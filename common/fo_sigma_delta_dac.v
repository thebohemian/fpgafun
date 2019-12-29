module fo_sigma_delta_dac
		#(
		parameter BITS=16,
		parameter INV=1'b1)
		
		(
		input reset,
		input [(BITS-1):0] in,
		output out,
		
		input clk
		);
	
	reg [BITS:0] accumulator = 0;

	always @(posedge clk) accumulator <= accumulator[(BITS-1):0] + in;

	assign out = (!reset ? accumulator[BITS] : {BITS { 1'b0 }}) ^ INV;

endmodule