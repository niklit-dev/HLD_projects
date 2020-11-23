`timescale 1ns / 1ps

module FDN_core
	#(
		parameter wight_data_i   = 25,
		parameter wight_comp_a_i = 32, 		
		parameter wight_mult     = 49,
    	parameter wight_data_o   = 32,
    	parameter wight_comp_o_i = 56,
		parameter wight_comp_b_i = 24, 
		parameter wight_coef_i   = 24, 
		parameter N_chanals      = 32,
		parameter Round          = 1024,
		parameter shiftR         = 10
	)
	(
	    input clk_coef,
		input clk,
		input rst,
		input vld_data_in,
		input last_data_in,
		input [wight_data_i-1:0]dataReIn,
		input [wight_data_i-1:0]dataImIn,
		input vld_coef_in,
		input [wight_coef_i-1:0]coefReIn,
		input [wight_coef_i-1:0]coefImIn,
		output vld_data_out,
		output last_data_out,
		output [wight_data_o-1:0]dataReOut,
		output [wight_data_o-1:0]dataImOut 
	);
	
    // !!!!!!!!!!!!!! Подумать как сделать подругому !!!!!!!!!!!!!!!!!
    function integer log2;
        input integer value;
        begin
            value = value-1;
            for (log2=0; value>0; log2=log2+1)
                value = value>>1;
        end
    endfunction

//	// Вход A комплексного умножителя
//	wire [wight_comp_in(wight_data_i)*2-1:0]compInA_i;
//	// Вход B комплексного умножителя
//	wire [wight_comp_b_i*2-1:0]compInB_i;
//    // Выход комплексного умножителя	
//	wire [wight_comp_o_i-1:0]compOut_i;    	
//	wire compEnaOut_i;
//	// Входы памяти коэффициентов
//	wire [log2(N_chanals)-1:0]addr_coef;

    reg vld_data_out_i;
    reg [wight_mult+log2(N_chanals)-1:0]dataReOut_i;
	reg [wight_mult+log2(N_chanals)-1:0]dataImOut_i; 
    // ---- Комплексный умножитель ----
	// Вход A комплексного умножителя
	wire [wight_comp_a_i*2-1:0]compInA_i;
	// Задержанный вход A комплексного умножителя
	wire [wight_comp_a_i*2-1:0]compInAD_i;
	// Валидность входных данных
	wire compENA_in_i;
	// Сдвиговый регистр валидности
	reg [2:0]vld_data_inD_i;
	// Сдвиговый регистр данных
	reg [wight_comp_a_i*2-1:0]compInASh_i[2:0];
	// Вход B комплексного умножителя
	wire [wight_comp_b_i*2-1:0]compInB_i;
    // Выход комплексного умножителя	
	wire [wight_comp_o_i*2-1:0]compOut_i;    	
	wire compEnaOut_i;
	wire [wight_mult-1 : 0]compOut_Re_i;
	wire [wight_mult-1 : 0]compOut_Im_i;
	// ****
	// ---- Память коэффициентов ----
	// Вход адреса памяти коэффициентов
//	reg [log2(N_chanals)-1:0]addr_coef_i;
	reg [log2(N_chanals)-1:0]addr_coef_in_i;
	reg [log2(N_chanals)-1:0]addr_coef_out_i;
	// Вход данных
	reg [wight_coef_i*2-1:0]dataIn_coef_i;
	// Выход данных
	wire [wight_coef_i*2-1:0]dataOut_coef_i;
	// Валидность данных
	reg ena_coef_in_i;
	
	wire [wight_coef_i-1:0]ram_coefRe_i;
	wire [wight_coef_i-1:0]ram_coefIm_i;
	// ****
	// Счетчик коэффициентов
	reg [log2(N_chanals)-1:0]count_coef_i;
	// ---- Аккумулятор ----
	reg [log2(N_chanals)-1:0]count_coefD_i[2:0];
	reg vld_acc_i;
	wire [log2(N_chanals)-1:0]count_acc_i;
	reg [wight_mult+log2(N_chanals)-1 : 0]accRe_O_i;
	reg [wight_mult+log2(N_chanals)-1 : 0]accIm_O_i;
	reg [5:0]vld_accD_i;
	reg [15:0]rst_accD_i;
	wire vld_acc_in_i;
	wire rst_acc_i;
	wire vld_acc_in_all_i;
	reg vld_acc_in_B_i;
	// ---- Счетчик каналов ----
	reg [log2(N_chanals)-1:0]chan_coef_i;

    // Зануляем неиспользуемые входы A комплексного умножителя	
	generate
        if(wight_comp_a_i != wight_data_i)begin: A_Zeros
            assign compInA_i[             wight_comp_a_i-1 :                wight_data_i] = dataReIn[wight_data_i-1];
            assign compInA_i[           wight_comp_a_i*2-1 : wight_data_i+wight_comp_a_i] = dataReIn[wight_data_i-1];
        end
    endgenerate
	// Вход данных на комплексном умножителе А
    assign compInA_i[               wight_data_i-1 :              0] = dataReIn;
    assign compInA_i[wight_data_i+wight_comp_a_i-1 : wight_comp_a_i] = dataImIn;
    
    // Задержка входа данных на комплексном умножителе А
	always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            for(int i=0;i<3;i++) begin
                compInASh_i[i] <= '0;
            end
        end
        else
        begin 
            for(int i=1;i<3;i++)begin
                compInASh_i[i] <= compInASh_i[i-1];
            end
            compInASh_i[0] <= compInA_i;
        end
    end    
    // Вход данных на комплексный умножитель А
    assign compInAD_i = compInASh_i[2];     
            
	// Зануляем неиспользуемые входы B комплексного умножителя
	generate
        if(wight_comp_b_i != wight_coef_i)begin: B_Zeros
            assign compInB_i[             wight_comp_b_i-1 :                wight_coef_i] = ram_coefRe_i[wight_coef_i-1];//dataOut_coef_i[wight_coef_i-1];
            assign compInB_i[           wight_comp_b_i*2-1 : wight_coef_i+wight_comp_b_i] = ram_coefIm_i[wight_coef_i-1];//dataOut_coef_i[wight_coef_i*2-1];
        end
    endgenerate        
	// Вход коэффициентов на комплексном умножителе В
	assign compInB_i[               wight_coef_i-1 :              0] = ram_coefRe_i;//dataOut_coef_i[wight_coef_i-1   : 0]; 
	assign compInB_i[wight_coef_i+wight_comp_b_i-1 : wight_comp_b_i] = ram_coefIm_i;//dataOut_coef_i[wight_coef_i*2-1 : wight_coef_i];  
	
	// Задержка валидности данных
	always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            vld_data_inD_i <= '0;
        end
        else
        begin 
            for(int i=1;i<3;i++)begin
                vld_data_inD_i[i] <= vld_data_inD_i[i-1];
            end
            vld_data_inD_i[0] <= vld_data_in;
        end
    end  
    // Валидность данных на входе комплексного умножителя
    assign compENA_in_i = vld_data_inD_i[2];
	
    // Комплексный умножитель
	cmpy_0 cmpy_0_inst
    (
        .aclk(clk),               
        .s_axis_a_tvalid(compENA_in_i),   
        .s_axis_a_tdata(compInAD_i),     
        .s_axis_b_tvalid(compENA_in_i),    
        .s_axis_b_tdata(compInB_i),     
        .m_axis_dout_tvalid(compEnaOut_i), 
        .m_axis_dout_tdata(compOut_i)   
    );
    
    // Действительная часть на выходе комплексного умножителя
    assign compOut_Re_i = compOut_i[               wight_mult-1 :              0];
    assign compOut_Im_i = compOut_i[wight_mult+wight_comp_o_i-1 : wight_comp_o_i];
	
//	// Счетчик входных коэффыициентов
//	always @(posedge clk) 
//	begin
//        if(rst == '1)
//            count_coef_i <= '0;
//        else
//        begin
//            if((count_coef_i == N_chanals-1 & vld_coef_in == '1) | last_data_in == '1)
//                count_coef_i <= '0;
//            else if(vld_coef_in == '1)
//                count_coef_i <= count_coef_i + 1;
//        end
//    end
   
//	// Задержка входных коэффициентов
//    always @(posedge clk) 
//    begin
//        if(rst == '1)
//        begin
//            dataIn_coef_i <= '0;
//            ena_coef_in_i <= '0;
//        end
//        else
//        begin
//            dataIn_coef_i[wight_coef_i-1   :            0] <= coefReIn;
//            dataIn_coef_i[wight_coef_i*2-1 : wight_coef_i] <= coefImIn;
//            ena_coef_in_i <= vld_coef_in;
//        end
//    end   
    
//    // Мультиплексор адресов коэффициентов
//    always @(posedge clk) 
//    begin
//        if(rst == '1)
//            addr_coef_i <= '0;        
//        else
//        begin   
//            case(vld_coef_in) 
//                // Адрес чтения
//                1'b0 : addr_coef_i <= chan_coef_i;
//                // Адрес записи
//                1'b1 : addr_coef_i <= count_coef_i;
//                default : addr_coef_i <= '0;
//            endcase
//        end
//    end

//    // Память коэффициентов
//    blk_mem_gen_0 blk_mem_gen_0_inst
//    (
//        .clka (clk),
//        .ena  ('1), 
//        .wea  (ena_coef_in_i), 
//        .addra(addr_coef_i),
//        .dina (dataIn_coef_i), 
//        .douta(dataOut_coef_i)
//    );  

	// Счетчик входных коэффыициентов
	always @(posedge clk_coef) 
	begin
        if(rst == '1)
            count_coef_i <= '0;
        else
        begin
            if((count_coef_i == N_chanals-1 & vld_coef_in == '1) | last_data_in == '1)
                count_coef_i <= '0;
            else if(vld_coef_in == '1)
                count_coef_i <= count_coef_i + 1;
        end
    end    
    
    // Задержка адресов коэффициентов на запись
    always @(posedge clk_coef) 
    begin
        if(rst == '1)
            addr_coef_in_i <= '0;        
        else
        begin   
            // Адрес записи
            addr_coef_in_i <= count_coef_i;
        end
    end
    
    // Задержка адресов коэффициентов на чтение
    always @(posedge clk) 
    begin
        if(rst == '1)
            addr_coef_out_i <= '0;        
        else
        begin   
            // Адрес чтения
            addr_coef_out_i <= chan_coef_i;
        end
    end    
   
   	// Задержка входных коэффициентов
    always @(posedge clk_coef) 
    begin
        if(rst == '1)
        begin
            dataIn_coef_i <= '0;
            ena_coef_in_i <= '0;
        end
        else
        begin
            dataIn_coef_i[wight_coef_i-1   :            0] <= coefReIn;
            dataIn_coef_i[wight_coef_i*2-1 : wight_coef_i] <= coefImIn;
            ena_coef_in_i <= vld_coef_in;
        end
    end   
 
     
   // Память коэффициентов
   blk_mem_gen_0 blk_mem_gen_0_inst
   (
        .clka (clk_coef),      
        .ena  ('1),            
        .wea  (ena_coef_in_i), 
        .addra(addr_coef_in_i),
        .dina (dataIn_coef_i),
        .clkb (clk),          
        .enb  ('1),           
        .addrb(addr_coef_out_i),
        .doutb(dataOut_coef_i)
   );                           
	
//	// Память коэффициентов
//	dist_mem_gen_0 dist_mem_gen_0_inst
//    (
//        .a         (addr_coef_i),
//        .d         (dataIn_coef_i),           
//        .clk       (clk),         
//        .we        (ena_coef_in_i),          
//        .qspo_srst (rst),   
//        .qspo      (dataOut_coef_i)        
//    );
    
    // Действительная часть коэффициентов из памяти
    assign ram_coefRe_i = dataOut_coef_i[wight_coef_i-1   : 0];
    // Мнимая часть коэффициентов из памяти
	assign ram_coefIm_i = dataOut_coef_i[wight_coef_i*2-1 : wight_coef_i];
	
	// Аккумулятор сложения с накоплением
	// Действительная часть
	c_accum_0 c_accum_0_Re_inst
    (
        .B     (compOut_Re_i),    
        .CLK   (clk),     
        .CE    (compEnaOut_i),
        .SCLR  (rst | rst_acc_i),
        .BYPASS(vld_acc_in_all_i),   //vld_acc_in_i 
        .Q     (accRe_O_i)      
    );
	// Мнимая часть
	c_accum_0 c_accum_0_Im_inst
    (
        .B     (compOut_Im_i),     
        .CLK   (clk),     
        .CE    (compEnaOut_i),
        .SCLR  (rst | rst_acc_i),        
        .BYPASS(vld_acc_in_all_i),   //vld_acc_in_i      
        .Q     (accIm_O_i)     
    );	
    
    // Регистр vld_acc_in_i ожидания compEnaOut_i
    always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            vld_acc_in_B_i <= '0;
        end
        else
        begin 
            if(compEnaOut_i == '1)
                vld_acc_in_B_i <= '0;
            else if(vld_acc_in_i == '1)
                vld_acc_in_B_i <= '1;
        end
    end
       
    assign vld_acc_in_all_i = vld_acc_in_B_i | vld_acc_in_i;
    
    // Задержка валидности входных данных на аккумуляторе
    always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            vld_accD_i <= '0;
        end
        else
        begin 
            for(int i=1;i<6;i++)begin
                vld_accD_i[i] <= vld_accD_i[i-1];
            end
            vld_accD_i[0] <= vld_acc_i;
        end
    end  
    
    // Задержка сброса аккумулятора
    always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            rst_accD_i  <= '0;
        end
        else
        begin 
            for(int i=1;i<16;i++)begin
                rst_accD_i[i] <= rst_accD_i[i-1];
            end
            rst_accD_i[0] <= last_data_in;
        end
    end  
    
    // Вход аккумулятора
    assign vld_acc_in_i = vld_accD_i[5];
    assign rst_acc_i = rst_accD_i[15];
	
	// Разрешение загрузки данных в аккумулятор
    always @(posedge clk) 
    begin
        if(rst == '1 | rst_acc_i == '1)
        begin
            vld_acc_i   <= '0;
        end
        else
        begin
            // Если сложили все каналы
            if(count_acc_i == N_chanals-1 & compENA_in_i == '1)//compEnaOut_i
            begin
                vld_acc_i <= '1;
            end
            // Сложение каналов
            else if(compENA_in_i == '1)//compEnaOut_i
            begin
                vld_acc_i <= '0;
            end
            // Сброс vld
            else
                vld_acc_i <= '0;
        end
    end	
	
    // Задержка счетчика коэффициентов для аккумулятора
    always@(posedge clk)
    begin
        if(rst == '1) 
        begin
            for(int i=1;i<3;i++)begin
                count_coefD_i[i] <= '0;
            end
        end
        else
        begin 
            for(int i=1;i<3;i++)begin
                count_coefD_i[i] <= count_coefD_i[i-1];
            end
            count_coefD_i[0] <= chan_coef_i;
        end
    end  
	
	assign count_acc_i = count_coefD_i[2];
        	
    // Счетчик адресов на комплексный умножитель
    always @(posedge clk) 
    begin
        if(rst == '1)
        begin
            chan_coef_i <= '0;
        end
        else
        begin
            if(vld_data_in == '1 & chan_coef_i == N_chanals-1)
                chan_coef_i <= '0;
            else if(vld_data_in == '1)
                chan_coef_i <= chan_coef_i+1;
        end
    end
    
    // Округление  выходных данных
    always @(posedge clk) 
    begin
        if(rst == '1)
        begin
            vld_data_out_i <= '0;
            dataReOut_i    <= '0;
            dataImOut_i    <= '0;
        end
        else
        begin
            vld_data_out_i <= vld_acc_in_i;
            dataReOut_i    <= accRe_O_i + Round;
            dataImOut_i    <= accIm_O_i + Round;
        end
    end
    
    assign vld_data_out  = vld_data_out_i;
    assign dataReOut     = dataReOut_i[wight_mult+log2(N_chanals)-1 : shiftR];
    assign dataImOut     = dataImOut_i[wight_mult+log2(N_chanals)-1 : shiftR];
    assign last_data_out = rst_accD_i[11];
    
endmodule 
