/**
 * A module that allows bytewise outgoing SPI transfers.
 *
 * The module accepts the byte to send out when rd_en is HIGH.
 * It then starts the transfer when wr_en is HIGH next.
 * The bits are sent MSB first on each wr_en HIGH.
 *
 * During the transfer the latch line is taken LOW.
 * When the transfer ends the latch line is taken HIGH again.
 *
 * The rd_en and wr_en are controlled from the outside.
 */
module spi_tx(
		input rd_en,
		input [7:0] data_in,
		
		input wr_en,
		output reg data_out,
		
		output reg latch,
		
		input clk
		);
	
	initial latch <= 1;
		
	reg [2:0] counter = 0;
	reg [7:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_SHIFTING = 2;
	localparam STATE_END = 3;
	reg [1:0] state = STATE_IDLE;
	
	always @ (posedge clk) begin
		case (state)
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg <= data_in;
					counter <= 7;
					state <= STATE_START;
				end
			end
			STATE_START: begin
				if (wr_en) begin
					state <= STATE_SHIFTING;
					latch <= 0;
				end
			end
			STATE_SHIFTING: begin
				if (wr_en) begin
					data_out <= shift_reg[counter];
					
					if (counter > 0) begin
						counter <= counter - 1;
					end else begin
						state <= STATE_END;
					end
				end
			end
			STATE_END: begin
				if (wr_en) begin
					state <= STATE_IDLE;
					latch <= 1;
				end
			end
		endcase
	end
	
endmodule
