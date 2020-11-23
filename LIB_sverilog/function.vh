
`ifndef _function_vh_
`define _function_vh_

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

// Функция вычисления логарифма по основанию 2
function integer log2;
    input integer value;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

`endif