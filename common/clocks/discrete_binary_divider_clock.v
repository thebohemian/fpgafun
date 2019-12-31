/**
 */
module discrete_binary_divider_clock
		#(
		parameter N=1
		)
		
		(
		output clk_out,
		
		input clk
		);
	
	reg [N:0] counter = 0;
	
	always @ (posedge clk)
		counter <= counter + 1;
		
	assign clk_out = counter[N];
endmodule