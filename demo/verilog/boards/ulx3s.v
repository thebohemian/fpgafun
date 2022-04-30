`include "../../common/ecpclock/ecpclock.v"

localparam MAIN_CLOCK_FREQ = 25_000_000;

module boardclock
		#(
		parameter speed = 25
		)
		(
		input  clock_in,
		output clock_out,
		output locked
		);
		
	ecpclock #(.speed(speed)) clock0 (.clock25mhz_in(clock_in), .clock_out(clock_out), .locked(locked));

endmodule

