`include "../../common/iceclock/iceclock.v"

/** measures a value on PIN D16 and counts the 
 * cycles/clock ticks between to positive edge
 * movements of the signal (so the cycle of the
 * signal). Finally the clock ticks are transformed
 * into a nanosecond value - the length of the
 * period.
 *
 * This works by shifting the sample count to the
 * left 3 times (equivalent of mulitplying by 8).
 * this works because the system clock of the
 * FPGA function is set to 125MHz which translates
 * 8ns per cycle.
 *
 * Here some results of the measurement:
 * 10936ns - 33pF
 * 58112ns - 220pF
 * 7274240ns - 100nF
 *
 */
module top(
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input D16_i,
		
		input CLK_IN
		);

	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(125)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
	localparam CLK_FREQ = 125_000_000;
	
	reg input_latch_unstable = 0;
	reg input_latch_next = 0;
	reg input_latch_last = 0;
	
	reg [31:0] cycle_counter = 0;
	
	reg [31:0] samples_freq = 0;

	always @ (posedge sysclk) begin
		input_latch_unstable <= D16_i;	// metastable
		input_latch_next <= input_latch_unstable;	// stable
		input_latch_last <= input_latch_next;	// last value
		
		if (!input_latch_last && input_latch_next) begin
			// posedge
			cycle_counter <= 0;
			samples_freq <= cycle_counter << 3; // times 8
		end
		else begin
			cycle_counter <= cycle_counter + 1;
		end
	end

//	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = samples_freq[23:16];
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = samples_freq[15:8];
//	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = samples_freq[7:0];

endmodule