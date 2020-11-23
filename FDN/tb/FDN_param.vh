// Директория src
parameter NameDir = ".";
// Длина теста
parameter FDN_N_test         = 24;
// Количество диаграмм
parameter FDN_N_DN           = 18;
// Количество каналов
parameter FDN_N_chanals      = 32;
// Адрес AXI_Lite
parameter FDN_AddrAXI        = 4026531840;
// Ширина входных данных
parameter FDN_wight_data_i   = 20;
// Разрядность коэффициентов
parameter FDN_wight_coef_i   = 18;
// Разрядность входа данных комплексного умножителя
parameter FDN_wight_comp_a_i = 24;
// Разрядность входа коэффициентов комплексного умножителя
parameter FDN_wight_comp_b_i = 24;
// Разрядность данных на выходе комплексного умножителя(по правилам математики)
parameter FDN_wight_mult     = 39;
// Разрядность данных на выходе комплексного умножителя(по факту)
parameter FDN_wight_comp_o_i = 40;
// Разрядность данных на выходе
parameter FDN_wight_data_o   = 21;
// Сдвиг данных
parameter FDN_shiftR         = 23;
// Коэффициент округления
parameter FDN_Round          = 4194304;
