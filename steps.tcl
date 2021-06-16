pwd : /home/prafulla/risc-v/openlane/designs/queue
collaterals:
config.tcl
sky130A_sky130_fd_sc_*_config.tcl
src/picorv32.sdc
src/picorv32.v

update config.tcl


pwd: /home/prafulla/risc2/openlane
expdk
dockrisc
	./flow.tcl -design pico9june -tag TAG1 -overwrite -interactive
	run_synthesis
		results/synthesis/queue.synthesis.v
		
	run_floorplan
		tmp/floorplan/verilog2def_openroad.def
		tmp/floorplan/ioPlacer.def
		results/floorplan/queue.floorplan.def
		tmp/floorplan/pdn.def
		
	run_placement
		results/synthesis/queue.synthesis_optimized.v
		results/placement/queue.placement.def
		
	run_cts
		results/cts/queue.cts.def
		results/synthesis/queue.synthesis_cts.v
		
	run_routing
		tmp/routing/fastroute.def
		tmp/routing/fastroute.def
		tmp/routing/addspacers.def
		results/synthesis/queue.synthesis_preroute.v
		
		
m5 and m4 coming as straps because we specified power grid strategy in : /home/prafulla/risc-v/sky130A/libs.tech/openlane/common_pdn.tcl
pdngen::specify_grid stdcell {}


following libs config.tcl is present
sky130_fd_sc_hd/
sky130_fd_sc_hdll/
sky130_fd_sc_hs/
sky130_fd_sc_hvl/
sky130_fd_sc_ls/
sky130_fd_sc_ms

#Resizing the floorplan

reg cannot be driven by primitives or continuous assignment















	
