/**
 * SPI byte receive module
 * 
 * Receives a byte from an external source via SPI.
 * 
 * The clock of the external source is given by
 * clk_ic but the module only uses this as a guideline
 * to create its own clock signal.
 * 
 * The signal is only created during the actual read
 * phase.
 * 
 * The bits are read MSB-first.
 * 
 * "received" is set to HIGH for one clock cycle upon
 * arrival of the last bit. The byte can then be read from
 * "data_out". It stays valid until the next read cycle
 * starts.
 * 
 * A read cycle is started by putting "rd_en" to HIGH.
 *  
 * This module contains no latch/strobe or chip select
 * functionality. This is to be provided by another
 * module. This allows embedding a receive phase
 * in a larger SPI-based protocol. 
 */
module spi_rx(
		input rd_en,
		output [7:0] data_out,
		
		output reg received,		// signals completion
		
		input serial_in,			// from IC
		output reg serial_clock,	// to IC
		
		input clk_ic,
		input clk
		);
	
	initial serial_clock <= 0;
	
	reg [8:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_WAIT_BIT = 1;
	localparam STATE_SHIFTING_IN = 2;
	reg [1:0] state = STATE_IDLE;

	reg last_clk_ic = 0;
	
	always @ (posedge clk) begin
		last_clk_ic <= clk_ic;
		received <= 0;
		
		case (state)
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg <= 9'b0_0000_0001;
					state <= STATE_WAIT_BIT;
				end
			end
			STATE_WAIT_BIT:
				if (!last_clk_ic && clk_ic) begin
					// posedge
					serial_clock <= 1;
					state <= STATE_SHIFTING_IN;
					
					// expect data
					shift_reg <= { shift_reg[7:0], serial_in };
				end
			STATE_SHIFTING_IN:
				if (last_clk_ic && !clk_ic) begin
					serial_clock <= 0;
					
					if (shift_reg[8]) begin
						// all bits read
						received <= 1;
						state <= STATE_IDLE;
					end else begin
						state <= STATE_WAIT_BIT;
					end
				end
		endcase
	end
	
	assign data_out = shift_reg[7:0];
	
endmodule
