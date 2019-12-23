module fo_sigma_delta_dac
		#(
		parameter BITS=16,
		parameter INV=1'b1)
		
		(
		input clk,
		input reset,
		input [(BITS-1):0] in,
		output out
		);

	reg [BITS:0] accumulator;

	always @(posedge clk) accumulator <= accumulator[(BITS-1):0] + (in);

	assign out = (!reset ? accumulator[BITS] : {BITS { 1'b0 }}) ^ INV;
endmodule