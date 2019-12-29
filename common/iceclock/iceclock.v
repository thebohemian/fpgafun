`include "clock18mhz.v"
`include "clock24mhz.v"
`include "clock30mhz.v"
`include "clock48mhz.v"
`include "clock60mhz.v"
`include "clock96mhz.v"
`include "clock120mhz.v"
`include "clock124.5mhz.v"
`include "clock127.5mhz.v"
`include "clock150mhz.v"
`include "clock180mhz.v"
`include "clock204mhz.v"
`include "clock240mhz.v"
`include "clock264mhz.v"
`include "clock276mhz.v"

/** Instantiate this module and set the desired speed in the "speed" parameter.
 * 
 */
module iceclock
		#(
		parameter speed = 12
		)
		(
		input  clock12mhz_in,
		output clock_out,
		output locked
		);
`define instantiate(speed) """
    begin
	pll``speed`` pll (
			.clock_in(clock12mhz_in),
			.clock_out(clock_out),
			.locked(locked)
		);	
	end
"""
	
	generate
		case (speed)
			12: begin
				assign clock_out = clock12mhz_in;
				assign locked = 1;
			end
			18: `instantiate(18)
			24: `instantiate(24)
			30: `instantiate(30)
			48: `instantiate(48)
			60: `instantiate(60)
			96: `instantiate(96)
			120: `instantiate(120)
			125: `instantiate(1245)	// actually 124.5
			128: `instantiate(1275)	// actually 127.5
			150: `instantiate(150)
			180: `instantiate(180)
			204: `instantiate(204)
			default:
				$error("invalid speed!");
		endcase
			
	endgenerate
	
endmodule