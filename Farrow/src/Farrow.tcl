# Import files
add_files -norecurse $FARROW_PATH/src/FIRx.sv
add_files -norecurse $FARROW_PATH/src/mult_sum.sv
add_files -norecurse $FARROW_PATH/src/multiplier_del.sv
add_files -norecurse $FARROW_PATH/src/Farrow.sv

# Multiplayer
create_ip -name mult_gen -vendor xilinx.com -library ip -version 12.0 -module_name mult_gen_0
set_property -dict [list CONFIG.PortAWidth $outputDataWidthGlobal CONFIG.Multiplier_Construction {Use_Mults} CONFIG.OutputWidthHigh [expr "$outputDataWidthGlobal+$delayDataWidth-1"]] [get_ips mult_gen_0]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci]
catch { config_ip_cache -export [get_ips -all mult_gen_0] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci]

# Adder round
create_ip -name c_addsub -vendor xilinx.com -library ip -version 12.0 -module_name c_addsub_round
set_property -dict [list CONFIG.Component_Name {c_addsub_round} CONFIG.A_Width [expr "$outputDataWidthGlobal+$delayDataWidth-1"] CONFIG.B_Width [expr "$outputDataWidthGlobal+$delayDataWidth-1"] CONFIG.Out_Width [expr "$outputDataWidthGlobal+$delayDataWidth-1"] CONFIG.Latency {1} CONFIG.B_Value {0000000000000000000000000000000000000}] [get_ips c_addsub_round]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/c_addsub_round/c_addsub_round.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/c_addsub_round/c_addsub_round.xci]
catch { config_ip_cache -export [get_ips -all c_addsub_round] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/c_addsub_round/c_addsub_round.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/c_addsub_round/c_addsub_round.xci]

# Adder fir
create_ip -name c_addsub -vendor xilinx.com -library ip -version 12.0 -module_name c_addsub_fir
set_property -dict [list CONFIG.Component_Name {c_addsub_fir} CONFIG.A_Width $outputDataWidthGlobal CONFIG.B_Width $outputDataWidthGlobal CONFIG.Out_Width $outputDataWidthGlobal CONFIG.Latency {1} CONFIG.B_Value {00000000000000000000}] [get_ips c_addsub_fir]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/c_addsub_fir/c_addsub_fir.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/c_addsub_fir/c_addsub_fir.xci]
catch { config_ip_cache -export [get_ips -all c_addsub_fir] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/c_addsub_fir/c_addsub_fir.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/c_addsub_fir/c_addsub_fir.xci]

# Memory
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Write_Width_A $delayDataWidth CONFIG.Write_Depth_A {32} CONFIG.Read_Width_A $delayDataWidth CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Write_Width_B $delayDataWidth CONFIG.Read_Width_B $delayDataWidth CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips blk_mem_gen_0]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
catch { config_ip_cache -export [get_ips -all blk_mem_gen_0] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]

# FIR 0
create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_compiler_0
set_property -dict [list CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $PROJ_PATH/tb/FiltFarParam/Coef/FIR_coef0.coe CONFIG.Number_Channels $numChannels CONFIG.Sample_Frequency {12} CONFIG.Coefficient_Width $delayDataWidth CONFIG.Coefficient_Structure {Symmetric} CONFIG.Output_Rounding_Mode {Non_Symmetric_Rounding_Up} CONFIG.Output_Width $outputDataFIR0 CONFIG.M_DATA_Has_TREADY {false} CONFIG.Coefficient_Sets {1} CONFIG.Select_Pattern {All} CONFIG.Sample_Frequency {12} CONFIG.Clock_Frequency {384} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Data_Width $inputDataWidth CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig $halfRankFir CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required}] [get_ips fir_compiler_0]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_0/fir_compiler_0.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/fir_compiler_0/fir_compiler_0.xci]
catch { config_ip_cache -export [get_ips -all fir_compiler_0] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_0/fir_compiler_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/fir_compiler_0/fir_compiler_0.xci]

# FIR 1
create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_compiler_1
set_property -dict [list CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $PROJ_PATH/tb/FiltFarParam/Coef/FIR_coef1.coe CONFIG.Number_Channels $numChannels CONFIG.Sample_Frequency {12} CONFIG.Coefficient_Structure {Negative_Symmetric} CONFIG.Output_Rounding_Mode {Non_Symmetric_Rounding_Up} CONFIG.Output_Width $outputDataFIR1 CONFIG.Coefficient_Sets {1} CONFIG.Select_Pattern {All} CONFIG.Clock_Frequency {384} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Width $delayDataWidth CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Data_Width $inputDataWidth CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig $halfRankFir CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required}] [get_ips fir_compiler_1]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_1/fir_compiler_1.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/fir_compiler_1/fir_compiler_1.xci]
catch { config_ip_cache -export [get_ips -all fir_compiler_1] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_1/fir_compiler_1.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/fir_compiler_1/fir_compiler_1.xci]

#FIR 2
create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_compiler_2
set_property -dict [list CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $PROJ_PATH/tb/FiltFarParam/Coef/FIR_coef2.coe CONFIG.Number_Channels $numChannels CONFIG.Sample_Frequency {12} CONFIG.Coefficient_Width $delayDataWidth CONFIG.Coefficient_Structure {Symmetric} CONFIG.Output_Rounding_Mode {Non_Symmetric_Rounding_Up} CONFIG.Output_Width $outputDataFIR2 CONFIG.Coefficient_Sets {1} CONFIG.Select_Pattern {All} CONFIG.Clock_Frequency {384} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Coefficient_Structure {Symmetric} CONFIG.Data_Width $inputDataWidth CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig $halfRankFir CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required}] [get_ips fir_compiler_2]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_2/fir_compiler_2.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/fir_compiler_2/fir_compiler_2.xci]
catch { config_ip_cache -export [get_ips -all fir_compiler_2] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_2/fir_compiler_2.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/fir_compiler_2/fir_compiler_2.xci]

#FIR 3
create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_compiler_3
set_property -dict [list CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $PROJ_PATH/tb/FiltFarParam/Coef/FIR_coef3.coe CONFIG.Number_Channels $numChannels CONFIG.Sample_Frequency {12} CONFIG.Coefficient_Width $delayDataWidth CONFIG.Coefficient_Structure {Negative_Symmetric} CONFIG.Output_Rounding_Mode {Non_Symmetric_Rounding_Up} CONFIG.Output_Width $outputDataFIR3 CONFIG.Coefficient_Sets {1} CONFIG.Select_Pattern {All} CONFIG.Clock_Frequency {384} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Data_Width $inputDataWidth CONFIG.Output_Rounding_Mode {Non_Symmetric_Rounding_Up} CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig $halfRankFir CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required}] [get_ips fir_compiler_3]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_3/fir_compiler_3.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/fir_compiler_3/fir_compiler_3.xci]
catch { config_ip_cache -export [get_ips -all fir_compiler_3] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_3/fir_compiler_3.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/fir_compiler_3/fir_compiler_3.xci]

# FIR 4
create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_compiler_4
set_property -dict [list CONFIG.CoefficientSource {COE_File} CONFIG.Coefficient_File $PROJ_PATH/tb/FiltFarParam/Coef/FIR_coef4.coe CONFIG.Number_Channels $numChannels CONFIG.Sample_Frequency {12} CONFIG.Coefficient_Width $delayDataWidth CONFIG.Coefficient_Structure {Symmetric} CONFIG.Output_Rounding_Mode {Non_Symmetric_Rounding_Up} CONFIG.Output_Width $outputDataFIR4 CONFIG.Coefficient_Sets {1} CONFIG.Select_Pattern {All} CONFIG.Clock_Frequency {384} CONFIG.Coefficient_Sign {Signed} CONFIG.Quantization {Integer_Coefficients} CONFIG.Coefficient_Fractional_Bits {0} CONFIG.Data_Width $inputDataWidth CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} CONFIG.ColumnConfig $halfRankFir CONFIG.DATA_Has_TLAST {Not_Required} CONFIG.S_DATA_Has_TUSER {Not_Required} CONFIG.M_DATA_Has_TUSER {Not_Required}] [get_ips fir_compiler_4]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_4/fir_compiler_4.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/fir_compiler_4/fir_compiler_4.xci]
catch { config_ip_cache -export [get_ips -all fir_compiler_4] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/fir_compiler_4/fir_compiler_4.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/fir_compiler_4/fir_compiler_4.xci]









