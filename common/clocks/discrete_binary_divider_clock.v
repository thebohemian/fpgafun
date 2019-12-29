/**
 */
module discrete_binary_divider_clock
		#(
		parameter N=1
		)
		
		(
		output div_clk,
		
		input clk
		);
	
	reg [N:0] counter = 0;
	
	always @ (posedge clk)
		counter <= counter + 1;
		
	assign div_clk = counter[N];
endmodule