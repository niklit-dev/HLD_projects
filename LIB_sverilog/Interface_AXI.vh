// Интерфейс мастера AXI_lite                                                                            
interface M_AXI_Lite #(                                                                                  
    parameter widht_addr = 32,                                                                           
    parameter widht_data = 32                                                                            
    )                                                                                                    
    (                                                                                                    
    input logic clk                                                                                      
    );                                                                                                   
//        // clk                                                                                         
//        logic                clk;                                                                      
    // write                                                                                             
    logic [widht_addr-1:0]   awaddr;                                                                     
    logic                  awvalid;                                                                      
    logic                  awready;                                                                      
    logic [widht_data-1:0]   wdata;                                                                      
    logic [widht_data/8-1:0] wstrb;                                                                      
    logic                  wvalid;                                                                       
    logic                  wready;                                                                       
    logic [1:0]            bresp;                                                                        
    logic                  bvalid;                                                                       
    logic                  bready;                                                                       
    // read                                                                                              
    logic [widht_addr-1:0]   araddr;                                                                     
    logic                  arvalid;                                                                      
    logic                  arready;                                                                      
    logic [widht_data-1:0]   rdata;                                                                      
    logic [ 1:0]           rresp;                                                                        
    logic                  rvalid;                                                                       
    logic                  rready;                                                                       
                                                                                                         
    initial                                                                                              
    begin                                                                                                
        awaddr  = '0;                                                                                    
        awvalid = '0;                                                                                    
        wdata   = '0;                                                                                    
        wvalid  = '0;                                                                                    
        wstrb    = '0;                                                                                   
        bready  = '0;                                                                                    
        bresp   = '0;                                                                                    
        araddr  = '0;                                                                                    
        arvalid = '0;                                                                                    
        rready  = '0;                                                                                    
    end                                                                                                  
                                                                                                         
    // Запись одного слова                                                                               
    task MasterWrite                                                                                     
        (                                                                                                
        input int addr,                                                                                  
        input int data                                                                                   
        );                                                                                               
        // Ждем тактовый сигнал                                                                          
        @(posedge clk); 
        #1;                                                                                 
        // Устанавливаем адрес                                                                           
        awaddr = addr;   // realtobits                                                                   
        // Валидность адреса                                                                             
        awvalid = '1;                                                                                    
        // Устанавливаем данные                                                                          
        wdata = data;                                                                                    
        // Валидность данных                                                                             
        wvalid = '1;                                                                                     
        wstrb   = '1;                                                                                    
        bready = '1; 
        // Ожидаем подтверждения (ready)   
        while(awvalid == '1 | wvalid == '1)
        begin
            if(awready == '1 & wready == '1)
            begin
                // Ждем тактовый сигнал                                                                          
                @(posedge clk);
                #1; 
                awvalid = '0;
                wvalid  = '0;                                                                                    
                wstrb    = '0;  
            end
            else if(awready == '1)
            begin
                // Ждем тактовый сигнал                                                                          
                @(posedge clk);
                #1; 
                awvalid = '0;           
            end
            else if(wready == '1)
            begin
                // Ждем тактовый сигнал                                                                          
                @(posedge clk); 
                #1;
                wvalid  = '0;                                                                                    
                wstrb    = '0;                 
            end
            else
            begin
                // Ждем тактовый сигнал                                                                          
                @(posedge clk);
                #1; 
            end
        end

//        // Ждем подтверждение приема данных                                                              
//        wait(awready == '1); 
//        // Ждем тактовый сигнал                                                                          
//        @(posedge clk); 
//        awvalid = '0;        
//        wait(wready == '1);                                                           
//        // Ждем тактовый сигнал                                                                          
//        @(posedge clk); 
//        #1;                                                                                 
//        //awvalid = '0;                                                                                    
//        wvalid  = '0;                                                                                    
//        wstrb    = '0;                                                                                   
        // Ждем подтверждение завершения транзакции                                                      
        wait(bvalid == '1);                                                                              
        // Ждем тактовый сигнал                                                                          
        @(posedge clk); 
        #1;                                                                                 
        //                                                                                               
        bready = '0;                                                                                     
    endtask;                                                                                             
                                                                                                         
    // Чтение одного слова                                                                               
    task MasterRead                                                                                      
        (                                                                                                
        input int addr,                                                                                  
        output int data                                                                                  
        );                                                                                               
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);    
        #1;                                                                              
        // Устанавливаем адрес                                                                           
        araddr = addr;   // realtobits                                                                   
        // Валидность адреса                                                                             
        arvalid = '1;                                                                                    
        // Готовность приема данных                                                                      
        rready = '1;
        @(posedge clk);    
        #1;                                                                                    
        // Ждем подтверждение приема адреса                                                              
        wait(arready == '1);                                                                             
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);
        #1;                                                                                  
        araddr = '0;                                                                                     
        arvalid  = '0;                                                                                   
        // Ждем данные                                                                                   
        wait(rvalid == '1);                                                                              
        // Сохраняем данные                                                                              
        data = rdata;                                                                                    
        // Ждем тактовый сигнал                                                                          
        @(posedge clk); 
        #1;                                                                                 
        //                                                                                               
        rready = '0; 
        
        @(posedge clk);                                                                                    
    endtask;    	
                                                                                                         
endinterface                                                                                           
                                                                                                         

// Интерфейс AXI4                                                                                        
interface M_AXI4 #(     
    parameter dempf = 1024,  
    parameter width_data_file = 64,                                                                         
    parameter widht_addr = 32,                                                                           
    parameter widht_data = 32                                                                            
    )                                                                                                    
    (                                                                                                    
    // Тактовый сигнал                                                                                   
    input logic clk                                                                                
    );                                                                                                   
    // write                                                                                             
    logic   [widht_addr-1:0] awaddr;                                                                     
    logic            [7:0] awlen;                                                                        
    logic                  awvalid;                                                                      
    logic                  awready; 
    logic            [1:0] awburst;
	
    logic   [widht_data-1:0] wdata;                                                                      
    logic [widht_data/8-1:0] wstrb;                                                                         
    logic                  wlast;                                                                        
    logic                  wvalid;                                                                       
    logic                  wready;
	
    logic            [1:0] bresp;                                                                        
    logic                  bvalid;                                                                       
    logic                  bready;                                                                       
    // read                                                                                              
    logic   [widht_addr-1:0] araddr;                                                                     
    logic            [7:0] arlen;                                                                        
    logic                  arvalid;                                                                      
    logic                  arready;  
    logic            [1:0] arburst;
	
    logic   [widht_data-1:0] rdata;                                                                      
    logic            [1:0] rresp;                                                                        
    logic                  rlast;                                                                        
    logic                  rvalid;                                                                       
    logic                  rready;                                                                       
                                                                                                         
    const integer Nlen = 256;                                                                            
    const integer Nbytes = widht_data/8;                                                                 
                                                                                                         
    initial                                                                                              
    begin                                                                                                
        awaddr  = '0;                                                                                    
        awvalid = '0; 
        awlen   = '0; 
        awburst = '0;                                                                                  
        wdata   = '0;                                                                                    
        wvalid  = '0;                                                                                    
        wstrb   = '0;                                                                                    
        bready  = '0;                                                                                    
        araddr  = '0;                                                                                    
        arvalid = '0;
        arlen   = '0; 
        arburst = '0;                                                                                   
        rready  = '0;                                                                                    
        wlast   = '0;                                                                                    
        rlast   = '0;                                                                                    
    end                                                                                                  
                                                                                                         
    // Запись массива данных                                                                             
    task MasterWrite(                                                                                    
        input int data[],                                                                                
        input int addr                                                                                   
        );                                                                                               
        real N_data;                                                                                     
        automatic int iter = 0;                                                                          
        automatic int addr_i = 0;                                                                        
        automatic int words = 0; 
        automatic int i=0;  
        automatic int j=0;                                                                       
        // определяем размер массива                                                                     
        N_data = $size(data);                                                                            

        // Цикл по количеству пакетов
        while(N_data > 0)                                                                    
        begin   
            // Вычислаем адрес чтения                                                                    
            addr_i = addr + i*Nlen*Nbytes;                                                               
            // Вычисляем количество слов в пакете                                                        
            if(N_data > Nlen)  
            begin                                                                 
                words = Nlen-1;  
                N_data = N_data - Nlen;
            end                                                                         
            else
            begin                                                                                         
                words = N_data-1;  
                N_data = 0;
            end                                                                   
            // Ждем тактовый сигнал                                                                      
            @(posedge clk); 
            #1;
            // Выставляем строб                                                                          
            wstrb = '1; 
            // Тип пакета INCR         
            awburst = 1;                                                                   
            // Готовность записи данных                                                                  
            bready = '1;                                                                                 
            // Запись адреса                                                                             
            awaddr = addr_i;                                                                             
            // Запись длины пакета                                                                       
            awlen = words;                                                                               
            // Валидность данных                                                                         
            awvalid = '1;                                                                                
            // Ждем подтверждение                                                                        
            wait(awready == '1);       
            // Устанавливаем даные            
            wdata = data[i*Nlen + j];  
            // Выставляем валидность                                                                     
            wvalid = '1;  
            // Записываем данные  
            while(j<=words)
            begin
                // Ждем тактовый сигнал           
                @(posedge clk);
                #1;
                // Запись адреса                                                                             
                awaddr = '0;                                                                             
                // Запись длины пакета                                                                       
                awlen = '0;                                                                               
                // Валидность данных                                                                         
                awvalid = '0;   
                // Выставляем валидность                                                                     
                wvalid = '1;  
                // Ждем готовность приема данных  
                if(wready == '1)
                begin        
                    // Устанавливаем last если последнее слово     
                    if(j == words)               
                        wlast = '1;    
                    // Устанавливаем даные            
                    wdata = data[i*Nlen + j];                
                    j++;                      
                end
            end
            // Ждем тактовый сигнал           
            @(posedge clk);
            #1; 
            j=0;
            i++;                                                                                          
            wlast   = '0;                                                                                
            wvalid = '0;                                                                                 
            wstrb    = '0;                                                                                
            wait(bvalid == '1);                                                                          
            // Ждем тактовый сигнал                                                                      
            @(posedge clk);                                                                              
            // Готовность записи данных                                                                                                                                                 
        end                                                                                              
    endtask;                                                                                             
                                                                                                         
    // Чтение массива данных                                                                             
    task MasterRead(                                                                                                                                                                         
        output int data[dempf],                                                                               
        input int addr                                                                                   
        );                                                                                               
        int N_data;                                                                                     
        automatic int iter = 0;                                                                          
        automatic int addr_i = 0;                                                                        
        automatic int words = 0; 
        automatic int i = 0; 
        automatic int j = 0;                                                                     
        // определяем размер массива                                                                     
        N_data = $size(data);                                                                            
        while(N_data > 0)                                                                    
        begin                                                                                           
            // Вычислаем адрес чтения                                                                    
            addr_i = addr + i*Nlen*Nbytes;                                                               
            // Вычисляем количество слов в пакете                                                        
            if(N_data > Nlen)  
            begin                                                                 
                words = Nlen-1;  
                N_data = N_data - Nlen;
            end                                                                         
            else
            begin                                                                                         
                words = N_data-1;  
                N_data = 0;
            end                                                               
            // Ждем тактовый сигнал                                                                      
            @(posedge clk);
            #1;
            // Тип пакета INCR         
            arburst = 1; 
            //
            bready = '1;                                                                                            
            // Запись адреса                                                                             
            araddr = addr_i;                                                                             
            // Запись длины пакета                                                                       
            arlen = words;                                                                             
            // Валидность данных                                                                         
            arvalid = '1;                                                                                
            // Ждем подтверждение                                                                        
            wait(arready == '1);                                                                         
            // Ждем тактовый сигнал                                                                      
            @(posedge clk);   
            #1; 
            // Тип пакета WRAP         
            arburst = 0;                                                                            
            // Валидность данных                                                                         
            arvalid = '0;                                                                                
            // Запись адреса                                                                             
            araddr = '0;                                                                                                                                                          
            // Ждем тактовый сигнал                                                                      
            @(posedge clk); 
            #1;                                                                             
            // Готовность к принятию данных                                                              
            rready = '1;     
            // Считываем данные  
            while(j<=words)
            begin
                // Ждем тактовый сигнал           
                @(posedge clk); 
                #1;
                // Ждем готовность приема данных  
                if(rvalid == '1)
                begin        
                    // Записываем данные                                                                     
                    data[i*Nlen + j] = rdata;            
                    j++;                      
                end
            end
            // Ждем тактовый сигнал           
            @(posedge clk); 
            #1;
            j=0;
            i++;                                                                                       
            rready = '0; 
            bready = '0;                                                                                 
        end                                                                                              
    endtask; 
	
///////////////////////////////////////////////////////////////////////////////////////////////////
// Таски для рабты через файл
///////////////////////////////////////////////////////////////////////////////////////////////////	 
    ////////////////////////////////////////////////////////////////////////////////
    // Функция записи в файл по 64 из потока по 512
    ////////////////////////////////////////////////////////////////////////////////
	task WriteToFileMAXI4
	   (
            input string File_Name,
            input int addr,
            input int len 
	    );
	
//		automatic longint unsigned wr_dat;
        automatic longint wr_dat;
		// Массив данных по 512 из потока 
	    automatic reg unsigned [511:0] arr512 [dempf/8];
		automatic reg unsigned[511:0] data512;
		automatic int len512 = 0;
		automatic int len_reg = 0;
		automatic int len_pck = 0;
        automatic int addr_pck = 0;
        automatic int bf_addr  = 0;
		integer File;                                                                         
        
        // Определяем длинну пакета слов по 512
		len512 = len/8;
		len_reg = len/8;
		
		// Определяем начальный адрес
        addr_pck = addr*Nbytes;                                                                                                                                    
		
        // Цикл передачи данных в несколько пакетов если размер превышает 255   
        while (len512 != 0)
        begin
                
            // Определяем длину очередного пакета
            // Внимание!!! Значение длины пакета передаём на один меньше. 256 передаётся как 255 и т.д!!! 
            if (len512 >= 256)
            begin
                len_pck = 256;
                len512 = len512 - 256;
            end   
            else 
            begin
                len_pck = len512;
                len512 = 0;   
            end          
            
            // Даём адрес и длинну для чтения
            araddr  = addr_pck;
            arlen   = len_pck-1; 
            arburst = '1;	
		    
		    // Даём валидность адреса
            @(posedge clk);
            #1;
            arvalid = '1;   

            // Опускаем валидность
            wait (arready == '1);
            @(posedge clk);
            #1;
            arvalid = '0;
            // Принимаем данные
            rready  = '1;

            // Цикл приёма слов по 512                                                
            for(int i = 0; i < len_pck; i++)                                                             
            begin 
                wait (rvalid == '1);
                 #1;                                                                                                                                                  
                // Принимаем данные                                                        
                arr512[bf_addr + i] = rdata;                                                 
                @(posedge clk);
                #1;                                                                      
            end 
            rready  = '0;
            
            // Определяем начальный адрес следующего пакета
            addr_pck = addr_pck + len_pck*Nbytes;
            // Орпделяем адрес массива на котором остановились
            bf_addr  = bf_addr + len_pck;  

        @(posedge clk);
        #1;  
		end
		
		// Открываем файл                                                                    
		File = $fopen(File_Name, "w"); 
		if(File == 0)
		begin
			$display("Файл", File_Name, "не открылся!");
			$finish; 
		end
		//Записываем в файл данные из массива
		for (int i = 0; i < len_reg; i++) 
		begin
		    data512 = arr512[i];   
		    for (int j = 0; j < 8; j++)
		    begin 
                wr_dat = data512[63:0];                      //wr_dat = data512[width_data_file-1:0]; 
                data512 = {'0, data512[511:64]};    	                    //data512 = {'0, data512[widht_data-1:width_data_file]}; 
                $fdisplay(File, "%H", wr_dat);
			end  
		end
		// Закрываем файл
		$fclose(File);
		
	endtask	
		
	///////////////////////////////////////////////////////////////////////////////	
	// Функция передачи данных из файла в поток(по 512) 
	///////////////////////////////////////////////////////////////////////////////	
	task ReadFromFileMAXI4 
	   (
	       input string File_Name,
	       input int addr,
	       input int len
	    );
		// 
		automatic longint unsigned rd_dat;
		automatic reg unsigned [511:0] arr512 [dempf/8]; 
		automatic reg unsigned [511:0] data512;
		automatic int j = 0;
		automatic int len512 = 0;
		automatic int len_pck = 0;
		automatic int addr_pck = 0;
		automatic int bf_addr  = 0;
		integer File;
		
		len512 = len/8;
		
		// Открываем файл и переписываем данные в массив                                                                    
		File = $fopen(File_Name, "r"); 
        if(File == 0)
        begin
            $display("Файл", File_Name, "не открылся!");
            $finish; 
        end
		// Переписываем данные из файла в массив
		for (int i = 0; i < len512; i++) 
		begin
		    for (int j = 0; j < 8; j++)
		    begin         	
                $fscanf(File, "%d\n", rd_dat);
                // Собираем слово 512 по 64
//                data512 = {data512[(widht_data-width_data_file)-1:0], data512[width_data_file-1:0]}; // Сдвиговый регистр
//                data512[width_data_file-1:0] = rd_dat;
                data512 = {data512[widht_data-1:widht_data-width_data_file], data512[widht_data-1:width_data_file]}; // Сдвиговый регистр
                data512[widht_data-1:widht_data-width_data_file] = rd_dat;
			end
			arr512[i] = data512;	
		end
		// Закрываем файл
        $fclose(File);
	
	    // Определяем начальный адрес
	    addr_pck = addr*Nbytes;
 
	    // Цикл передачи данных в несколько пакетов если размер превышает 255   
	    while (len512 != 0)
	    begin
	    
	        // Определяем длину очередного пакета
	        // Внимание!!! Значение длины пакета передаём на один меньше. 256 передаётся как 255 и т.д!!! 
	        if (len512 >= 256)
	        begin
	           len_pck = 256;
	           len512 = len512 - 256;
	        end   
	        else 
	        begin
	           len_pck = len512;
	           len512 = 0;   
	        end          
	           
            // Устанавливаем адрес
//            @(posedge clk);
//            #1;
            wstrb   = '1;        
            awburst = '1;                                                                                                                                    
            bready  = '1;                                                                                                                                                              
            awaddr  = addr_pck;                                                                                                                                                 
            awlen   = len_pck-1;    // Внимание!!! Значение длины пакета передаём на один меньше. 256 передаётся как 255 и т.д!!!                                                                                                                                                         
            
            // Даём валидность адреса
            @(posedge clk);
            #1;
            awvalid = '1;   

            // Опускаем валидность
            wait (awready == '1);
            @(posedge clk);
            #1;
            awvalid = '0;
            
            
            // Отсылаем данные
            //wait (wready == '1)
            @(posedge clk);
            #1;
                // Посылаем данные в поток
                for (int i = 0; i < len_pck; i++)          
                begin
                    if (wready == '0)
                        wvalid = '0;
                    else
                        wvalid = '1;      
                    //assign wvalid = wready ? 1 : 0;     
                    
                    wait (wready == '1);
                    wvalid = '1;    
                    wdata = arr512[bf_addr + i];  /////Исправить
                    if (i == len_pck-1)
                        wlast = '1;
                    @(posedge clk);     
                    #1;
                end 	             
                                                                                                  
            wlast    = '0;                                                                                
            wvalid   = '0;                                                                                 
            wstrb    = '0;
            // Определяем начальный адрес следующего пакета
            addr_pck = addr_pck + len_pck*Nbytes;
            // Орпделяем адрес массива на котором остановились
            bf_addr  = bf_addr + len_pck;  
                                                                                           
            wait(bvalid == '1);                                                                                                                                             
            @(posedge clk);
            #1;
            bready  = '0;
            @(posedge clk);
            #1;
	   end	
	endtask
	
	///////////////////////////////////////////////////////////////////////////////	
    // Функция передачи данных из двух файлов в поток(по 512) 
    ///////////////////////////////////////////////////////////////////////////////    
    task ReadFrom2FileMAXI4 
       (
           input string File_Name_L,
           input string File_Name_H,
           input int addr,
           input int len
        );
        // 
        automatic longint unsigned rd_dat_L;
        automatic longint unsigned rd_dat_H;
        automatic reg unsigned [511:0] arr512 [dempf/8]; 
        automatic reg unsigned [511:0] data512;
        automatic reg unsigned [31:0] data32_L [dempf];
        automatic reg unsigned [31:0] data32_H [dempf];
        automatic reg unsigned [63:0] data64 [dempf];
        automatic int k = 0;
        automatic int len512 = 0;
        automatic int len64 = 0;
        automatic int len_pck = 0;
        automatic int addr_pck = 0;
        automatic int bf_addr  = 0;
        integer File_L;
        integer File_H;
        
        len512 = len/8;
        len64  = len;
        

        // Открываем файл с младшейс частью и переписываем в массив                                                                   
        File_L = $fopen(File_Name_L, "r"); 
        if(File_L == 0)
        begin
            $display("Файл", File_Name_L, "не открылся!");
            $finish; 
        end
        // Открываем файл со старшей частью и переписываем в массив 
        File_H = $fopen(File_Name_H, "r"); 
        if(File_H == 0)
        begin
            $display("Файл", File_Name_H, "не открылся!");
            $finish; 
        end
        // Читаем данные из файла, скливаем и записывем в массив по 64
        for (int i = 0; i < len64; i++) 
        begin
             $fscanf(File_L, "%d\n", rd_dat_L);
             $fscanf(File_H, "%d\n", rd_dat_H);
             data32_L[i] = rd_dat_L;
             data32_H[i] = rd_dat_H;
             data64[i] = {data32_H[i] , data32_L[i]};     
        end
        // Закрываем файл
        $fclose(File_L);
        $fclose(File_H);
        
        // Склеиваем данные в слова по 512.
        for (int i = 0; i < len512; i++) 
        begin
            for (int j = 0; j < 8; j++)
            begin             
                k++;
                // Собираем слово 512 по 64
                data512 = {data512[widht_data-1:widht_data-width_data_file], data512[widht_data-1:width_data_file]}; // Сдвиговый регистр
                data512[widht_data-1:widht_data-width_data_file] = data64[k];
            end
            arr512[i] = data512;    
        end
         
    
        // Определяем начальный адрес
        addr_pck = addr*Nbytes;
 
        // Цикл передачи данных в несколько пакетов если размер превышает 255   
        while (len512 != 0)
        begin
        
            // Определяем длину очередного пакета
            // Внимание!!! Значение длины пакета передаём на один меньше. 256 передаётся как 255 и т.д!!! 
            if (len512 >= 256)
            begin
               len_pck = 256;
               len512 = len512 - 256;
            end   
            else 
            begin
               len_pck = len512;
               len512 = 0;   
            end          
               
            // Устанавливаем адрес
//            @(posedge clk);
//            #1;
            wstrb   = '1;        
            awburst = '1;                                                                                                                                    
            bready  = '1;                                                                                                                                                              
            awaddr  = addr_pck;                                                                                                                                                 
            awlen   = len_pck-1;    // Внимание!!! Значение длины пакета передаём на один меньше. 256 передаётся как 255 и т.д!!!                                                                                                                                                         
            
            // Даём валидность адреса
            @(posedge clk);
            #1;
            awvalid = '1;   

            // Опускаем валидность
            wait (awready == '1);
            @(posedge clk);
            #1;
            awvalid = '0;
            
            
            // Отсылаем данные
            //wait (wready == '1)
            @(posedge clk);
            #1;
                // Посылаем данные в поток
                for (int i = 0; i < len_pck; i++)          
                begin
                    if (wready == '0)
                        wvalid = '0;
                    else
                        wvalid = '1;      
                    //assign wvalid = wready ? 1 : 0;     
                    
                    wait (wready == '1);
                    wvalid = '1;    
                    wdata = arr512[bf_addr + i];  /////Исправить
                    if (i == len_pck-1)
                        wlast = '1;
                    @(posedge clk);     
                    #1;
                end                  
                                                                                                  
            wlast    = '0;                                                                                
            wvalid   = '0;                                                                                 
            wstrb    = '0;
            // Определяем начальный адрес следующего пакета
            addr_pck = addr_pck + len_pck*Nbytes;
            // Орпделяем адрес массива на котором остановились
            bf_addr  = bf_addr + len_pck;  
                                                                                           
            wait(bvalid == '1);                                                                                                                                             
            @(posedge clk);
            #1;
            bready  = '0;
            @(posedge clk);
            #1;
       end    
    endtask    
	
			
endinterface;	
	
//////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	         
// Интерфейс мастера AXI_Stream                                                                          
interface M_AXI_Stream #(                                                                                
    parameter widht_data = 32                                                                            
    )                                                                                                    
    (                                                                                                    
    // Тактовый сигнал                                                                                   
    input logic clk                                                                                      
    );                                                                                                   
    //                                                                                                   
    logic                      tvalid;                                                                   
    logic                      tready;                                                                   
    logic   [widht_data-1 : 0] tdata;                                                                    
    logic [widht_data/8-1 : 0] tstrb;                                                                    
    logic [widht_data/8-1 : 0] tkeep;                                                                    
    logic                      tlast;                                                                    
                                                                                                         
    // Начальные настройки                                                                               
    initial                                                                                              
    begin                                                                                                
       tvalid = '0;                                                                                      
       tdata  = '0;                                                                                      
       tstrb  = '0;                                                                                      
       tkeep  = '0;                                                                                      
       tlast  = '0;                                                                                      
    end                                                                                                  
                                                                                                         
    // Запись данных в поток                                                                             
    task MasterWrite(                                                                                    
        input int dataIn[]                                                                               
        );                                                                                               
        int N_data;  
        automatic int i=0;   
//        $display("MasterWrite", $time);                                                                                 
        // определяем размер массива                                                                     
        N_data = $size(dataIn);                                                                          
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);      
        // Записываем данные  
        while(i<N_data)
        begin
            // Ждем тактовый сигнал           
            @(posedge clk); 
            #1;
            // Ждем готовность приема данных  
            if(tready == '1)
            begin      
                // Устанавливаем last если последнее слово    
                if(i == N_data-1)                 
                    tlast = '1;    
                // Устанавливаем даные            
                 tdata = dataIn[i];                
                 // Устанавливаем stbb и keep      
                 tstrb = '1;                       
                 tkeep = '1;                       
                 // Устанавливаем валидность данных
                 tvalid = '1;  
                 i++;                      
            end
        end
        @(posedge clk);                                                                                                            
        tvalid = '0;                                                                                     
        tdata  = '0;                                                                                     
        tstrb  = '0;                                                                                     
        tkeep  = '0;                                                                                     
        tlast  = '0;                                                                                     
    endtask;                                                                                             

    // Запись данных в поток                                                                             
    task MasterWriteFromFile(                                                                                    
        string File_Name,
        integer N_data,
        integer delay = 0                                                                            
        );                                                                                               
        integer File; 
        integer data; 
        integer read_data;
        string line;
        integer i=0;                                                                                  
        // Открываем файл                                                                     
        File = $fopen(File_Name, "r"); 
        if(File == 0)
        begin
            $display("Файл ", File_Name, " не открылся!");
            $finish;
        end
        // Читаем первую строку  
        $fgets(line, File);
        data = line.atoi();
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);  
        #1;    
        // Записываем данные  
        while(i < N_data-1)    //!$feof(File))
        begin              
            // Ждем тактовый сигнал           
            @(posedge clk); 
            #1;
            // Ждем готовность приема данных  
            if(tready == '1)
            begin      
                // Устанавливаем даные            
                 tdata = data; 
                 // Устанавливаем stbb и keep      
                 tstrb = '1;                       
                 tkeep = '1;                       
                 // Устанавливаем валидность данных
                 tvalid = '1;  
                 // Читаем строку  
                 $fgets(line, File);
                 data = line.atoi(); 
                 i++;                
            end
            // Задержка между словами
            for(int del = 0; del < delay; del++)   
            begin      
                @(posedge clk); 
                #1;
                tvalid = '0;
            end                                   
        end
        @(posedge clk);
        #1;
        i=0;
        // Устанавливаем last если последнее слово
        tlast = '1; 
        // Устанавливаем даные            
        tdata = data;       
//        tdata = read_data; 
        // Устанавливаем stbb и keep      
        tstrb = '1;                       
        tkeep = '1;                       
        // Устанавливаем валидность данных
        tvalid = '1;            
        @(posedge clk);
        #1;
        // Закрываем файл
        $fclose(File); 
        $display("Файл ", File_Name, " закрыт"); //, $time);                                                                                                          
        tvalid = '0;                                                                                     
        tdata  = '0;                                                                                     
        tstrb  = '0;                                                                                     
        tkeep  = '0;                                                                                     
        tlast  = '0;  
//        $display("Файл ", File_Name, " задача завершена", $time);                                                                                    
    endtask; 
                                                                                                         
endinterface;                                                                                            
                                                                                                         
// Интерфейс слэйва AXI_Stream                                                                           
interface S_AXI_Stream #(                                                                                
    parameter widht_data = 32,                                                                           
    parameter dempf = 128                                                                                
    )                                                                                                    
    (                                                                                                    
    // Тактовый сигнал                                                                                   
    input logic clk                                                                                      
    );                                                                                                   
    //                                                                                                   
    logic                      tvalid;                                                                   
    logic                      tready;                                                                   
    logic   [widht_data-1 : 0] tdata;                                                                    
    logic [widht_data/8-1 : 0] tstrb;                                                                    
    logic [widht_data/8-1 : 0] tkeep;                                                                    
    logic                      tlast;                                                                    
                                                                                                         
    // Начальные настройки                                                                               
    initial                                                                                              
    begin                                                                                                
        tready = '0;                                                                                     
    end                                                                                                  
                                                                                                         
    // Чтение данных из потока                                                                           
    task MasterRead(                                                                                     
        output int dataOut[dempf]                                                                        
        );                                                                                               
        int N_data; 
        automatic int i=0;                                                                                     
        // определяем размер массива                                                                     
        N_data = $size(dataOut);                                                                         
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);                                                                                  
        tready = '1;
        
        // Записываем данные  
        while(i<N_data)
        begin
            // Ждем тактовый сигнал           
            @(posedge clk); 
            #1;
            // Ждем готовность приема данных  
            if(tvalid == '1)
            begin      
                // Устанавливаем даные                                                                       
                dataOut[i] = tdata;                
                i++;                      
            end
        end        
        // Ждем тактовый сигнал           
        @(posedge clk); 
        #1;                                                                                                   
        tready = '0;                                                                                     
    endtask;    
    
    // Чтение данных из потока в файл
    task MasterReadToFile(                                                                                     
        string File_Name                                                                    
        );                                                                                               
        integer File;
        integer i=0; 
        integer dataOut; 
//        integer dataOut[dempf];                                                                                 
        // Открываем файл                                                                     
        File = $fopen(File_Name, "w"); 
        if(File == 0)
        begin
            $display("Файл", File_Name, "не открылся!");
            $finish;
        end                                                                              
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);                                                                                  
        tready = '1;
        // Записываем данные  
        while(1)
        begin
            // Ждем тактовый сигнал           
            @(posedge clk); 
            #1;
            // Ждем готовность приема данных  
            if(tvalid == '1)
            begin      
                // Устанавливаем даные                                                                       
                dataOut = tdata; 
                // Записываем значение в файл  
                $fdisplay(File, "%d", dataOut);                           
                if(tlast == '1)  
                    break;                   
            end
        end        
        // Ждем тактовый сигнал           
        @(posedge clk); 
        #1;           
        // Закрываем файл
        $fclose(File);                                                                                                
        tready = '0;
        @(posedge clk);                                                                                     
    endtask;   
    
        // Чтение данных из потока в файл определенное количество
    task MasterReadToFileL(                                                                                     
        string File_Name,
        integer N_data                                                                       
        );                                                                                               
        integer File;
        integer i=0; 
        automatic reg signed [widht_data-1 : 0] dataOut;                                                                                
        // Открываем файл                                                                     
        File = $fopen(File_Name, "w"); 
        if(File == 0)
        begin
            $display("Файл", File_Name, "не открылся!");
            $finish;
        end     
        $display("Файл", File_Name, " открылся!");                                                                         
        // Ждем тактовый сигнал                                                                          
        @(posedge clk);                                                                                  
        tready = '1;
        // Записываем данные  
        while(i<N_data)
        begin
            // Ждем тактовый сигнал           
            @(posedge clk); 
            #1;
            // Ждем готовность приема данных  
            if(tvalid == '1)
            begin     
                dataOut = tdata;
//                $display("%0d", dataOut);
                // Устанавливаем даные                                                                       
                // Записываем значение в файл  
                $fdisplay(File, "%0d", dataOut);                            
                i++;                   
            end
        end        
        // Ждем тактовый сигнал           
        @(posedge clk); 
        #1; 
        i=0;        
        // Закрываем файл
        $fclose(File); 
        $display("Файл", File_Name, " закрылся!");                                                                                                   
        tready = '0;                                                                                     
    endtask;                                                                                         
                                                                                                         
endinterface;                                                                                            
                                                                                                         
// Интерфейс AXI4 slave                                                                                  
interface S_AXI4 #(                                                                                      
    parameter      depth = 1024,                                                                       
    parameter widht_addr = 32,                                                                           
    parameter wight_data = 32                                                                            
    )                                                                                                    
    (                                                                                                    
    // Тактовый сигнал                                                                                   
    input logic clk                                                                                      
    );                                                                                                   
    // write                                                                                             
    logic [widht_addr-1:0] awaddr;                                                                       
    logic            [7:0] awlen;                                                                        
    logic                  awvalid;                                                                      
    logic                  awready; 
    logic            [3:0] awid;
	
    logic [wight_data-1:0] wdata;                                                                        
    logic [wight_data/8-1:0] wstrb;                                                                        
    logic                  wlast;                                                                        
    logic                  wvalid;                                                                       
    logic                  wready; 
	
    logic            [3:0] bid;                                                                      
    logic            [1:0] bresp;                                                                        
    logic                  bvalid;                                                                       
    logic                  bready;  
	
    // read                                                                                              
    logic [widht_addr-1:0] araddr;                                                                       
    logic            [7:0] arlen;                                                                        
    logic                  arvalid;                                                                      
    logic                  arready; 
    logic            [3:0] arid;  
	
    logic [wight_data-1:0] rdata;                                                                        
    logic            [1:0] rresp;                                                                        
    logic                  rlast;                                                                        
    logic                  rvalid;                                                                       
    logic                  rready;
    logic            [3:0] rid;                                                                       
                                                                                                         
    const integer Nlen = 256;                                                                            
    const integer Nbytes = wight_data/8;                                                                 
                                                                                                         
    initial                                                                                              
    begin                                                                                                
        awready = '0;                                                                                    
        wready  = '0;                                                                                    
        bvalid  = '0;                                                                                    
        bresp   = '0;                                                                                    
        arready = '0;                                                                                    
        rdata   = '0;                                                                                    
        rresp   = '0;                                                                                    
        rlast   = '0;                                                                                    
        rvalid  = '0;
        bid     = '0;
        rid     = '0;
        wstrb   = '1;                                                                                    
    end                                                                                                  
                                                                                                         
   task Singl_RAM_S_AXI4
        (                                                                               
        //input int data[]                                                                                 
        ); 
        static reg [(wight_data-1):0] data[depth/8];                                                                                            
        automatic int addr_i = 0;                                                                        
        automatic int len_i = 0;                                                                                                                                                                          
        // Бесконечный цикл                                                                              
        while(1)                                                                                         
        begin                                                                                            
            // Ждем тактовый сигнал                                                                      
            @(posedge clk);
            #1;                                                                              
            // Начальные настройки                                                                       
            awready = '1;                                                                                
            //wready  = '1;   //!                                                                             
            arready = '1;                                                                                
            bresp   = '0;                                                                                
            bvalid  = '0;                                                                                
            // Если началась запись                                                                      
            if(awvalid == '1)                                                                            
            begin    
                // Идентификатор запроса записи     
                bid = awid;                                                                              
                // Запрещаем чтение данных                                                               
                arready = '0;                                                                            
                addr_i = awaddr;                                                                         
                len_i  = awlen;   
//                awready = '0;    
                $display("Чтение %d слов", awlen,$time);                                                                      
                // Ждем тактовый сигнал                                                                  
                @(posedge clk); 
                #1;
                wready  = '1;  //!          
                awready = '0;                                                                                                                                       
                // Запускаем цикл записи данных в память                                                 
                for(int i = 0; i<=len_i; i++)//len_i                                                           
                begin                                                                                    
                    // Ждем данных                                                                       
                    wait(wvalid == '1 & bready == '1);
                    #1
                     
                   // if(i == 253)//len_i-1)
                     //   bvalid = '1;                                                                 
                    // Записываем данные в память                                                        
                    data[addr_i/Nbytes + i] = wdata;
                    $display("index %d, wdata: %d, addr %d", i, wdata, (addr_i/Nbytes + i) );                                                  
                    // Ждем тактовый сигнал                                                              
                    @(posedge clk); 
                    #1;                                                                                              
                end
                
//                @(posedge clk);
//                #1; 
                
                bvalid = '1; //!
                                                                                                                                                                  
                // Ждем тактовый сигнал                                                                  
                @(posedge clk); 
                #1;  
                $display("Прочитано",$time);                                                                         
                bvalid  = '0; 
                bid     = '0;                                                                           
                arready = '1;                                                                            
                awready = '1;
                wready  = '0;  //!                                                                          
            end                                                                                          
                                                                                                         
            // Если началось чтение                                                                      
            if(arvalid == '1)                                                                            
            begin   
                // Идентификатор запроса чтения  
                rid = arid;                                                                                    
                // Запрещаем чтение данных                                                               
                awready = '0;                                                                            
                addr_i = araddr;                                                                         
                len_i  = arlen;                                                                                                                                               
                // Ждем тактовый сигнал                                                                  
                @(posedge clk); 
                #1;                                                                         
                arready = '0;                                                                            
                rvalid = '1;                                                                       
                // Запускаем цикл чтения данных из памяти                                                
                for(int i = 0; i<=len_i; ++i)  // <= i++                                                         
                begin                                                                                    
                                                                                 
                    // Ждем данных                                                                       
                    wait(rready == '1);                                                                  
                    // Считываем данные из памяти                                                        
                    rdata = data[addr_i/Nbytes + i];
                    $display("rd_DDR %d, data: %d, addr %d", i, rdata, addr_i ); 
                    // Если последнее слово                                                              
                    if(i == len_i)     // if(i == len_i)                                                                  
                    begin                                                                            
                        rlast = '1;                                                                  
                    end 
                    // Ждем тактовый сигнал                                                              
                    @(posedge clk); 
                    #1;                                                            
                end                                                                                      
                rvalid = '0;                                                                             
                rlast  = '0;  
                rid    = '0;                                                                            
                arready = '1;                                                                            
            end                                                                                          
        end                                                                                                        
    endtask;	
	
		
	// Чтение из файла и передача в поток
	task ReadFromFileSAXI4(string File_Name );
		static longint unsigned data[depth]; 
		automatic longint unsigned rd_dat;
        integer File; 
		automatic int addr_i = 0;                                                                        
        automatic int len_i = 0;
		// Инициализация                                                                       
		arready = '0;                                                                                                                                                                                                                                     
		bresp   = '0;                                                                                
		rvalid  = '0; 
		
		// Открываем файл и переписываем данные в массив                                                                    
		File = $fopen(File_Name, "r"); 
        if(File == 0)
        begin
            $display("Файл", File_Name, "не открылся!");
            $finish; 
        end
		// Переписываем данные
		for (int i = 0; i < depth; i++)
		begin	
            $fscanf(File, "%d\n", rd_dat); 
			//$display("integer %d, %d",rd_dat, i);
			data[i] = rd_dat; 
		end
		// Закрываем файл
        $fclose(File); 
		
		
		@(posedge clk); // Следующий такт         
		#1;                                                                                                                                          
		arready = '1;   // Готовность принимать адрес                                                                                                                                                                                                                                     

		while(1)                                                                                         
        begin
			// Если пришёл запрос на чтение
			if(arvalid == '1)                                                                            
			begin                                                              
				awready = '0;    // Запрещаем чтение данных                                                                            
				addr_i = araddr; // Фиксируем адрес                                                                        
				len_i  = arlen;  // Фиксируем длину
				@(posedge clk); #1;                                                                        
                arready = '0;                                                                             
                rvalid = '1;                                                                        
                // Запускаем цикл чтения данных из массива памяти                                                
                for(int i = 0; i<=len_i; ++i)                                                            
                begin                                                                                                                                             
                    // Ждем данных                                                                       
                    wait(rready == '1);                                                                  
                    // Считываем данные из памяти                                                        
                    rdata = data[addr_i/Nbytes + i]; 
                    // Если последнее слово                                                              
                    if(i == len_i)                                                                       
                    begin                                                                            
                        rlast = '1;                                                                  
                    end 
                    
                    // Ждем тактовый сигнал                                                              
                    @(posedge clk); #1;                                                          
                end
				// Заканчиваем чтение	
				rvalid = '0;                                                                             
				rlast  = '0;
				arready = '1;                                                                               
				awready = '1;  
				
			end	
			@(posedge clk);
			#1;
		end		
	endtask
	
endinterface;                                                        
