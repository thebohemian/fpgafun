
/**
 * A module that allows bytewise outgoing I2C transfers.
 *
 * The module accepts the byte to send out when rd_en is HIGH.
 * 
 */
module i2c_tx
		(
		input rd_en,
		input [7:0] data_in,
		
		output reg sent,
		
		output reg sda,
		output reg scl,
		
		input clk_i2c,
		
		input clk
		);
	
	initial sent <= 0;
	
	initial sda <= 1;
	initial scl <= 1;
		
	reg [2:0] counter = 0;
	reg [7:0] shift_reg;

	localparam STATE_IDLE = 1;
	localparam STATE_START = 2;
	localparam STATE_PREPARE_BIT = 3;
	localparam STATE_WAIT_HIGH = 4;
	localparam STATE_PREPARE_ACK = 6;
	localparam STATE_RECEIVE_ACK = 7;
	reg [2:0] state = STATE_IDLE;
	
	reg last_clk_i2c = 1;
	
	reg ongoing = 0;
	
	always @ (posedge clk) begin
		last_clk_i2c <= clk_i2c;
		sent <= 0;
		
		case (state)
			STATE_IDLE: begin
				if (last_clk_i2c && !clk_i2c) begin
					// if negedge happens, then create the STOP condition
					sda <= 1;
					ongoing = 0;
				end
				if (rd_en) begin
					shift_reg <= data_in;
					counter <= 7;
					state <= (ongoing && clk_i2c) ? STATE_PREPARE_BIT : STATE_START;
				end
			end
			STATE_START: begin
				if (!last_clk_i2c && clk_i2c) begin
					// posedge
					// creates Start condition
					ongoing <= 1;
					sda <= 0;
					state <= STATE_PREPARE_BIT;
				end
			end
			STATE_PREPARE_BIT:
				if (last_clk_i2c && !clk_i2c) begin
					// negedge -> put bit on SDA
					sda <= shift_reg[counter];
					
					// drive clock down
					scl <= 0;
					
					state <= STATE_WAIT_HIGH;
				end
			STATE_WAIT_HIGH:
				if (!last_clk_i2c && clk_i2c) begin
					// posedge
					state <= (counter == 0) ? STATE_PREPARE_ACK : STATE_PREPARE_BIT;

					// drive clock up
					scl <= 1;
					
					counter <= counter - 1;
				end
			STATE_PREPARE_ACK:
				if (last_clk_i2c && !clk_i2c) begin
					// negedge
					
					// put sda down from our side
					sda <= 0;
					
					// drive clock down
					scl <= 0;
					
					state <= STATE_RECEIVE_ACK;
				end
			STATE_RECEIVE_ACK:
				if (!last_clk_i2c && clk_i2c) begin
					// posedge
					
					// indicate sent
					sent <= 1;
					
					state <= STATE_IDLE;
					
					// drive clock up
					scl <= 1;
				end
				// TODO: continue or next byte
		endcase
	end
	
endmodule
