/**
 * A simple free running increasing counter.
 */ 
module monotonic_counter
		#(
		parameter BITS = 16
		)
		
		(
		output [BITS-1:0] value,
		
		input clk
		);
	
	reg [BITS-1:0] cnt = 0;
	
	always @ (posedge clk)
		cnt <= cnt + 1;

	assign value = cnt;
		
endmodule