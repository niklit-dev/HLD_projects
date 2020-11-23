`timescale 1ns / 1ps

module Farrow
    #(
        parameter wight_data_in  = 16, // Разрядность входных данных
        parameter width_data_out = 21, // Разрядность выходных данных
        parameter wight_delay    = 18, // Разрядность задержек
        parameter polinom        = 5,  // Порядок полинома
        parameter [5*32-1:0]round_mul = {32'd524288,32'd524288,32'd524288,32'd524288,32'd524288}, // Коэффициенты округления
        parameter [5*32-1:0]shift_mul = {32'd20,32'd20,32'd20,32'd20,32'd20},                      // Величины сдвига
        parameter wigth_fir_0    = 18, // Разрядность на выходе 0-го fir
        parameter wigth_fir_1    = 18, // Разрядность на выходе 1-го fir
        parameter wigth_fir_2    = 19, // Разрядность на выходе 2-го fir
        parameter wigth_fir_3    = 18, // Разрядность на выходе 3-го fir
        parameter wigth_fir_4    = 18, // Разрядность на выходе 4-го fir
        parameter wigth_fir_all  = 24, // Разрядность на выходе fir кратная байту
        parameter latency_fir    = 32, // Задержка при прохождении через fir
        parameter N_chanals      = 32, // Количество каналов
        parameter N_DN           = 18  // Количество ДН
    )
    (
        input clk,
        input rst,
        // Входные данные
        input                    vld_in,
        input                    last_in,
        input [wight_data_in-1:0]data_in,
        // Коэффициенты задержек
        input                  clk_del,
        input                  vld_del,
        input                  last_del,
        input [wight_delay-1:0]data_del,
        // Выходные данные
        output                     vld_out,
        output                     last_out,
        output [width_data_out-1:0]data_out[N_DN-1:0],
        // Шина AXI_Lite
        input s_axil_clk,
        input s_axil_rst,
        // write
        input  [31:0] s_axil_awaddr,
        input  [ 3:0] s_axil_awid,  
        input         s_axil_awvalid, 
        output        s_axil_awready, 
        input  [31:0] s_axil_wdata,   
        input  [ 3:0] s_axil_wstrb,    
        input         s_axil_wvalid,  
        output        s_axil_wready,  
        output  [ 1:0] s_axil_bresp,   
        output        s_axil_bvalid,  
        input         s_axil_bready, 
        output [ 3:0] s_axil_bid,
        // read
        input  [ 3:0] s_axil_arid,
        input  [31:0] s_axil_araddr,  
        input         s_axil_arvalid, 
        output        s_axil_arready, 
        output [31:0] s_axil_rdata,   
        output [ 1:0] s_axil_rresp,   
        output        s_axil_rvalid,  
        input         s_axil_rready,
        output [ 3:0] s_axil_rid
    );
    
    // Задержка на одном элементе mult_sum
    parameter del_mult_sum = 3;
    // Задержка на всех элементах mult_sum
    parameter del_mult_sum_x = del_mult_sum*(polinom-1);
    
    // Состояния конечного автомата на AXI Lite
//    typedef enum logic[2:0] {IDLE, WRADDRL, WRADDRH, BRESP, ENDBR} state_AXIL_t;
//    state_AXIL_t st_AXIL;
    
    wire [width_data_out-1:0]data_fir_i[polinom-1:0];
    wire vld_fir_i;
    wire last_fir_i;
//    reg  vld_del_i;
    reg  last_del_i;
    reg  [wight_delay-1:0]data_del_i;
    reg  [31:0]count_del_ch_i;
    reg  [31:0]count_del_dn_i;
    reg  [N_DN-1:0]en_del_i;
    wire vld_out_i[N_DN-1:0];
    reg  [del_mult_sum_x+35:0]last_out_i;
    
//    // Автомат AXI Lite
//    reg        s_axil_awready_i; 
//    reg        s_axil_wready_i;   
//    reg        s_axil_bvalid_i;   
//    reg [ 3:0] s_axil_bid_i;
    
    // Блок КИХ фильтров
    FIRx
        #(
            .wight_data_in (wight_data_in),
            .width_data_out(width_data_out),
            .wigth_fir_0   (wigth_fir_0),
            .wigth_fir_1   (wigth_fir_1),
            .wigth_fir_2   (wigth_fir_2),
            .wigth_fir_3   (wigth_fir_3),
            .wigth_fir_4   (wigth_fir_4),
            .polinom       (polinom),
            .wigth_fir_all (wigth_fir_all),
            .latency_fir   (latency_fir)
        )
    FIRx_inst
        (
            .rst(rst),
            .clk(clk),
            // Входные данные
            .data_in(data_in),
            .vld_in (vld_in),
            .last_in(last_in),
            // Выходные данные
            .data_out(data_fir_i),
            .vld_out (vld_fir_i),
            .last_out(last_fir_i)
        );
    
    // Инстантиируем умножение на задержку по количеству ДН
    genvar i;
    generate
    for(i=0; i<N_DN; i++)
    begin : mul_sum_gen
        multiplier_del
        #(
            .width_data (width_data_out),
            .wight_delay(wight_delay),
            .polinom    (polinom),
            .round_mul  (round_mul),
            .shift_mul  (shift_mul)
        )
        multiplier_del_inst
        (
            .rst(rst),
            .clk(clk),
            // Входные данные
            .vld_in (vld_fir_i),
            .last_in(last_fir_i),
            .data_in(data_fir_i),
            // Задержки на запись
            .clk_del (clk_del),
            .vld_del (en_del_i[i]),
            .last_del(last_del_i),
            .data_del(data_del_i),        
            // Выходные данные
            .data_out(data_out[i]),        
            .vld_out (vld_out_i[i])      
        );
    end
    endgenerate        
    
    // --------- Запись коэффициентов ----------
    // Счетчики коэффициентов по каналам
    always@(posedge clk_del)
    begin
        if(rst == '1)
            count_del_ch_i <= '0;
        else
        begin
            if(last_del == '1 & vld_del == '1)
                count_del_ch_i <= '0;
            else if(count_del_ch_i == N_chanals-1 & vld_del == '1)
                count_del_ch_i <= '0;
            else if(vld_del == '1)
                count_del_ch_i <= count_del_ch_i+1;
        end
    end
    // Счетчики коэффициентов по диаграммам
    always@(posedge clk_del)
    begin
        if(rst == '1)
            count_del_dn_i <= '0;
        else
        begin
            if(last_del == '1 & vld_del == '1)
                count_del_dn_i <= 0;
            else if(count_del_ch_i == N_chanals-1 & vld_del == '1 & count_del_dn_i == N_DN-1)
                count_del_dn_i <= 0;
            else if(count_del_ch_i == N_chanals-1 & vld_del == '1)
                count_del_dn_i <= count_del_dn_i+1;
        end
    end    
    // Дешифратор
    always@(posedge clk_del)
    begin
        if(rst == '1)    
            en_del_i <= '0;
        else
        begin
            for(int n_dec=0; n_dec<N_DN; n_dec++)
                if(count_del_dn_i == n_dec & vld_del == '1) 
                    en_del_i[n_dec] <= '1;
                else
                    en_del_i[n_dec] <= '0;
        end
    end
    // Задержка коэффициентов
    always@(posedge clk_del)
    begin
        if(rst == '1)  
        begin    
            data_del_i <= '0;
//            vld_del_i  <= '0;
            last_del_i <= '0;
        end
        else
        begin
            data_del_i <= data_del;
//            vld_del_i  <= vld_del;
            last_del_i <= last_del;
        end
    end
    
    // Задержка last
    always@(posedge clk)
    begin
        if(rst == '1)
        begin    
            for(int q=0; q<=del_mult_sum_x+35; q++)
            begin
                last_out_i[q]   <= '0;
            end
        end
        else
        begin    
            for(int q=1; q<=del_mult_sum_x+35; q++)
            begin
                last_out_i[q] <= last_out_i[q-1];
            end
            last_out_i[0] <= last_in;
        end
    end
    
    // Выходные данные
    assign vld_out  = vld_out_i[0];
    assign last_out = last_out_i[del_mult_sum_x+35];
    
    // Выходная шина AXIL
    assign s_axil_awready = '0;
    assign s_axil_wready  = '0;
    assign s_axil_bvalid  = '0;
    assign s_axil_bresp   = '0;
    assign s_axil_bid     = '0;               
    assign s_axil_arready = '0;
    assign s_axil_rdata   = '0;
    assign s_axil_rresp   = '0;
    assign s_axil_rvalid  = '0;
    assign s_axil_rid     = '0;
    
endmodule
