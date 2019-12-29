
/**
 * A module that allows bytewise outgoing I2C transfers.
 *
 * The module accepts the byte to send out when rd_en is HIGH.
 * 
 */
module i2c_tx
		#(
		parameter BYTES=2
		)
		(
		input rd_en,
		input [7:0] data_in,
		input [(INDEX_BITS-1):0] index_in,
		
		output reg sda,
		output scl,
		
		input i2c_clock,
		
		input clk
		);
		
	assign scl = i2c_clock;
	
	reg [2:0] counter = 0;
	reg [7:0] shift_reg [BYTES];

	localparam STATE_BOOT = 0;
	localparam STATE_IDLE = 1;
	localparam STATE_START = 2;
	localparam STATE_PREPARE_BIT = 3;
	localparam STATE_WAIT_HIGH = 4;
	localparam STATE_WAIT_LOW = 5;
	localparam STATE_ACK_HIGH = 6;
	localparam STATE_ACK_LOW = 7;
	localparam STATE_STOP = 8;
	
	reg [4:0] state = STATE_BOOT;
	
	localparam TYPE_ADDRESS = 0;
	localparam TYPE_DATA = 1;
	reg byte_type;
	
	localparam INDEX_BITS = $clog2(BYTES);
	reg [(INDEX_BITS-1):0] index = 0;
	
	reg [7:0] addr = 8'b0100_0000;
	
	always @ (posedge clk) begin
		case (state)
			STATE_BOOT: begin
				if (!i2c_clock) begin
					state <= STATE_IDLE;
					sda <= 1;
				end
			end
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg[index_in] <= data_in;
					if (index_in == BYTES-1) begin
						counter <= 7;
						byte_type <= 0;
						state <= STATE_START;
					end
				end
			end
			STATE_START: begin
				if (i2c_clock) begin
					if (sda) begin
						state <= STATE_PREPARE_BIT;
						
						// bus START
						sda <= 0;
					end
				end
			end
			STATE_PREPARE_BIT:
				if (!i2c_clock) begin
					state <= STATE_WAIT_HIGH;
						
					// bus value
					sda <= byte_type ? shift_reg[counter] : addr[counter];
				end
			STATE_WAIT_HIGH:
				if (i2c_clock) begin
					if (counter == 0) begin
						state <= STATE_WAIT_LOW;
					end else begin
						state <= STATE_PREPARE_BIT;
					end
					counter <= counter - 1;
				end
			STATE_WAIT_LOW:
				if (!i2c_clock) begin
					state <= STATE_ACK_HIGH;
				end
			STATE_ACK_HIGH:
				if (i2c_clock) begin
					state <= STATE_ACK_LOW;
				end
			STATE_ACK_LOW:
				if (i2c_clock) begin
					if (byte_type == TYPE_ADDRESS) begin
						byte_type <= TYPE_DATA;
						counter <= 7;
						index <= 0;
						state <= STATE_PREPARE_BIT;
					end
					else if (index == BYTES - 1) begin
						// all bytes processed
						state <= STATE_STOP;
					end
					else begin
						// next data byte
						counter <= 7;
						index <= index + 1;
						state <= STATE_PREPARE_BIT;
					end
				end
			STATE_STOP: begin
				if (i2c_clock) begin
					state <= STATE_IDLE;
					
					// bus STOP
					sda <= 1;
				end
			end
		endcase
	end
	
endmodule
