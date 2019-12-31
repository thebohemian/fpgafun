/** 
 * Uses a CD4094BE as a simple shift
 * register.
 * 
 * The IC is used as a write-only register.
 *
 * The module is driven by the main clock but
 * data sent to the IC is controlled by wr_en
 * clock enable signal. The signal was tested
 * to be working at up to 4 MHz.
 * 
 * The important difference to the 74HC595N
 * is that the register clock is not output
 * all the time but only when we write data
 * to it.
 * 
 * The 4094BE is also much slower.
 * 
 * TODO: Make the spi_tx and the 4094BE
 * control work for both chips only relying on
 * inverters.
 * 
 * The IC datasheet calls the wires used here
 * as follows:
 * 
 * strobe - strobe
 * data_out - data
 * register_clock - clock
 *  
 */
module shift_4094be
		(
		input rd_en,
		input [7:0] data_in,
		
		input wr_en,
		output data_out,		// data  
		output strobe,			// strobe
		output register_clock,	// clock
		
		input clk,
		
		output [2:0] counter_out,
		output [1:0] state_out
		);
	
	/** We cannot simply run the clock of the SR all the time because this would
	 * make the values in the register shift all the time. Instead we control
	 * the clock manually and use wr_en simply as a reference. wr_en is supposed
	 * to be slow enough for the shift register to be capable of following it.
	 */
	reg shift_en = 0;
	assign register_clock = shift_en;
	
	initial strobe <= 0;
		
	reg [2:0] counter = 0;
	reg [7:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_SHIFTING = 1;
	localparam STATE_WAIT_LOW = 2;
	localparam STATE_END = 3;
	reg [1:0] state = STATE_IDLE;
	
	reg last_wr_en;
	
	assign counter_out = counter;
	assign state_out = state;
	
	always @ (posedge clk) begin
		last_wr_en <= wr_en;
	end
	
	always @ (posedge clk) begin
		case (state)
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg <= data_in;
					state <= STATE_SHIFTING;
					counter <= 7;
				end
			end
			STATE_SHIFTING: begin
				if (!last_wr_en && wr_en) begin
					// posedge: generate clock to move data into outputs
					strobe <= 0;
					shift_en <= 1;
					data_out <= shift_reg[counter];
					state <= STATE_WAIT_LOW;
				end
			end
 			STATE_WAIT_LOW: begin
				if (last_wr_en && !wr_en) begin
					// negedge: stop shift register clock cycle, handle next bit or end
					shift_en <= 0;
					state <= (counter == 0) ? STATE_END : STATE_SHIFTING;
					counter <= counter - 1;
				end
			end
			STATE_END: begin
				if (!last_wr_en && wr_en) begin
					// posedge: generate clock to move data into outputs
					strobe <= 1;
					shift_en <= 1;
				end else if (last_wr_en && !wr_en) begin
					// negedge: stops output cycle
					shift_en <= 0;
					strobe <= 0;
					state <= STATE_IDLE;
				end
			end
		endcase
	end
	
endmodule
