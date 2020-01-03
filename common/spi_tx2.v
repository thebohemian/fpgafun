/**
 * Byte-based data transfer via SPI to an
 * external device.
 * 
 * The transfer phase is started by putting the data
 * into "data_in" and setting "rd_en" to HIGH.
 * 
 * The module respects the given clock "clk_ic"
 * to generate its own clock signal for the external
 * device. The clock generation is only active during
 * the actual transfer operation.
 * 
 * The transfer happens MSB-first.
 * 
 * The "sent" line is set to HIGH when the transfer
 * sends out the last bit. Immediately providing
 * another data byte allows continous writing of
 * data to the external device without losing a
 * clock cycle.
 * 
 */
module spi_tx(
		input rd_en,
		input [7:0] data_in,
		
		output reg sent,				// signals completion
		
		output reg serial_out,			// to IC
		output reg serial_clock,		// to IC
		
		input clk_ic,
		input clk
		);

	initial serial_clock <= 0;
	initial serial_out <= 0;
	
	reg [2:0] counter = 0;
	reg [7:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_PREPARE_BIT = 1;
	localparam STATE_SHIFTING = 2;
	localparam STATE_FINISH = 3;
	reg [1:0] state = STATE_IDLE;
	
	reg last_clk_ic = 0;
	
	always @ (posedge clk) begin
		last_clk_ic <= clk_ic;
		sent <= 0;
		
		case (state)
			STATE_IDLE: begin
				// If negedge happens during idle, the clock and
				// output is reset. Another transfer could however
				// start immediately.
				if (last_clk_ic && !clk_ic) begin
					// negedge
					serial_clock <= 0;
					serial_out <= 0;
				end
				
				if (rd_en) begin
					shift_reg <= data_in;
					counter <= 7;
					state <= STATE_PREPARE_BIT;
				end
			end
			STATE_PREPARE_BIT:
				// negedge
				if (last_clk_ic && !clk_ic) begin
					serial_clock <= 0;
					// prepare bit
					serial_out <= shift_reg[counter];
					state <= STATE_SHIFTING;
				end
			STATE_SHIFTING:
				if (!last_clk_ic && clk_ic) begin
					// posedge
					serial_clock <= 1;
					counter <= counter - 1;
					
					if (counter == 0) begin
						state <= STATE_IDLE;
						sent <= 1;
					end else begin
						state <= STATE_PREPARE_BIT;
					end
				end
		endcase
	end
	
endmodule
