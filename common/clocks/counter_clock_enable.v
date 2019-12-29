/**
 * A module which represents a "clock enable" signal
 * created through a counter register.
 * 
 * The signal is HIGH for a single period only.
 * 
 * The width of the counter depends on the relation
 * between the source and the destination frequency.
 * 
 * A clock of this type is costly in terms of needed
 * FPGA resources and should be used sparingly.
 */ 
module counter_clock_enable
		#(
		parameter CLK_FREQ = 12_000_000,
		parameter COUNTER_FREQ = 6_000_000,
		)
		
		(
		output en,
		
		input clk
		);
	
	localparam TICKS = CLK_FREQ / COUNTER_FREQ;
	localparam BITS = $clog2(TICKS);
	
	reg [BITS-1:0] counter = 0;
	
	always @ (posedge clk)
		counter <= counter == 0 ? TICKS - 1 : counter - 1;
		
	assign en = counter == 0;
	
endmodule