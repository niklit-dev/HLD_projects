// Директория src
parameter NameDir = ".";
// Разрядность входного потока данных
parameter wight_data_in = 16;
// Разрядность выходного потока данных
parameter width_data_out = 20;
// Разрядность задержки
parameter wight_delay = 18;
// Порядок полинома
parameter polinom = 5;
// Cдвиг данных после умножения на задержку
parameter [5*32-1:0]shift_mul = {32'd17,32'd17,32'd17,32'd17,32'd17};        
// Константа для сложения (=1 в разряде старшего бита выходного числа)(Коэффициент округления после умножения на задержку)
parameter [5*32-1:0]round_mul = {32'd65536,32'd65536,32'd65536,32'd65536,32'd65536};
// Разрядность данных FIR кратная 1-му байту
parameter wigth_fir_all = 24;    
// Фактическая разрядность данных FIR
parameter wigth_fir_0    = 18; // Разрядность на выходе 0-го fir
parameter wigth_fir_1    = 18; // Разрядность на выходе 1-го fir
parameter wigth_fir_2    = 19; // Разрядность на выходе 2-го fir
parameter wigth_fir_3    = 18; // Разрядность на выходе 3-го fir
parameter wigth_fir_4    = 18; // Разрядность на выходе 4-го fir
// Задержка на КИХ ффилтре
parameter latency_fir = 31;
// Количество выходов(ДН)
parameter N_DN = 18;
// Количество каналов
parameter N_chanals = 32;
// Длина теста
parameter N_test = 24;


