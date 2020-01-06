`include "i2c_tx.v"

/**
 * Module: io_mcp23017
 * 
 * Byte-based access to IO extender MCP230717.
 * 
 */
module io_mcp23017 
		(
		input wr_en,	// write
		input [2:0] hardware_address,	// Hardware Address bits 
		input [7:0] register_address,	// IC registers (00 to 15h)
		input [7:0] data_in,			// data byte to write into IC
		
		output reg completed,			// indicates a finished read/write operation
			
		output SDA,						// Serial Data I/O pin
		output SCK,						// SCK pin from IC

		input clk_ic,					// clock signal for the external IC (100kHz, 400kHz)
		input clk
		);
	
	initial completed <= 0;
	
	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_WAIT_SENT_CONTROL_BYTE = 2;
	localparam STATE_WAIT_SENT_REGISTER_ADDRESS = 3;
	localparam STATE_WAIT_SENT_DATA_BYTE = 4;
	reg [2:0] state = STATE_IDLE;
		
	reg [7:0] register = 0;
	reg [7:0] data = 0;
	
	reg tx_rd_en = 0;
	reg [7:0] tx_data = 0;
	wire tx_sent;
	
	reg last_clk_ic = 0;
	
	always @ (posedge clk) begin
		last_clk_ic <= clk_ic;
		completed <= 0;
		tx_rd_en <= 0;
		
		case (state)
			STATE_IDLE:
				if (wr_en) begin
					data <= data_in;
					register <= register_address;
					state <= STATE_START;
				end
			STATE_START:
				if (last_clk_ic && !clk_ic) begin
					tx_rd_en <= 1;
					tx_data <= { 4'b0100, hardware_address, 1'b0 };
					state <= STATE_WAIT_SENT_CONTROL_BYTE;
				end
			STATE_WAIT_SENT_CONTROL_BYTE:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= register;
					state <= STATE_WAIT_SENT_REGISTER_ADDRESS;
				end
			STATE_WAIT_SENT_REGISTER_ADDRESS:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= data;
					state <= STATE_WAIT_SENT_DATA_BYTE;
				end
			STATE_WAIT_SENT_DATA_BYTE:
				if (tx_sent) begin
					state <= STATE_IDLE;
					completed <= 1;
				end
		endcase
	end
	
	i2c_tx tx(
			.rd_en(tx_rd_en),
			.data_in(tx_data),
			
			.sent(tx_sent),
			
			.sda(SDA),
			.scl(SCK),
			
			.clk_i2c(clk_ic),
			.clk(clk)
		);
	
endmodule
