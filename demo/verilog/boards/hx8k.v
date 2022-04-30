
localparam MAIN_CLOCK_FREQ = 12_000_000;

`include "../../common/iceclock/iceclock.v"

module boardclock
		#(
		parameter speed = 12
		)
		(
		input  clock_in,
		output clock_out,
		output locked
		);
		
	iceclock #(.speed(speed)) clock0 (.clock12mhz_in(clock_in), .clock_out(clock_out), .locked(locked));

endmodule
