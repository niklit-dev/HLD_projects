`timescale 1ns / 1ps

module mult_sum
    #(
        parameter wight_data  = 20,     // Разрядность вхлодных и выходных данных  
        parameter wight_delay = 18,     // Разрядность задержек
        parameter round       = 524288, // Коэффициент округления
        parameter shift       = 20      // Величина сдвига
    )
    (
        input rst,
        input clk,
        // Входные данные
        input  [ wight_data-1:0]data_in,
        input  [wight_delay-1:0]delay,
        input  [ wight_data-1:0]data_fir,
        input  vld_in,    
        // Выходные данные
        output [wight_data-1:0]data_out
    );
    
    parameter wight_mul = wight_data+wight_delay-1;
    
    reg  [1:0]vld_del_i;
    wire vld_round_i;
    wire vld_sum_i;
    wire [ wight_mul-1:0]data_mul_i;
    wire [ wight_mul-1:0]data_mul_round_i;
    wire [wight_data-1:0]data_round_i;
    
    // Задержка входной vld
    always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            vld_del_i <= '0;
        end
        else
        begin 
            for(int i=1;i<2;i++)begin
                vld_del_i[i] <= vld_del_i[i-1];
            end
            vld_del_i[0] <= vld_in;
        end
    end     
    
    // Валидность округления
    assign vld_round_i = vld_del_i[0];
    // Валидность сложения
    assign vld_sum_i   = vld_del_i[1];
    
    // Умножение на задержку
    mult_gen_0 mult_del
    (
        .CLK(clk), 
        .A  (data_in), 
        .B  (delay), 
        .P  (data_mul_i) 
    );
    
    // Сложение с коэффициентом округления
    c_addsub_round c_addsub_round
    (
        .A  (data_mul_i), 
        .B  (round), 
        .CLK(clk), 
        .CE (vld_round_i), 
        .S  (data_mul_round_i) 
    );
    
    assign data_round_i = data_mul_round_i[wight_mul-1:shift];
    
    // Сложение с сигналом после КИХ фильтра
    c_addsub_fir c_addsub_fir
    (
        .A  (data_round_i), 
        .B  (data_fir), 
        .CLK(clk), 
        .CE (vld_sum_i), 
        .S  (data_out) 
    );

endmodule
