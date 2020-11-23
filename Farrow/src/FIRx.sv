`timescale 1ns / 1ps


module FIRx
    #(
        parameter wight_data_in  = 16, // Разрядность входных данных
        parameter width_data_out = 21, // Разрядность выходных данных
//        parameter [5*32-1:0]wigth_fir = {32'd18,32'd18,32'd19,32'd18,32'd18},     // Разрядность на выходе данных fir-ов
        parameter wigth_fir_0 = 18, // Разрядность на выходе 0-го fir
        parameter wigth_fir_1 = 18, // Разрядность на выходе 1-го fir
        parameter wigth_fir_2 = 19, // Разрядность на выходе 2-го fir
        parameter wigth_fir_3 = 18, // Разрядность на выходе 3-го fir
        parameter wigth_fir_4 = 18, // Разрядность на выходе 4-го fir
        parameter polinom        = 5,   // Порядок полинома
        parameter wigth_fir_all = 24,  // Разрядность на выходе fir кратная байту
        parameter latency_fir   = 23   // задержка при прохождении через fir
    )
    (
        input rst,
        input clk,
        // Входные данные
        input [wight_data_in-1:0]data_in,
        input vld_in,
        input last_in,
        // Выходные данные
        output [width_data_out-1:0]data_out[polinom-1:0],
        output vld_out,
        output last_out
    );
    
//    wire vld_out_i;
//    wire last_out_i;
    reg  [latency_fir-1:0]last_del_i;
    wire [wigth_fir_all-1:0]data_fir_i[polinom-1:0];
//    wire [wigth_fir[0]-1:0]data_fir_i_0;
//    wire [wigth_fir[1]-1:0]data_fir_i_1;
//    wire [wigth_fir[2]-1:0]data_fir_i_2;
//    wire [wigth_fir[3]-1:0]data_fir_i_3;
//    wire [wigth_fir[4]-1:0]data_fir_i_4;
    wire vld_fir_i[polinom-1:0];
//    generate
//    for(genvar j=polinom-1; j>=0; j--)
//    begin : data_fir
//        wire [wigth_fir[j]-1:0]data_fir_i[j];
//    end
//    endgenerate
        
        
        
    // Полином 0-го порядка
    fir_compiler_0 fir_pol_0_inst
    (
        .aclk(clk),                
        .s_axis_data_tvalid(vld_in),  
        .s_axis_data_tready(),  
        .s_axis_data_tdata (data_in),   
        .m_axis_data_tvalid(vld_fir_i[0]),  
        .m_axis_data_tdata (data_fir_i[0])   
    );
    // Полином 1-го порядка
    fir_compiler_1 fir_pol_1_inst
    (
        .aclk(clk),                
        .s_axis_data_tvalid(vld_in),  
        .s_axis_data_tready(),  
        .s_axis_data_tdata (data_in),   
        .m_axis_data_tvalid(vld_fir_i[1]),  
        .m_axis_data_tdata (data_fir_i[1])   
    );
    // Полином 2-го порядка
    fir_compiler_2 fir_pol_2_inst
    (
        .aclk(clk),                
        .s_axis_data_tvalid(vld_in),  
        .s_axis_data_tready(),  
        .s_axis_data_tdata (data_in),   
        .m_axis_data_tvalid(vld_fir_i[2]),  
        .m_axis_data_tdata (data_fir_i[2])   
    );
    // Полином 3-го порядка
    fir_compiler_3 fir_pol_3_inst
    (
        .aclk(clk),                
        .s_axis_data_tvalid(vld_in),  
        .s_axis_data_tready(),  
        .s_axis_data_tdata (data_in),   
        .m_axis_data_tvalid(vld_fir_i[3]),  
        .m_axis_data_tdata (data_fir_i[3])   
    );
    // Полином 4-го порядка
    fir_compiler_4 fir_pol_4_inst
    (
        .aclk(clk),                
        .s_axis_data_tvalid(vld_in),  
        .s_axis_data_tready(),  
        .s_axis_data_tdata (data_in),   
        .m_axis_data_tvalid(vld_fir_i[4]),  
        .m_axis_data_tdata (data_fir_i[4])   
    );    
    
    // Задержка входного last
    always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            last_del_i <= '0;
        end
        else
        begin 
            for(int i=1;i<latency_fir;i++)begin
                last_del_i[i] <= last_del_i[i-1];
            end
            last_del_i[0] <= last_in;
        end
    end        
          
    // Выхожные данные
    assign last_out   = last_del_i[latency_fir-1];
    assign vld_out    = vld_fir_i[0];

    assign data_out[0] = data_fir_i[0][width_data_out-1:0];  
    assign data_out[1] = data_fir_i[1][width_data_out-1:0];    
    assign data_out[2] = data_fir_i[2][width_data_out-1:0];
    assign data_out[3] = data_fir_i[3][width_data_out-1:0];
    assign data_out[4] = data_fir_i[4][width_data_out-1:0];

//    assign data_out[0][wigth_fir_0-1:0]              = data_fir_i[0][wigth_fir_0-1:0];
//    assign data_out[0][width_data_out-1:wigth_fir_0] = data_fir_i[0][wigth_fir_0-1];
    
//    assign data_out[1][wigth_fir_1-1:0]              = data_fir_i[1][wigth_fir_1-1:0];
//    assign data_out[1][width_data_out-1:wigth_fir_1] = data_fir_i[1][wigth_fir_1-1];
    
//    assign data_out[2][wigth_fir_2-1:0]              = data_fir_i[2][wigth_fir_2-1:0];
//    assign data_out[2][width_data_out-1:wigth_fir_2] = data_fir_i[2][wigth_fir_2-1];
    
//    assign data_out[3][wigth_fir_3-1:0]              = data_fir_i[3][wigth_fir_3-1:0];
//    assign data_out[3][width_data_out-1:wigth_fir_3] = data_fir_i[3][wigth_fir_3-1];
    
//    assign data_out[4][wigth_fir_4-1:0]              = data_fir_i[4][wigth_fir_4-1:0];
//    assign data_out[4][width_data_out-1:wigth_fir_4] = data_fir_i[4][wigth_fir_4-1];

endmodule
