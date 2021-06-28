`timescale 1 ns / 1 ps
`include "pico18june.v"
`include "sleep_unit2.v"


module pico18june_tb;
        reg clk = 1;
	wire clk_g;
        reg resetn = 0;
        wire trap;

        always #5 clk = ~clk;

        initial begin
                //if ($test$plusargs("vcd")) begin
                $dumpfile("pico18june_tb.vcd");
                $dumpvars(0, pico18june_tb);
                //end
                repeat (100) @(posedge clk);
                resetn <= 1;
                repeat (1000) @(posedge clk);
                $display("Test complete");
                $finish;
        end

        wire mem_valid;
        wire mem_instr;
        reg mem_ready;
        wire [31:0] mem_addr;
        wire [31:0] mem_wdata;
        wire [3:0] mem_wstrb;
        reg  [31:0] mem_rdata;
always @(posedge clk) begin
                if (mem_valid && mem_ready) begin
                        if (mem_instr)
                                $display("ifetch 0x%08x: 0x%08x", mem_addr, mem_rdata);
                        else if (mem_wstrb)
                                $display("write  0x%08x: 0x%08x (wstrb=%b)", mem_addr, mem_wdata, mem_wstrb);
                        else
                                $display("read   0x%08x: 0x%08x", mem_addr, mem_rdata);
                end
        end


	wire new_ascii_instr_o;
	wire core_busy_o;

        picorv32 #(
        ) uut (
                .clk         (clk_g        ),
                .resetn      (resetn     ),
                .trap        (trap       ),
                .mem_valid   (mem_valid  ),
                .mem_instr   (mem_instr  ),
                .mem_ready   (mem_ready  ),
                .mem_addr    (mem_addr   ),
                .mem_wdata   (mem_wdata  ),
                .mem_wstrb   (mem_wstrb  ),
		.new_ascii_instr_o (new_ascii_instr_o),
		.core_busy	(core_busy_o),
                .mem_rdata   (mem_rdata  )
        );


	wire core_sleep, fetch_enable_o;
	reg scan_cg_en_i = 1'b0;
	reg fetch_enable_i = 1'b0;
        reg wake_from_sleep_i= 1'b0; 

	sleep_unit sleep_uut (
		.clk_ungated_i	(clk		),
	        .resetn		(resetn		),
	        .clk_gated_o	(clk_g		),
	        .scan_cg_en_i	(scan_cg_en_i	),
	        .core_sleep_o	(core_sleep	),
	        .fetch_enable_i	(fetch_enable_i	),
	        .fetch_enable_o	(fetch_enable_o	),
		.new_ascii_instr_i (new_ascii_instr_o),
		.core_busy_o 	(core_busy_o),
		.wake_from_sleep_i (wake_from_sleep_i	)
	);

	initial begin
		repeat (92) @(posedge clk);
		#15 scan_cg_en_i = 1'b0;
		#25 fetch_enable_i = 1'b0;
		#10 wake_from_sleep_i =1'b1;
		#500 wake_from_sleep_i = 1'b0;
		#200 scan_cg_en_i = 1'b0;
		#30 fetch_enable_i = 1'b0;
		#1000 resetn = 1'b0;
		#300 resetn = 1'b1;
		#1000 wake_from_sleep_i =1'b1;
		#500 wake_from_sleep_i = 1'b0;
		
	end

        reg [31:0] memory [0:255];


	initial begin
               // memory[0] = 32'h 3fc00093; //       li      x1,1020
               // memory[1] = 32'h 0000a023; //       sw      x0,0(x1)
               // memory[2] = 32'h 0000a103; // loop: lw      x2,0(x1)
               // memory[3] = 32'h 00110113; //       addi    x2,x2,1
               // memory[4] = 32'h 0020a023; //       sw      x2,0(x1)
                //memory[5] = 32'h ff5ff06f; //       j       <loop>
	
memory[0] = 32'h 3FC00093;
memory[1] = 32'h 0000a023;
memory[2] = 32'h 00400513;
memory[3] = 32'h 00500593;
memory[4] = 32'h 000002B3;
memory[5] = 32'h FFF58593;
memory[6] = 32'h 00A282B3;
memory[7] = 32'h FFF58593;
memory[8] = 32'h FE05DCE3;
memory[9] = 32'h 00500533;
memory[10] = 32'h 00A0A023;
//
//memory[0] = 32'h 3FC00093;
//memory[1] = 32'h 00400513;
//memory[2] = 32'h 00500593;
//memory[3] = 32'h 02A58633;
//memory[4] = 32'h 00C0A023;
		
        end

        always @(posedge clk) begin
                mem_ready <= 0;
                if (mem_valid && !mem_ready) begin
                        if (mem_addr < 1024) begin
                                mem_ready <= 1;
                                mem_rdata <= memory[mem_addr >> 2];
                                if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
                                if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
                                if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
                                if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
                        end
                        /* add memory-mapped IO here */
                end
        end
endmodule

