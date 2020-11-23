`timescale 1ns / 1ps
`include "Interface_AXI.vh"
`include "function.vh"
`include "Farrow_param.vh"

module Farrow_tb;

    const string NameFileIn  = {NameDir, "FiltFarDatIn/DataIn.txt"};
    const string NameFileDel = {NameDir, "FiltFarParam/Dalay.txt"};
    const string NameFileOut = {NameDir, "FiltFarOut/DataOut"};
    const string NameFileEtl = {NameDir, "FiltFarEtl/DataOut"};
    
    reg rst;
    reg clk_del;
    reg clk;
    wire [width_data_out-1:0]data_out[N_DN-1:0];
    wire vld_out;
    string Comp[N_DN] = "";

    // Тактовый сигнал записи задержек
    always
        #4 clk_del = !clk_del;
    
    // Тактовый сигнал
    always
        #2.5 clk = ! clk;
        
    // Создаем мастер AXI_Stream для коэффициентов
    M_AXI_Stream #(.widht_data(wight_delay)) M_AXI_Del(.clk(clk_del));
    // Создаем мастер AXI_Stream для входных данных
    M_AXI_Stream #(.widht_data(wight_data_in)) M_AXI_Data_in(.clk(clk));
    
    assign M_AXI_Del.tready = '1;
    assign M_AXI_Data_in.tready = '1;
    
    // Запись задержек и входных данных  
    initial
    begin
        clk = 0;
        clk_del = 0;
        rst = 1;  
        #30
        rst = 0; 
        // Записываем задержки
        M_AXI_Del.MasterWriteFromFile(NameFileDel, N_DN*N_chanals);
        $display("Задержки записаны.");
        #30
        // Записываем входные данные
        M_AXI_Data_in.MasterWriteFromFile(NameFileIn, N_chanals*N_test,3);//4
        #10
        $display("Входные данные записаны.");
        for(int i = 0; i < N_DN; i++)
            wait(Comp[i] == "OK");
        $display("Тест успешно пройден!");
        $finish;        
    end         
    
    // Чтение выходных данных
    generate    
        for(genvar j = 0; j < N_DN; j++) 
        begin: read_out
            // Создаем слэйв AXI_Stream для принимаемых диаграмм
            S_AXI_Stream #(.widht_data(width_data_out), .dempf(N_DN*N_chanals*N_test)) S_AXI_Data_Out(.clk(clk));
            // Соединяем блок Farrow с интерфейсом
            assign read_out[j].S_AXI_Data_Out.tdata  = data_out[j];
            assign read_out[j].S_AXI_Data_Out.tvalid = vld_out;
            
            // Запускаем процесс приема данных
            initial
            begin 
                // Чтение данных
                read_out[j].S_AXI_Data_Out.MasterReadToFileL($sformatf("%s%0d%s", NameFileOut, j, ".txt"), N_chanals*N_test);
                $display("Выходные данных для %d диаграммы считаны.", j);
                #10
                // Сравниваем данные
                Compare($sformatf("%s%0d%s", NameFileOut, j, ".txt"), $sformatf("%s%0d%s", NameFileEtl, j, ".txt"), N_chanals*N_test);
                #10
                // Сравнение завершилось
                Comp[j] = "OK";
            end
        end
    endgenerate      

    // Farrow
    Farrow
        #(
            .wight_data_in (wight_data_in),
            .width_data_out(width_data_out),
            .wight_delay   (wight_delay),
            .polinom       (polinom),
            .round_mul     (round_mul),         
            .shift_mul     (shift_mul),
            .wigth_fir_0   (wigth_fir_0),
            .wigth_fir_1   (wigth_fir_1),
            .wigth_fir_2   (wigth_fir_2),
            .wigth_fir_3   (wigth_fir_3),
            .wigth_fir_4   (wigth_fir_4),
            .wigth_fir_all (wigth_fir_all),
            .latency_fir   (latency_fir),
            .N_chanals     (N_chanals),
            .N_DN          (N_DN)
        )
    Farrow_inst
        (
            .clk(clk),
            .rst(rst),
            // Входные данные
            .vld_in (M_AXI_Data_in.tvalid),
            .last_in(M_AXI_Data_in.tlast),
            .data_in(M_AXI_Data_in.tdata),
            // Коэффициенты задержек
            .clk_del (clk_del),
            .vld_del (M_AXI_Del.tvalid),
            .last_del(M_AXI_Del.tlast),
            .data_del(M_AXI_Del.tdata),
            // Выходные данные
            .vld_out (vld_out),
            .last_out(),
            .data_out(data_out),
            // Шина AXI_Lite
            .s_axil_clk('1),
            .s_axil_rst('0),
            // write
            .s_axil_awaddr ('0),
            .s_axil_awid   ('0),  
            .s_axil_awvalid('0), 
            .s_axil_awready(), 
            .s_axil_wdata  ('0),   
            .s_axil_wstrb  ('0),    
            .s_axil_wvalid ('0),  
            .s_axil_wready (),  
            . s_axil_bresp (),   
            .s_axil_bvalid (),  
            .s_axil_bready ('0), 
            .s_axil_bid    (),
            // read
            .s_axil_arid   ('0),
            .s_axil_araddr ('0),  
            .s_axil_arvalid('0), 
            .s_axil_arready(), 
            .s_axil_rdata  (),   
            .s_axil_rresp  (),   
            .s_axil_rvalid (),  
            .s_axil_rready ('0),
            .s_axil_rid    ()
        );

endmodule
