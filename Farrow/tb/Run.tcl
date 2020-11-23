# Project properties
set PROJ_NAME   Farrow
set LIB_PATH    ../../LIB_sverilog
set PROJ_PATH   ../
set FARROW_PATH ../
set PROJ_SRC    $PROJ_PATH/$PROJ_NAME/$PROJ_NAME
set Simulation_Enable 1
# set Synthesis_Enable 1

# Load script constant
source $PROJ_PATH/tb/Farrow_param.tcl

# Create project
create_project $PROJ_NAME $PROJ_PATH/$PROJ_NAME -force -part xcvu9p-flgb2104-2-i

source $FARROW_PATH/src/Farrow.tcl

# Simulate resorse
add_files -fileset sim_1 -norecurse $LIB_PATH/Interface_AXI.vh
add_files -fileset sim_1 -norecurse $LIB_PATH/function.vh
add_files -fileset sim_1 -norecurse $FARROW_PATH/tb/Farrow_param.vh
add_files -fileset sim_1 -norecurse $FARROW_PATH/tb/Farrow_tb.sv

# Project TOP
set_property top Farrow [current_fileset]

# TB TOP
set_property top Farrow_tb [get_filesets sim_1]

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
add_wave {{/Farrow_tb/Farrow_inst/rst}} 
# CLK
add_wave {{/Farrow_tb/Farrow_inst/clk}} 
# Data_in
add_wave {{/Farrow_tb/Farrow_inst/vld_in}} 
add_wave {{/Farrow_tb/Farrow_inst/last_in}} 
add_wave {{/Farrow_tb/Farrow_inst/data_in}} 
# Delay_in
add_wave {{/Farrow_tb/Farrow_inst/clk_del}}
add_wave {{/Farrow_tb/Farrow_inst/vld_del}} 
add_wave {{/Farrow_tb/Farrow_inst/last_del}} 
add_wave {{/Farrow_tb/Farrow_inst/data_del}} 
# Data_out
add_wave {{/Farrow_tb/Farrow_inst/vld_out}} 
add_wave {{/Farrow_tb/Farrow_inst/last_out}} 
add_wave {{/Farrow_tb/Farrow_inst/data_out}} 
# Run test
run all





