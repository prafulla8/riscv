module sleep_unit (
        clk_ungated_i,
        resetn,
        clk_gated_o,
        scan_cg_en_i,
        core_sleep_o,
        fetch_enable_i,
        fetch_enable_o,
	//mul_busy_i,
	//fast_mul_busy_i,
	//div_busy_i,
	//axi_busy_i,
	//adaptor_busy_i,
        /*if_busy_i,
        ctrl_busy_i,
        lsu_busy_i,
        apu_busy_i,
        pulp_clock_en_i,
        p_elw_start_i,
        p_elw_finish_i,
        debug_p_elw_no_sleep_i, */
        new_ascii_instr_i,
        core_busy_o,
        wake_from_sleep_i
);
        parameter PULP_CLUSTER = 0;
        input wire clk_ungated_i;
        input wire resetn;
        output wire clk_gated_o;
        input wire scan_cg_en_i;
        output wire core_sleep_o;
        input wire fetch_enable_i;
        output wire fetch_enable_o;
	//input wire mul_busy_i;
        //input wire fast_mul_busy_i;
        //input wire div_busy_i;
        //input wire axi_busy_i;
        //input wire adaptor_busy_i;
        /*input wire if_busy_i;
        input wire ctrl_busy_i;
        input wire lsu_busy_i;
        input wire apu_busy_i;
        input wire pulp_clock_en_i;
        input wire p_elw_start_i;
        input wire p_elw_finish_i;
        input wire debug_p_elw_no_sleep_i; */
        output wire core_busy_o;
        input wire new_ascii_instr_i;
        input wire wake_from_sleep_i;

        reg fetch_enable_q;
	reg new_ascii_instr_q;
	reg new_ascii_instr_q2;
	reg new_ascii_instr_q3;
	reg new_ascii_instr_q4;
	reg new_ascii_instr_q5;
	reg new_ascii_instr_q6;
	reg new_ascii_instr_q7;
	reg new_ascii_instr_q8;
	reg new_ascii_instr_q9;
	reg new_ascii_instr_q10;
	reg new_ascii_instr_q11;
	reg new_ascii_instr_q12;
	reg new_ascii_instr_q13;
	wire fetch_enable_d;
        reg core_busy_q1;
	reg core_busy_q2;
        wire core_busy_d;
        //reg p_elw_busy_q;
        //wire p_elw_busy_d;
        wire clock_en;
        assign fetch_enable_d = (fetch_enable_i ? 1'b1 : fetch_enable_q);
        generate
                if (PULP_CLUSTER) begin : g_pulp_sleep
                        assign core_busy_d = (p_elw_busy_d ? if_busy_i || apu_busy_i : 1'b1);
                        assign clock_en = fetch_enable_q && (pulp_clock_en_i || core_busy_q);
                        assign core_sleep_o = (p_elw_busy_d && !core_busy_q) && !debug_p_elw_no_sleep_i;
                        assign p_elw_busy_d = (p_elw_start_i ? 1'b1 : (p_elw_finish_i ? 1'b0 : p_elw_busy_q));
                end
                else begin : g_no_pulp_sleep
                        //assign core_busy_d = ((mul_busy_i || fast_mul_busy_i) || div_busy_i) ;
			//assign core_busy_d = new_ascii_instr_q13 || wake_from_sleep_i;
                        //assign clock_en = fetch_enable_q && (wake_from_sleep_i || core_busy_q);
                        assign clock_en = fetch_enable_q || wake_from_sleep_i || core_busy_q2 ;
			//assign clock_en = fetch_enable_q || core_busy_q ;
			assign core_sleep_o = fetch_enable_q && !clock_en;
                        //assign p_elw_busy_d = 1'b0;
			assign core_busy_o = wake_from_sleep_i || core_busy_d;
                end
        endgenerate
        always @(posedge clk_ungated_i or negedge resetn)
                if (resetn == 1'b0) begin
                        core_busy_q1 <= 1'b0;
                        //p_elw_busy_q <= 1'b0;
                        fetch_enable_q <= 1'b0;
                end
                else begin
                        core_busy_q1 <= core_busy_d;
			core_busy_q2 <= core_busy_q1;
                        //p_elw_busy_q <= p_elw_busy_d;
		       fetch_enable_q <= fetch_enable_d;
		       //new_ascii_instr_q <= new_ascii_instr_i;
		       //new_ascii_instr_q2 <= new_ascii_instr_q;
		       //new_ascii_instr_q3 <= new_ascii_instr_q2;
		       //new_ascii_instr_q4 <= new_ascii_instr_q3;
		       //new_ascii_instr_q5 <= new_ascii_instr_q4;
		       //new_ascii_instr_q6 <= new_ascii_instr_q5;
		       //new_ascii_instr_q7 <= new_ascii_instr_q6;
		       //new_ascii_instr_q8 <= new_ascii_instr_q7;
		       //new_ascii_instr_q9 <= new_ascii_instr_q8;
		       //new_ascii_instr_q10 <= new_ascii_instr_q9;
		       //new_ascii_instr_q11 <= new_ascii_instr_q10;
		       //new_ascii_instr_q12 <= new_ascii_instr_q11;
		       //new_ascii_instr_q13 <= new_ascii_instr_q12;
                end
        assign fetch_enable_o = fetch_enable_q;
        clock_gate core_clock_gate_i(
                .clk_i(clk_ungated_i),
                .en_i(clock_en),
                .scan_cg_en_i(scan_cg_en_i),
                .clk_o(clk_gated_o)
        );

	shift_reg inst_shift_reg(
		.clk	(clk_ungated_i),
		.reset	(resetn),
		.s_in	(new_ascii_instr_i),
		.s_out 	(core_busy_d)

	);
endmodule

module clock_gate(clk_o, clk_i, en_i,scan_cg_en_i);
  // Clock gating latch triggered on the rising clki edge
  input  clk_i;
  input  en_i;
  input  scan_cg_en_i;
  output clk_o;

  reg enabled;
  always @ (clk_i, en_i) begin
    if (!clk_i) begin
      enabled = en_i | scan_cg_en_i;
    end
  end

  assign clk_o = enabled & clk_i;
endmodule

module shift_reg
   #(parameter N=38)
   (
    input wire clk, reset,
    input wire s_in,
    output wire s_out
   );

   reg [N-1:0] r_reg;
   wire [N-1:0] r_next;


   always @(posedge clk, negedge reset)
   begin
      if (~reset)
         r_reg <= 0;
      else
         r_reg <= r_next;
	end

	assign r_next = {s_in, r_reg[N-1:1]};
	assign s_out = r_reg[0];


endmodule
