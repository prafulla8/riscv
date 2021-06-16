
# Design
set ::env(DESIGN_NAME) "picorv32_axi"

set ::env(VERILOG_FILES) "./designs/pico9june/src/*.v"
set ::env(SDC_FILE) "./designs/pico9june/src/picorv32.sdc"

set ::env(CLOCK_PERIOD) "20.000"
set ::env(CLOCK_PORT) "clk"

## to map latches
set ::env(SYNTH_LATCH_MAP) "./designs/pico9june/test_map.v"

set ::env(CLOCK_NET) $::env(CLOCK_PORT)

#set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hs"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"


set filename $::env(OPENLANE_ROOT)/designs/$::env(DESIGN_NAME)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}


