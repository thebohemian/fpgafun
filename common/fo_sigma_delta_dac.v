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
	
	localparam MSB = BITS - 1;

	always @(posedge clk)
			accumulator <= accumulator[MSB:0] + {~in[MSB], in[MSB-1:0]};

	assign out = (!reset ? accumulator[BITS] : 0) ^ INV;

endmodule