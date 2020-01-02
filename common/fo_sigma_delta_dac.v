module fo_sigma_delta_dac
		#(
		parameter BITS=16,
		parameter INV=1'b1)
		
		(
		input reset,
		input [MSB:0] in,
		output out,
		
		input clk
		);
		
	localparam MSB = BITS - 1;
	
	reg [BITS:0] accumulator = 0;

	wire [MSB:0] unsigned_in = {~in[MSB], in[MSB-1:0]};
		
	always @(posedge clk)
		accumulator <= accumulator[MSB:0] + unsigned_in;
		
	assign out = reset ? 0 : (accumulator[BITS] ^ INV);

endmodule