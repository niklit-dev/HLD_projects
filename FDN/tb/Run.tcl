# Project properties
set PROJ_NAME FDN
set LIB_PATH  ../../LIB_sverilog
set PROJ_PATH ../
set FDN_PATH  ../
set PROJ_SRC  $PROJ_PATH/$PROJ_NAME/$PROJ_NAME
set Simulation_Enable 1
# set Synthesis_Enable 1

# Load script constant
source $PROJ_PATH/tb/FDN_param.tcl

# Create project
create_project $PROJ_NAME $PROJ_PATH/$PROJ_NAME -force -part xcvu9p-flgb2104-1-e

source $FDN_PATH/src/FDN.tcl

# Constraints
add_files -fileset constrs_1 -norecurse $PROJ_PATH/tb/constr.xdc

# Simulate resorse
add_files -fileset sim_1 -norecurse $LIB_PATH/Interface_AXI.vh
add_files -fileset sim_1 -norecurse $FDN_PATH/tb/FDN_param.vh
add_files -fileset sim_1 -norecurse $FDN_PATH/tb/FDN_TB.sv

# Project TOP
set_property top FDN_core_x [current_fileset]

# TB TOP
set_property top FDN_TB [get_filesets sim_1]

# Run Synthesis
#launch_runs synth_1 

# # Run Implementation
# launch_runs impl_1

# Run simulation
launch_simulation
close_wave_config
create_wave_config
restart
# Reset
add_wave {{/FDN_TB/FDN_core_x_inst/rst}} 
# CLK
add_wave {{/FDN_TB/FDN_core_x_inst/clk}} 
# Data input
add_wave {{/FDN_TB/FDN_core_x_inst/vld_data_in}} 
add_wave {{/FDN_TB/FDN_core_x_inst/last_data_in}} 
add_wave {{/FDN_TB/FDN_core_x_inst/readi_data_in}} 
add_wave {{/FDN_TB/FDN_core_x_inst/dataReIn}} 
add_wave {{/FDN_TB/FDN_core_x_inst/dataImIn}} 
# Coefficients
add_wave {{/FDN_TB/FDN_core_x_inst/vld_coef_in}} 
add_wave {{/FDN_TB/FDN_core_x_inst/last_coef_in}} 
add_wave {{/FDN_TB/FDN_core_x_inst/readi_coef_in}} 
add_wave {{/FDN_TB/FDN_core_x_inst/coefReIn}} 
add_wave {{/FDN_TB/FDN_core_x_inst/coefImIn}} 
# Data output
add_wave {{/FDN_TB/FDN_core_x_inst/vld_data_out}} 
add_wave {{/FDN_TB/FDN_core_x_inst/last_data_out}}
add_wave {{/FDN_TB/FDN_core_x_inst/dataReOut}} 
add_wave {{/FDN_TB/FDN_core_x_inst/dataImOut}} 
# AXI Lite
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_clk}} 
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_rst}}
# write
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_awaddr}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_awid}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_awvalid}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_awready}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_wdata}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_wvalid}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_wready}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_bready}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_bvalid}}
# read
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_araddr}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_arid}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_arvalid}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_arready}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_rdata}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_rvalid}}
add_wave {{/FDN_TB/FDN_core_x_inst/s_axil_rready}}

run all



