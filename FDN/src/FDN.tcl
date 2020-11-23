# Import files
add_files -norecurse $FDN_PATH/src/FDN_core.sv
add_files -norecurse $FDN_PATH/src/FDN_core_x.sv

# Complex Multiplayer
create_ip -name cmpy -vendor xilinx.com -library ip -version 6.0 -module_name cmpy_0
set_property -dict [list CONFIG.APortWidth $FDN_wight_data_i CONFIG.BPortWidth $FDN_wight_coef_i CONFIG.OptimizeGoal {Performance} CONFIG.OutputWidth $FDN_wight_mult CONFIG.LatencyConfig {Manual} CONFIG.MinimumLatency {6}] [get_ips cmpy_0]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/cmpy_0/cmpy_0.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/cmpy_0/cmpy_0.xci]
catch { config_ip_cache -export [get_ips -all cmpy_0] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/cmpy_0/cmpy_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/cmpy_0/cmpy_0.xci]
#launch_runs -jobs 4 cmpy_0_synth_1
#wait_on_run cmpy_0_synth_1

## Distributed RAM
#create_ip -name dist_mem_gen -vendor xilinx.com -library ip -version 8.0 -module_name dist_mem_gen_0
#set_property -dict [list CONFIG.depth $FDN_N_chanals CONFIG.data_width [expr "$FDN_wight_coef_i*2"] CONFIG.input_options {registered} CONFIG.output_options {registered} CONFIG.sync_reset_qspo {true}] [get_ips dist_mem_gen_0]
#generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/dist_mem_gen_0/dist_mem_gen_0.xci]
#generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/dist_mem_gen_0/dist_mem_gen_0.xci]
#catch { config_ip_cache -export [get_ips -all dist_mem_gen_0] }
#export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/dist_mem_gen_0/dist_mem_gen_0.xci] -no_script -sync -force -quiet
#create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/dist_mem_gen_0/dist_mem_gen_0.xci]
#launch_runs -jobs 4 dist_mem_gen_0_synth_1
#wait_on_run dist_mem_gen_0_synth_1

# Block memory RAM
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list CONFIG.Memory_Type {Simple_Dual_Port_RAM}  CONFIG.Write_Width_A [expr "$FDN_wight_coef_i*2"] CONFIG.Write_Depth_A $FDN_N_chanals CONFIG.Read_Width_A [expr "$FDN_wight_coef_i*2"] CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Write_Width_B [expr "$FDN_wight_coef_i*2"] CONFIG.Read_Width_B [expr "$FDN_wight_coef_i*2"] CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips blk_mem_gen_0]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
catch { config_ip_cache -export [get_ips -all blk_mem_gen_0] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.xci]
#launch_runs -jobs 4 blk_mem_gen_0_synth_1
#wait_on_run blk_mem_gen_0_synth_1

# Accumulator
create_ip -name c_accum -vendor xilinx.com -library ip -version 12.0 -module_name c_accum_0
set_property -dict [list CONFIG.Input_Width $FDN_wight_mult CONFIG.Output_Width $FDN_wight_acc CONFIG.CE {true} CONFIG.SCLR {true}] [get_ips c_accum_0]
generate_target {instantiation_template} [get_files $PROJ_SRC.srcs/sources_1/ip/c_accum_0/c_accum_0.xci]
generate_target all [get_files  $PROJ_SRC.srcs/sources_1/ip/c_accum_0/c_accum_0.xci]
catch { config_ip_cache -export [get_ips -all c_accum_0] }
export_ip_user_files -of_objects [get_files $PROJ_SRC.srcs/sources_1/ip/c_accum_0/c_accum_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $PROJ_SRC.srcs/sources_1/ip/c_accum_0/c_accum_0.xci]
#launch_runs -jobs 4 c_accum_0_synth_1
#wait_on_run c_accum_0_synth_1
