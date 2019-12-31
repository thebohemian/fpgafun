/*
 * Clock enable signal based on a built-in free running counter.
 * 
 * The clock enable signal is only HIGH for one clock period.
 * 
 * The signal is generated every clock / 2^N times. So this
 * module can divide the incoming clock only by 2, 4, 8, 16
 * etc.
 * 
 * This module uses its own counter. If more than one binary
 * divider clock enable signal is to be used in a design
 * it is advisable to use a variant that shares the counter.
 */
module discrete_binary_divider_clock_enable
		#(
		parameter N=1
		)
		
		(
		output en,
		
		input clk
		);
	
	reg [N:0] counter = 0;
	
	always @ (posedge clk)
		counter <= counter + 1;
		
	assign en = &counter[N];
endmodule