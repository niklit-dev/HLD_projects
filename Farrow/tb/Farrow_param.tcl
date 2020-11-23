# --------------------------------------------------
# Разрядность входных данных фильтра
set inputDataWidth 16
set inputDataAxiWidth 16
# Разрядность выходных данных фильтра
set outputDataWidthGlobal 20
# Количество каналов
set numChannels 32
# Разрядность коэффициентов
set coefWidth 18
# Разрядность задержки
set delayDataWidth 18
# --------------------------------------------------
# Разрядность выходных данныx фильтров
# FIR0;
set outputDataFIR0 18;
# FIR1;
set outputDataFIR1 18;
# FIR2;
set outputDataFIR2 19;
# FIR3;
set outputDataFIR3 18;
# FIR4;
set outputDataFIR4 18;
# --------------------------------------------------
# Параметры блока сложения adder
# Разрядность входного числа А
set adder_inputDataA $outputDataWidthGlobal
# Разрядность входного числа B
set adder_inputDataB $outputDataWidthGlobal
# Разрядность выходного числа
set adder_outputData $outputDataWidthGlobal
# --------------------------------------------------
# Параметры умножителя mult_gen
# Разрядность входного числа А(разрядность задержки)
set mult_inputDataA $delayDataWidth
# Разрядность входного числа B(разрядность выходного тракта)
set mult_inputDataB $outputDataWidthGlobal
# Номер страшего бита выходного числа
set mult_outputDataHighBit [expr "$delayDataWidth + $outputDataWidthGlobal - 1"]
# Разрядность портов adder, используемого для округления
set adder_width_port [expr "$delayDataWidth + $outputDataWidthGlobal"]
