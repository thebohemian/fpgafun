`include "../../common/iceclock/iceclock.v"

module top(
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input CLK_IN
		);
	
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(30)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
	localparam SYS_CLK_FREQ = 30_000_000;
	localparam BLINK_FREQ = 1;
	localparam COUNTER_WIDTH = $clog2(SYS_CLK_FREQ);

	// approx 1 Hz with 30 MHz clock.
	reg [COUNTER_WIDTH-1:0] counter;

	always @(posedge sysclk)
		counter <= counter + 1;
		
	assign LED_D9 = counter[COUNTER_WIDTH - 1];
	assign LED_D8 = counter[COUNTER_WIDTH - 2];
	assign LED_D7 = counter[COUNTER_WIDTH - 3];
	assign LED_D6 = counter[COUNTER_WIDTH - 4];
	assign LED_D5 = counter[COUNTER_WIDTH - 5];
	assign LED_D4 = counter[COUNTER_WIDTH - 6];
	assign LED_D3 = counter[COUNTER_WIDTH - 7];
	assign LED_D2 = counter[COUNTER_WIDTH - 8];

endmodule
