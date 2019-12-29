/**
 * A simple free running increasing counter.
 * 
 * A reset line can be used. If set
 * to HIGH the counter is reset to 0.
 */ 
module monotonic_counter
		#(
		parameter BITS = 16
		)
		
		(
		output [BITS-1:0] value,
		
		input reset,
		input clk
		);
	
	reg [BITS-1:0] cnt = 0;
	
	always @ (posedge clk)
		cnt <= reset ? 0 : cnt + 1;

	assign value = cnt;
		
endmodule