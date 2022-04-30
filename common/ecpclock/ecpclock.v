`include "clock12mhz.v"
`include "clock30mhz.v"
`include "clock400mhz.v"
				
/** Instantiate this module and set the desired speed in the "speed" parameter.
 * 
 */
module ecpclock
		#(
		parameter speed = 25
		)
		(
		input  clock25mhz_in,
		output clock_out,
		output locked
		);

`define instantiate(speedarg) """
    begin

	ecp_pll``speedarg`` pll (
			.clkin(clock12mhz_in),
			.clkout0(clock_out),
			.locked(locked)
		);	
	end
"""
	
	generate
		case (speed)
			12: `instantiate(12)
			25: begin
				assign clock_out = clock25mhz_in;
				assign locked = 1;
			end
			30:  `instantiate(30)
			400: `instantiate(400)
			default:
				$error("invalid speed!");
		endcase
			
	endgenerate
	
endmodule
