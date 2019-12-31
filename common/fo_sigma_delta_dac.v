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
	
	localparam MSB = BITS - 1;
	
	reg [BITS:0] accumulator = 32768;

	always @(posedge clk)
		if (in[MSB])
			accumulator <= accumulator[MSB:0] - (-in);
		else
			accumulator <= accumulator[MSB:0] + in;

	assign out = (!reset ? accumulator[BITS] : 32768) ^ INV;

endmodule