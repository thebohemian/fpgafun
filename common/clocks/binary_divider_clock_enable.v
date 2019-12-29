/*
 * Clock enable signal based on given and potentially shared
 * counter.
 * 
 * The clock enable signal is only HIGH for one clock period.
 * 
 * The signal is generated every clock / 2^N times. So this
 * module can divide the incoming clock only by 2, 4, 8, 16
 * etc.
 * 
 * The counter is supposed to be monotonically increasing
 * and can have more bits than what this module needs. 
 */
module binary_divider_clock_enable
		#(
		parameter N=1
		)
		
		(
		output en,
		
		input [N:0] counter_in,
		
		input clk
		);
	
	assign en = counter_in[N] & !counter_in[0];
	
endmodule