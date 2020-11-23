`timescale 1ns / 1ps

module FDN_core_x
	#(
        parameter wight_data_i   = 25,
        parameter wight_comp_a_i = 32,         
        parameter wight_mult     = 49,
        parameter wight_data_o   = 32,
        parameter wight_comp_o_i = 51,
        parameter wight_comp_b_i = 24, 
        parameter wight_coef_i   = 24, 
        parameter N_chanals      = 32,
        parameter Round          = 1024,
        parameter shiftR         = 10,
        parameter N_DN           = 72,
        parameter AddrAXI        = 32'hf0000000
    )
    (
        input clk_coef,
        input clk,
        input rst,
        // Входной поток данных
        input vld_data_in,
        input last_data_in,
        output readi_data_in,
        input [wight_data_i-1:0] dataReIn[N_DN-1:0],
        input [wight_data_i-1:0] dataImIn[N_DN-1:0],
        // Входной поток коэффициентов
        input vld_coef_in,
        input last_coef_in,
        output readi_coef_in,
        input [wight_coef_i-1:0] coefReIn,
        input [wight_coef_i-1:0] coefImIn,
        // Выходной поток диаграмм
        output vld_data_out,
        output last_data_out,
        output [wight_data_o-1:0] dataReOut[N_DN-1:0],
        output [wight_data_o-1:0] dataImOut[N_DN-1:0],
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
    
    function integer log2;
        input integer value;
        begin
            value = value-1;
            for (log2=0; value>0; log2=log2+1)
                value = value>>1;
        end
    endfunction
    
    
    reg [3:0]stateAXI;
    
    parameter s0  = 4'b0000; 
    parameter sw  = 4'b0001;
    parameter sw1 = 4'b0010;
    parameter sw2 = 4'b0011;
    parameter sw3 = 4'b0100;
    parameter sw4 = 4'b0101;
    parameter sr  = 4'b0110;
    parameter sr1 = 4'b0111;
    parameter sr2 = 4'b1000;
    
        
    reg [wight_data_i-1:0]dataReIn_i[N_DN-1:0];
    reg [wight_data_i-1:0]dataImIn_i[N_DN-1:0];
    reg [N_DN-1:0]vld_data_in_i;
    reg FarrowEn_i;
    reg [log2(N_chanals)-1:0]count_coef_ch_i;
    reg [log2(N_DN)-1:0]count_coef_dn_i;
    reg [N_DN-1:0]en_coef_i;
    reg [wight_coef_i-1:0]coefReIn_i;
    reg [wight_coef_i-1:0]coefImIn_i;
    reg s_axil_awready_i;
    reg s_axil_arready_i;
    reg s_axil_bvalid_i; 
    reg s_axil_wready_i; 
    reg [3:0]s_axil_bid_i;    
    reg [3:0]s_axil_rid_i;    
    reg s_axil_rvalid_i; 
    reg [31:0]s_axil_rdata_i;
    reg reg_axil_rst_i;
    reg reg_axil_far_i;
    reg reg_axil_err_i;
    reg [31:0]reg_err_i;
    reg rst_i;
    reg rst_all_i;
    wire [N_DN-1:0]vld_data_out_i;
    wire [N_DN-1:0]last_data_out_i;
    integer n_dec;
    
    // Разрешение записи коэффициентов
    assign readi_coef_in = ~vld_data_in;
    // Разрешение записи данных
    assign readi_data_in = ~rst;
    
    // Переход между клоковыми доменами
    always@(posedge clk)
    begin
        if(rst == '1)
        begin
            FarrowEn_i <= '0;
        end
        else
        begin 
            FarrowEn_i <= reg_axil_far_i;
        end
    end
    
    // Инстантиируем FDN_core
    genvar i;
    generate
    for(i=0; i<N_DN; i++)
    begin : FDN_gen
        // Мультиплексор
        always@(posedge clk)
        begin
            if(rst_all_i == '1)
            begin
                dataReIn_i[i]    <= '0;
                dataImIn_i[i]    <= '0;
                vld_data_in_i[i] <= '0;
            end
            else
            begin
                if(FarrowEn_i == '1)
                begin
                    dataReIn_i[i]    <= dataReIn[i];
                    dataImIn_i[i]    <= dataImIn[i];
                    vld_data_in_i[i] <= vld_data_in;
                end
                else
                begin
                    dataReIn_i[i]    <= dataReIn[0];
                    dataImIn_i[i]    <= dataImIn[0];  
                    vld_data_in_i[i] <= vld_data_in;              
                end
            end
        end
        // FDN_core
        FDN_core 
        #(
            .wight_data_i   (wight_data_i),
            .wight_comp_a_i (wight_comp_a_i),         
            .wight_mult     (wight_mult),
            .wight_data_o   (wight_data_o),
            .wight_comp_o_i (wight_comp_o_i),
            .wight_comp_b_i (wight_comp_b_i), 
            .wight_coef_i   (wight_coef_i), 
            .N_chanals      (N_chanals),
            .Round          (Round),
            .shiftR         (shiftR)
        )
        FDN_core_inst
        (
            .clk_coef       (clk_coef),
            .clk            (clk),
            .rst            (rst_all_i),
            .vld_data_in    (vld_data_in_i[i]),
            .last_data_in   (last_data_in),
            .dataReIn       (dataReIn_i[i]),
            .dataImIn       (dataImIn_i[i]),
            .vld_coef_in    (en_coef_i[i]),
            .coefReIn       (coefReIn_i),
            .coefImIn       (coefImIn_i),
            .vld_data_out   (vld_data_out_i[i]),
            .last_data_out  (last_data_out_i[i]),
            .dataReOut      (dataReOut[i]),
            .dataImOut      (dataImOut[i]) 
        );        
    end
    endgenerate
    
    assign vld_data_out  = vld_data_out_i[0];
    assign last_data_out = last_data_out_i[0];
    
    // ---- Запись коэффициентов ----
//    // Счетчики коэффициентов по каналам
//    always@(posedge clk)
//    begin
//        if(rst_all_i == '1)
//            count_coef_ch_i <= '0;
//        else
//        begin
//            if(last_coef_in == '1 & vld_coef_in == '1)
//                count_coef_ch_i <= '0;
//            else if(count_coef_ch_i == N_chanals-1 & vld_coef_in == '1)
//                count_coef_ch_i <= '0;
//            else if(vld_coef_in == '1)
//                count_coef_ch_i <= count_coef_ch_i+1;
//        end
//    end
//    // Счетчики коэффициентов по диаграммам
//    always@(posedge clk)
//    begin
//        if(rst_all_i == '1)
//            count_coef_dn_i <= '0;
//        else
//        begin
//            if(last_coef_in == '1 & vld_coef_in == '1)
//                count_coef_dn_i <= 0;
//            else if(count_coef_ch_i == N_chanals-1 & vld_coef_in == '1 & count_coef_dn_i == N_DN-1)
//                count_coef_dn_i <= 0;
//            else if(count_coef_ch_i == N_chanals-1 & vld_coef_in == '1)
//                count_coef_dn_i <= count_coef_dn_i+1;
//        end
//    end    
//    // Дешифратор
//    always@(posedge clk)
//    begin
//        if(rst_all_i == '1)    
//            en_coef_i <= '0;
//        else
//        begin
//            for(n_dec=0; n_dec<N_DN; n_dec++)
//                if(count_coef_dn_i == n_dec & vld_coef_in == '1) 
//                    en_coef_i[n_dec] <= '1;
//                else
//                    en_coef_i[n_dec] <= '0;
//        end
//    end
//    // Задержка коэффициентов
//    always@(posedge clk)
//    begin
//        if(rst_all_i == '1)  
//        begin    
//            coefReIn_i <= '0;
//            coefImIn_i <= '0;
//        end
//        else
//        begin
//            coefReIn_i <= coefReIn;
//            coefImIn_i <= coefImIn;
//        end
//    end

    // Счетчики коэффициентов по каналам
    always@(posedge clk_coef)
    begin
        if(rst_all_i == '1)
            count_coef_ch_i <= '0;
        else
        begin
            if(last_coef_in == '1 & vld_coef_in == '1)
                count_coef_ch_i <= '0;
            else if(count_coef_ch_i == N_chanals-1 & vld_coef_in == '1)
                count_coef_ch_i <= '0;
            else if(vld_coef_in == '1)
                count_coef_ch_i <= count_coef_ch_i+1;
        end
    end
    // Счетчики коэффициентов по диаграммам
    always@(posedge clk_coef)
    begin
        if(rst_all_i == '1)
            count_coef_dn_i <= '0;
        else
        begin
            if(last_coef_in == '1 & vld_coef_in == '1)
                count_coef_dn_i <= 0;
            else if(count_coef_ch_i == N_chanals-1 & vld_coef_in == '1 & count_coef_dn_i == N_DN-1)
                count_coef_dn_i <= 0;
            else if(count_coef_ch_i == N_chanals-1 & vld_coef_in == '1)
                count_coef_dn_i <= count_coef_dn_i+1;
        end
    end    
    // Дешифратор
    always@(posedge clk_coef)
    begin
        if(rst_all_i == '1)    
            en_coef_i <= '0;
        else
        begin
            for(n_dec=0; n_dec<N_DN; n_dec++)
                if(count_coef_dn_i == n_dec & vld_coef_in == '1) 
                    en_coef_i[n_dec] <= '1;
                else
                    en_coef_i[n_dec] <= '0;
        end
    end
    // Задержка коэффициентов
    always@(posedge clk_coef)
    begin
        if(rst_all_i == '1)  
        begin    
            coefReIn_i <= '0;
            coefImIn_i <= '0;
        end
        else
        begin
            coefReIn_i <= coefReIn;
            coefImIn_i <= coefImIn;
        end
    end
    
    // Шина AXI_Lite
    always@(posedge s_axil_clk)
    begin
        if(s_axil_rst == '1)  
        begin       
            s_axil_awready_i <= '0;
            s_axil_arready_i <= '0;
            s_axil_bvalid_i  <= '0;
            s_axil_wready_i  <= '0;
            s_axil_bid_i     <= '0;
            s_axil_rid_i     <= '0;
            s_axil_rvalid_i  <= '0;
            reg_axil_rst_i   <= '0;
            reg_axil_far_i   <= '0;
            reg_axil_err_i   <= '0;
            stateAXI         <= s0;            
        end
        else
        begin
            case(stateAXI)
                // Начальное состояеие
                s0 : begin
                        // Выбор записи
                        if(s_axil_awvalid == '1 & s_axil_wvalid == '1) 
                        begin
                            stateAXI      <= sw;
                        end
                        // Выбор чтения
                        if(s_axil_arvalid == '1) 
                        begin
                            stateAXI      <= sr;
//                            reg_axil_id_i <= s_axil_arid;
                        end  
                        s_axil_awready_i <= '0;
                        s_axil_arready_i <= '0;
                        s_axil_bvalid_i  <= '0;
                        s_axil_wready_i  <= '0;
                        s_axil_bid_i     <= '0;
                        s_axil_rid_i     <= '0;
                        s_axil_rvalid_i  <= '0;
                        s_axil_rdata_i   <= '0;
                        reg_axil_err_i   <= '0;
                        reg_axil_rst_i   <= '0;
                    end
                // Режим записи
                sw : begin
                        // Выбор режима работы (Фарроу или нет)
                        if(s_axil_awaddr == (AddrAXI | 32'h00000000))                        
                        begin
//                            $display(AddrAXI | 32'h00000000);
                            stateAXI         <= sw1;
                            s_axil_bid_i     <= s_axil_awid;
                            s_axil_awready_i <= '1;
                            reg_axil_far_i   <= s_axil_wdata[0];
                            s_axil_wready_i  <= '1;
                        end
                        // Выбор регистра ошибок 
                        else if(s_axil_awaddr ==  (AddrAXI | 32'h00000001)) 
                        begin
                            stateAXI         <= sw2;
                            s_axil_bid_i     <= s_axil_awid;
                            s_axil_awready_i <= '1;
                            reg_axil_err_i   <= '1;
                            s_axil_wready_i  <= '1;
                        end 
                        // Выбор регистра перезагрузки 
                        else if(s_axil_awaddr ==  (AddrAXI | 32'h00000002)) 
                        begin
                            stateAXI         <= sw3;
                            s_axil_bid_i     <= s_axil_awid;
                            s_axil_awready_i <= '1;
                            reg_axil_rst_i   <= '1;
                            s_axil_wready_i  <= '1;
                        end
                        else
                        begin 
                            stateAXI         <= s0;
                        end                                                                           
                    end 
                // Подтверждаем запись режима 
                sw1 : begin
//                        stateAXI         <= s0;
                        s_axil_bvalid_i  <= '1;
                        s_axil_awready_i <= '0;
                        s_axil_wready_i  <= '0;
                        stateAXI         <= sw4;  
                    end   
                // Подтверждаем обнуление ошибок 
                sw2 : begin
                        if(reg_err_i == '0)
                        begin
                            stateAXI         <= sw4;
                            s_axil_bvalid_i  <= '1;
                            reg_axil_err_i   <= '0;
                        end
                        s_axil_wready_i  <= '0;
                        s_axil_awready_i <= '0; 
                    end    
                // Подтверждаем перезагрузку
                sw3 : begin
                        if(rst_i == '1)
                        begin
                            stateAXI         <= sw4;
                            s_axil_bvalid_i  <= '1;
                            reg_axil_rst_i   <= '0;
                        end
                        s_axil_wready_i  <= '0;
                        s_axil_awready_i <= '0; 
                    end     
                // Формирование bvalid
                sw4 : begin
                        if(s_axil_bready == '1)
                        begin
                            s_axil_bvalid_i  <= '0;
                            stateAXI         <= s0;
                        end
                    end                 
                // Режим чтения
                sr : begin
                        // Чтение режима работы (Фарроу или нет)
                        if(s_axil_araddr == (AddrAXI | 32'h00000000)) 
                        begin
                            stateAXI         <= sr1;
                            s_axil_rid_i     <= s_axil_arid;
                            s_axil_arready_i <= '1;
                            s_axil_rdata_i   <= reg_axil_far_i;
                            s_axil_rvalid_i  <= '1;
                        end
                        // Выбор регистра ошибок 
                        if(s_axil_araddr ==  (AddrAXI | 32'h00000001))
                        begin
                            stateAXI         <= sr2;
                            s_axil_rid_i     <= s_axil_arid;
                            s_axil_arready_i <= '1;
                            s_axil_rdata_i   <= reg_err_i;
                            s_axil_rvalid_i  <= '1;
                        end                         
                    end
                sr1 : begin
                        if(s_axil_rready  == '1)
                        begin
                            s_axil_rvalid_i  <= '0;
                            s_axil_rid_i     <= '0;
                            stateAXI         <= s0;
                        end
                    end
                sr2 : begin
                        if(s_axil_rready  == '1)
                        begin
                            s_axil_rvalid_i  <= '0;
                            s_axil_rid_i     <= '0;
                            stateAXI         <= s0;
                        end                        
                    end
//                default :  stateAXI <= s0;
            endcase
        end
    end
    
    // Регистр ошибок
    always@(posedge clk)
    begin
        if(rst_all_i == '1)  
        begin 
            reg_err_i <= '0;
        end
        else
        begin
            if(vld_coef_in == vld_data_in)
                reg_err_i <= 32'h00000001;
            else if(reg_axil_err_i == '1)
                reg_err_i <= '0;
        end    
    end
    
    // Регистр сброса
    always@(posedge clk)
    begin
        if(rst == '1)  
        begin 
            rst_i <= '0;
        end
        else
        begin            
            if(reg_axil_rst_i == '1)
                rst_i <= '1;
            else 
                rst_i <= '0;
        end    
    end
    
    assign rst_all_i = rst_i | rst;
     
    assign s_axil_awready = s_axil_awready_i;
    assign s_axil_wready  = s_axil_wready_i;
    assign s_axil_bvalid  = s_axil_bvalid_i;
    assign s_axil_bid     = s_axil_bid_i;               
    assign s_axil_arready = s_axil_arready_i;
    assign s_axil_rdata   = s_axil_rdata_i;
    assign s_axil_rresp   = '0;
    assign s_axil_rvalid  = s_axil_rvalid_i;
    assign s_axil_rid     = s_axil_rid_i;

endmodule
