`timescale 1ns / 1ps

module multiplier_del
    #(
        parameter width_data     = 21,  // Разрядность входных и выходных данных
        parameter wight_delay    = 20,  // Разрядность задержек
        parameter polinom        = 5,   // Порядок полинома
        parameter N_chanel       = 32,  // Количество каналов
        parameter [5*32-1:0]round_mul = {32'd524288,32'd524288,32'd524288,32'd524288,32'd524288}, // Коэффициенты округления
        parameter [5*32-1:0]shift_mul = {32'd20,32'd20,32'd20,32'd20,32'd20}                      // Величины сдвига
    )
    (
        input rst,
        input clk,
        // Входные данные
        input  vld_in,
        input  last_in,
        input  [width_data-1:0]data_in[polinom-1:0],
        // Задержки на запись
        input  clk_del,
        input  vld_del,
        input  last_del,
        input  [wight_delay-1:0]data_del,        
        // Выходные данные
        output [width_data-1:0]data_out,        
        output vld_out       
    );
    // Задержка на одном элементе mult_sum
    parameter del_mult_sum = 3;
    // Задержка на всех элементах mult_sum
    parameter del_mult_sum_x = del_mult_sum*(polinom-1);
    
    wire [ width_data-1:0]data_mul_in_i[polinom-1:0];
    wire [ width_data-1:0]data_mul_out_i[polinom-1:1];
    wire [ width_data-1:0]data_fir_i[polinom-1:1];
    wire [wight_delay-1:0]delay_reg_i[polinom-1:1];
    reg  [wight_delay-1:0]delay_del_i[del_mult_sum_x+4:0];
    wire [wight_delay-1:0]delay_mem_i;
    reg  [wight_delay-1:0]delay_i;
    reg  [ width_data-1:0]data_in_del_i[4:0];
    wire [ width_data-1:0]data_in_i;
    reg                   vld_del_in_i;
    wire                  vld_in_i[polinom-1:1];
    reg                   vld_del_i[del_mult_sum_x+4:0];
    reg  [ width_data-1:0]data_fir_del_i[del_mult_sum_x+5:0][polinom-2:0];
    reg  [wight_delay-1:0]count_del_in_i;
    reg  [wight_delay-1:0]count_del_out_i;
      
    // Входные данные
    assign data_mul_in_i[polinom-1] = data_in_i;
    
    // Сдвиговый регистр входных данных
    always@(posedge clk)
    begin
        if(rst == '1)
        begin    
            for(int q=0; q<=4; q++)
            begin
                data_in_del_i[q] <= '0;
            end
        end
        else
        begin    
            for(int q=1; q<=4; q++)
            begin
                data_in_del_i[q] <= data_in_del_i[q-1];
            end
            data_in_del_i[0] <= data_in[polinom-1];
        end
    end
    
    assign data_in_i = data_in_del_i[4];
    
    // ---------------- Инстантиируем элементы умножений со сложением ---------------
    genvar i;
    generate
    for(i=polinom-1; i>=1; i--)
    begin : mul_sum_gen  
        // Соединяем выходы и входы блоков mult_sum
        assign data_mul_in_i[i-1] = data_mul_out_i[i];
      
        // Умножение на задержку и сложение с отфильтрованными данными
        mult_sum 
            #(
                .wight_data (width_data),
                .wight_delay(wight_delay), 
                .round      (round_mul[(i+1)*32-1:i*32]),
                .shift      (shift_mul[(i+1)*32-1:i*32])
            )
        mult_sum_inst
            (
                .rst(rst),
                .clk(clk),
                // Входные данные
                .data_in (data_mul_in_i[i]),
                .delay   (delay_reg_i[i]),
                .data_fir(data_fir_i[i]),
                .vld_in  (vld_in_i[i]),    
                // Выходные данные
                .data_out(data_mul_out_i[i])
            );
            
        // Задержка КИХ фильтров
        always@(posedge clk)
        begin
            if(rst == '1)
            begin
                for(int q=0; q<del_mult_sum_x+6; q++)
                begin
                    data_fir_del_i[q][i-1] <= '0;
                end
            end
            else
            begin
                for(int q=1; q<del_mult_sum_x+6; q++)
                begin
                    data_fir_del_i[q][i-1] <= data_fir_del_i[q-1][i-1];
                end
                data_fir_del_i[0][i-1] <= data_in[i-1];
            end
        end      
        // Данные от КИХ фильтров после задержки 
        assign data_fir_i[i] = data_fir_del_i[del_mult_sum_x-(i-1)*del_mult_sum+3][i-1];
        // Коэффициенты задержек после задержки
        assign delay_reg_i[i] = delay_del_i[del_mult_sum_x-(i-1)*del_mult_sum-1];     //[i-1]   
        // Валидность данных
        assign vld_in_i[i] = vld_del_i[del_mult_sum_x-(i-1)*del_mult_sum+1];
    end
    endgenerate    
    
    // Сдвиговый регистр задержек
    always@(posedge clk)
    begin
        if(rst == '1)
        begin    
            for(int q=0; q<=del_mult_sum_x+4; q++)
            begin
                delay_del_i[q] <= '0;
                vld_del_i[q]   <= '0;
            end
        end
        else
        begin    
            for(int q=1; q<=del_mult_sum_x+4; q++)
            begin
                delay_del_i[q] <= delay_del_i[q-1];
                vld_del_i[q]   <= vld_del_i[q-1];
            end
            delay_del_i[0] <= delay_mem_i;
            vld_del_i[0]   <= vld_in;
        end
    end
    
    // Память задержек
    blk_mem_gen_0 blk_mem_delay
    (
        .clka (clk_del),
        .ena  (vld_del), // vld_del_in_i
        .wea  ('1),
        .addra(count_del_in_i),
        .dina (data_del), // delay_i
        .clkb (clk),
//        .enb  (vld_in),
        .addrb(count_del_out_i),
        .doutb(delay_mem_i)
    );
    
    // ----------- Запись коэффициентов в память ------------
    // Регистр vld_del
    always@(posedge clk_del)
    begin
        if(rst == '1)
        begin 
            vld_del_in_i <= '0;
        end
        else
        begin   
            vld_del_in_i <= vld_del;
        end
    end
    
    // Счетчик адресов на запись
    always@(posedge clk_del)
    begin
        if(rst == '1)
        begin   
            count_del_in_i <= '0;
        end
        else
        begin    
            if(last_del == '1 || count_del_in_i == N_chanel-1)
                count_del_in_i <= '0;
            else if(vld_del == '1)
                count_del_in_i <= count_del_in_i + 1;
        end
    end  
    
    // Счетчик адресов на чтение
    always@(posedge clk)
    begin
        if(rst == '1)
        begin   
            count_del_out_i <= '0;
        end
        else
        begin    
            if((last_in == '1 && vld_in == '1) || (count_del_out_i == N_chanel-1 && vld_in == '1))
                count_del_out_i <= '0;
            else if(vld_in == '1)
                count_del_out_i <= count_del_out_i + 1;
        end
    end
    
    // Входные коэффициенты задержек
    always@(posedge clk_del)
    begin
        if(rst == '1)
        begin  
            delay_i <= '0;
        end
        else
        begin 
            delay_i <= data_del;
        end
    end                 
    
    // Выходные данные
    assign data_out = data_mul_out_i[1];
    // Выходная валидность
    assign vld_out = vld_del_i[del_mult_sum_x+4];
        
endmodule
