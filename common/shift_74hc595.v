`include "spi_tx.v"

/** 
 * Uses a NXP 74HC595N as a simple shift
 * register.
 * 
 * The IC is used as a write-only register.
 *
 * The module is driven by the main clock but
 * data sent to the IC is controlled by wr_en
 * clock enable signal. The signal was tested
 * to be working at up to 40 MHz.
 * 
 * It is important the the frequency to talk
 * to the IC is at maximum *half* the frequency
 * of 'clk'.
 * 
 * The IC datasheet calls the wires used here
 * as follows:
 * 
 *  data_out - DS (serial data input)
 *	register_clock - SH_CP (shift register clock input)
 *  latch - ST_CP (storage register clock input)
 *  
 */
module shift_74hc595
		(
		input rd_en,
		input [7:0] data_in,
		
		input wr_en,
		output data_out,		// DS (serial data input)  
		output latch,			// ST_CP (storage register clock input)
		output register_clock,	// SH_CP (shift register clock input)
		
		input clk
		);
	assign register_clock = wr_en;

	spi_tx spi (
			.rd_en(rd_en),
			.data_in(data_in),
			
			.wr_en(register_clock),
			.data_out(data_out),
			
			.latch(latch),
			
			.clk(clk)
		);
	
endmodule
