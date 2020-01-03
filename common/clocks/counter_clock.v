module counter_clock
		#(
		parameter CLK_FREQ = 12_000_000,
		parameter COUNTER_FREQ = 6_000_000
		)
		
		(
		output clk_out,
		
		input clk
		);
	
	localparam TICKS = CLK_FREQ / COUNTER_FREQ;
	localparam BITS = $clog2(TICKS);
	
	reg [BITS-1:0] counter = TICKS - 1;
	
	always @ (posedge clk)
		counter <= (counter == 0) ? (TICKS-1) : counter-1;
		
	assign clk_out = (counter >= (TICKS/2));
	
endmodule