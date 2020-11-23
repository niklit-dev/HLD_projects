`timescale 1ns / 1ps
`include "Interface_AXI.vh"
`include "FDN_param.vh"

module FDN_TB;
    
    const string NameFileCoefRe       = {NameDir, "CoefRe/CoefRe.txt"}; 
    const string NameFileCoefIm       = {NameDir, "CoefIm/CoefIm.txt"}; 
    const string NameFileDataFarInRe  = {NameDir, "EtalonsFarrow/DataReIn/DataOutRe"}; 
    const string NameFileDataFarInIm  = {NameDir, "EtalonsFarrow/DataImIn/DataOutIm"}; 
    const string NameFileDataOneInRe  = {NameDir, "EtalonsOne/DataReIn/DataReIn"}; 
    const string NameFileDataOneInIm  = {NameDir, "EtalonsOne/DataImIn/DataImIn"}; 
    const string NameFileDataFarOutRe = {NameDir, "EtalonsFarrow/DataReOut/DataFarReOut"}; 
    const string NameFileDataFarOutIm = {NameDir, "EtalonsFarrow/DataImOut/DataFarImOut"}; 
    const string NameFileDataOneOutRe = {NameDir, "EtalonsOne/DataReOut/DataOneReOut"}; 
    const string NameFileDataOneOutIm = {NameDir, "EtalonsOne/DataImOut/DataOneImOut"};  
    const string NameFileDataFarEtlRe = {NameDir, "EtalonsFarrow/DataReEtl/DataOutRe"}; 
    const string NameFileDataFarEtlIm = {NameDir, "EtalonsFarrow/DataImEtl/DataOutIm"}; 
    const string NameFileDataOneEtlRe = {NameDir, "EtalonsOne/DataReEtl/DataReEtl"}; 
    const string NameFileDataOneEtlIm = {NameDir, "EtalonsOne/DataImEtl/DataImEtl"};   
    string CoefOK = "";
    string FarOK = "";
    string Mode = "";
    string Comp[FDN_N_DN] = "";
    string Name;
    reg clk_coef;
    reg clk;
    reg rst;  
    reg clk_axi;  
    wire [FDN_wight_data_i-1:0] dataReIn[FDN_N_DN-1:0];
    wire [FDN_wight_data_i-1:0] dataImIn[FDN_N_DN-1:0];
    wire [FDN_wight_data_o-1:0] dataReOut[FDN_N_DN-1:0];
    wire [FDN_wight_data_o-1:0] dataImOut[FDN_N_DN-1:0];
    wire vld_data_out;
    wire coef_tready;
    wire data_tready;
    integer DN_streamRe[FDN_N_DN-1:0][FDN_N_test-1:0];
    integer DN_streamIm[FDN_N_DN-1:0][FDN_N_test-1:0];
    
    // Функция сравнения данных
    function Compare;
        input string NameFile1; 
        input string NameFile2;
        input integer Len;
        begin
            integer File1, File2;
            integer data1, data2;
            string line1, line2;
            // Открываем файлы
            File1 = $fopen(NameFile1, "r");
            File2 = $fopen(NameFile2, "r");
            // Проверяем успешное открытие файлов
            if(File1 == 0)
            begin
                $display("Файл", NameFile1, "не открылся!");
                $finish;
            end   
            if(File2 == 0)
            begin
                $display("Файл", NameFile2, "не открылся!");
                $finish;
            end             
            // Цикл чтения и сравнения
            for(int i = 0; i < Len; i++)
            begin
                // Читаем строку  
                $fgets(line1, File1);
                data1 = line1.atoi(); 
                $fgets(line2, File2);
                data2 = line2.atoi(); 
                if(data1 != data2)
                begin
                    $display("Файл", NameFile1, " не сходится с файлом ", NameFile2);
                    $finish;
                end
            end
            $display("Файлы", NameFile1, NameFile2, " сошлись!");
        end
    endfunction
    
    // Создаем мастер AXI_Stream для коэффициентов
    M_AXI_Stream #(.widht_data(FDN_wight_coef_i)) M_AXI_CoefRe(.clk(clk_coef));    
    M_AXI_Stream #(.widht_data(FDN_wight_coef_i)) M_AXI_CoefIm(.clk(clk_coef)); 
    // Создаем мастер AXI_Lite для управления блоком
    M_AXI_Lite MAXIL(.clk(clk_axi));          
    
    // Тактовый сигнал записи коэффициентов
    always
        #4 clk_coef = !clk_coef;
    
    // Тактовый сигнал
    always
        #2.5 clk = ! clk;
        
    // Тактовый сигнал AXI   
    always
        #5 clk_axi = ! clk_axi;
        
    // Запись коэффициентов    
    initial
    begin
        clk = 0;
        clk_coef = 0;
        clk_axi = 0;
        rst = 1;  
        #30
        rst = 0; 
        // ------- Режим работы фильтра Фарроу -------
        // Записываем настройки в блок
        MAXIL.MasterWrite(FDN_AddrAXI, '1); // Режим Фарроу
        // Записываем коэффициенты
        fork
            M_AXI_CoefRe.MasterWriteFromFile(NameFileCoefRe, FDN_N_chanals*FDN_N_DN);
            M_AXI_CoefIm.MasterWriteFromFile(NameFileCoefIm, FDN_N_chanals*FDN_N_DN);
        join   
        CoefOK = "OK";
        $display("Coef writen");
        // ------- Режим работы без фильтра Фарроу ------- 
        wait (FarOK == "OK");
        // Записываем настройки в блок
        MAXIL.MasterWrite(FDN_AddrAXI, '0); // Режим без Фарроу      
        Mode = "OK"; 
        for(int i = 0; i < FDN_N_DN; i++)
            wait(Comp[i] == "OK");
        $display("Тест успешно пройден!");
        $finish;
    end     
    
    generate    
        for(genvar j = 0; j < FDN_N_DN; j++) 
        begin: data
            // Генерим интерфейсы
            // Создаем мастер AXI_Stream для данных
            M_AXI_Stream #(.widht_data(FDN_wight_data_i)) M_AXI_DataRe(.clk(clk));
            M_AXI_Stream #(.widht_data(FDN_wight_data_i)) M_AXI_DataIm(.clk(clk));
            // Создаем слэйв AXI_Stream для принимаемых диаграмм
            S_AXI_Stream #(.widht_data(FDN_wight_data_o), .dempf(FDN_N_test)) S_AXI_DataRe(.clk(clk));
            S_AXI_Stream #(.widht_data(FDN_wight_data_o), .dempf(FDN_N_test)) S_AXI_DataIm(.clk(clk));
    
            // Генерим соединения блока FDN_core_x с интерфейсами
            assign dataReIn[j] = data[j].M_AXI_DataRe.tdata;
            assign dataImIn[j] = data[j].M_AXI_DataIm.tdata;
            
            assign data[j].M_AXI_DataRe.tready = data_tready;
            assign data[j].M_AXI_DataIm.tready = data_tready;
            
            assign data[j].S_AXI_DataRe.tdata = dataReOut[j];
            assign data[j].S_AXI_DataIm.tdata = dataImOut[j]; 
            
            assign data[j].S_AXI_DataRe.tvalid = vld_data_out;
            assign data[j].S_AXI_DataIm.tvalid = vld_data_out;  
           
            // Запускаем процесс выдачи и приема данных
            initial
            begin   
                wait (CoefOK == "OK");     
                // Записываем входные данные и принимаем полученные ДН 
                // для совместной работы с фильтром Фарроу     
                fork
                    // Запись данных
                    // Действительная часть входных данных              
                    data[j].M_AXI_DataRe.MasterWriteFromFile($sformatf("%s%0d%s", NameFileDataFarInRe, j, ".txt"), FDN_N_test*FDN_N_chanals);
                    // Мнимая часть входных данных
                    data[j].M_AXI_DataIm.MasterWriteFromFile($sformatf("%s%0d%s", NameFileDataFarInIm, j, ".txt"),FDN_N_test*FDN_N_chanals);
                    // Чтение данных
                    // Действительная часть выходных данных
                    data[j].S_AXI_DataRe.MasterReadToFileL($sformatf("%s%0d%s", NameFileDataFarOutRe, j, ".txt"), FDN_N_test);
                    // Мнимая часть выходных данных
                    data[j].S_AXI_DataIm.MasterReadToFileL($sformatf("%s%0d%s", NameFileDataFarOutIm, j, ".txt"), FDN_N_test);          
                join
                FarOK = "OK";
                // Ждем записи настроек
                wait(Mode == "OK")
                // Записываем входные данные и принимаем полученные ДН 
                // для работы без фильтра Фарроу     
                fork
                    // Запись данных
                    // Действительная часть входных данных              
                    data[j].M_AXI_DataRe.MasterWriteFromFile($sformatf("%s%s", NameFileDataOneInRe, ".txt"), FDN_N_test*FDN_N_chanals);
                    // Мнимая часть входных данных
                    data[j].M_AXI_DataIm.MasterWriteFromFile($sformatf("%s%s", NameFileDataOneInIm, ".txt"),FDN_N_test*FDN_N_chanals);
                    // Чтение данных
                    // Действительная часть выходных данных
                    data[j].S_AXI_DataRe.MasterReadToFileL($sformatf("%s%0d%s", NameFileDataOneOutRe, j, ".txt"), FDN_N_test);
                    // Мнимая часть выходных данных
                    data[j].S_AXI_DataIm.MasterReadToFileL($sformatf("%s%0d%s", NameFileDataOneOutIm, j, ".txt"), FDN_N_test);          
                join
                // Сравниваем данные
                Compare($sformatf("%s%0d%s", NameFileDataFarOutRe, j, ".txt"), $sformatf("%s%0d%s", NameFileDataFarEtlRe, j, ".txt"), FDN_N_test);
                Compare($sformatf("%s%0d%s", NameFileDataFarOutIm, j, ".txt"), $sformatf("%s%0d%s", NameFileDataFarEtlIm, j, ".txt"), FDN_N_test);
//                Compare($sformatf("%s%0d%s", NameFileDataOneOutRe, j, ".txt"), $sformatf("%s%0d%s", NameFileDataOneEtlRe, j, ".txt"), FDN_N_test);
//                Compare($sformatf("%s%0d%s", NameFileDataOneOutIm, j, ".txt"), $sformatf("%s%0d%s", NameFileDataOneEtlIm, j, ".txt"), FDN_N_test);
                // Сравнение завершилось
                Comp[j] = "OK";
            end
        end
    endgenerate        
    
    assign M_AXI_CoefRe.tready = coef_tready;
    assign M_AXI_CoefIm.tready = coef_tready;
    
    FDN_core_x
	#(
        .wight_data_i   (FDN_wight_data_i),
        .wight_comp_a_i (FDN_wight_comp_a_i),         
        .wight_mult     (FDN_wight_mult),
        .wight_data_o   (FDN_wight_data_o),
        .wight_comp_o_i (FDN_wight_comp_o_i),
        .wight_comp_b_i (FDN_wight_comp_b_i), 
        .wight_coef_i   (FDN_wight_coef_i), 
        .N_chanals      (FDN_N_chanals),
        .Round          (FDN_Round),
        .shiftR         (FDN_shiftR),
        .N_DN           (FDN_N_DN),
        .AddrAXI        (FDN_AddrAXI)
    )
    FDN_core_x_inst
    (
        .clk_coef(clk_coef),
        .clk(clk),                                                 
        .rst(rst),                                                 
        // Входной поток данных                                    
        .vld_data_in(data[0].M_AXI_DataRe.tvalid), 
        .last_data_in(data[0].M_AXI_DataRe.tlast),
        .readi_data_in(data_tready),                 
        .dataReIn(dataReIn),                                       
        .dataImIn(dataImIn),                                       
        // Входной поток коэффициентов                             
        .vld_coef_in(M_AXI_CoefRe.tvalid),                         
        .last_coef_in(M_AXI_CoefRe.tlast),               
        .readi_coef_in(coef_tready),             
        .coefReIn(M_AXI_CoefRe.tdata),                             
        .coefImIn(M_AXI_CoefIm.tdata),                             
        // Выходной поток диаграмм                                 
        .vld_data_out(vld_data_out),  
        .last_data_out(),                           
        .dataReOut(dataReOut),                                     
        .dataImOut(dataImOut),                                     
        // Шина AXI_Lite                                           
        .s_axil_clk(clk_axi),                                      
        .s_axil_rst(rst),                                          
        // write                                                   
        .s_axil_awaddr  (MAXIL.awaddr),                            
        .s_axil_awid    ('0),                                      
        .s_axil_awvalid (MAXIL.awvalid),                           
        .s_axil_awready (MAXIL.awready),                           
        .s_axil_wdata   (MAXIL.wdata  ),                           
        .s_axil_wstrb   (MAXIL.wstrb  ),                           
        .s_axil_wvalid  (MAXIL.wvalid ),                           
        .s_axil_wready  (MAXIL.wready ),                           
        .s_axil_bresp   (MAXIL.bresp  ),                           
        .s_axil_bvalid  (MAXIL.bvalid ),                           
        .s_axil_bready  (MAXIL.bready ),                           
        .s_axil_bid     (),                                        
        // read                                                    
        .s_axil_arid    ('0),                                      
        .s_axil_araddr  (MAXIL.araddr ),                           
        .s_axil_arvalid (MAXIL.arvalid),                           
        .s_axil_arready (MAXIL.arready),                           
        .s_axil_rdata   (MAXIL.rdata  ),                           
        .s_axil_rresp   (MAXIL.rresp  ),                           
        .s_axil_rvalid  (MAXIL.rvalid ),                           
        .s_axil_rready  (MAXIL.rready ),                           
        .s_axil_rid     ()                                         
    );
    
endmodule
