`include "spi_rx.v"
`include "spi_tx2.v"

/**
 * Module: sram_23lc1024
 * 
 * Byte-based access to static RAM module
 * 23LC1024.
 * 
 */
module sram_23lc1024 
		(
		input wr_en,	// write
		input rd_en,	// read
		
		input [23:0] address_in,		// address to read from/write to
		input [7:0] data_in,			// data byte to write into memory
		output [7:0] data_out,			// data byte last read from memory (valid 
		
		output reg completed,			// indicates a finished read/write operation
		
		output reg CSn,					// Chip Select pin from IC
		output HOLDn,					// HOLD pin from IC (feature not used)
			
		output SI,						// Serial In pin from IC
		input SO,						// Serial Out pin from IC
		output SCK,						// SCK pin from IC

		input clk_ic,					// clock signal for the external IC
		input clk
		);
	
	localparam STATE_IDLE = 0;
	localparam STATE_READ_START = 11;
	localparam STATE_READ_WAIT_SENT_COMMAND = 1;
	localparam STATE_READ_WAIT_SENT_ADDRESS_BYTE_1 = 2;
	localparam STATE_READ_WAIT_SENT_ADDRESS_BYTE_2 = 3;
	localparam STATE_READ_WAIT_SENT_ADDRESS_BYTE_3 = 4;
	localparam STATE_READ_WAIT_RECEIVED_DATA_BYTE = 5;
	localparam STATE_WRITE_START = 12;
	localparam STATE_WRITE_WAIT_SENT_COMMAND = 6;
	localparam STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_1 = 7;
	localparam STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_2 = 8;
	localparam STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_3 = 9;
	localparam STATE_WRITE_WAIT_SENT_DATA_BYTE = 10;
	localparam STATE_FINISH = 13;
	reg [3:0] state = STATE_IDLE;
	
	// HOLD feature not used.
	assign HOLDn = 1;
	
	initial CSn <= 1;
	
	reg [7:0] data;
	reg [23:0] address;
	
	reg tx_rd_en = 0;
	reg [7:0] tx_data = 0;
	wire tx_sent;
	
	reg rx_rd_en = 0;
	wire [7:0] rx_data;
	wire rx_received;
	
	reg last_clk_ic = 0;
	
	always @ (posedge clk) begin
		last_clk_ic <= clk_ic;
		completed <= 0;
		tx_rd_en <= 0;
		rx_rd_en <= 0;
		
		case (state)
			STATE_IDLE:
				if (rd_en) begin
					address <= address_in;
					state <= STATE_READ_START;
					
				end else if (wr_en) begin
					address <= address_in;
					data <= data_in;
					
					state <= STATE_WRITE_START;
				end
			STATE_WRITE_START:
				if (!last_clk_ic && clk_ic) begin
					CSn <= 0;			// enable device
					tx_rd_en <= 1;
					tx_data <= 8'h02;	// write command
					state <= STATE_WRITE_WAIT_SENT_COMMAND;
				end
			STATE_WRITE_WAIT_SENT_COMMAND:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= address[23:16];
					state <= STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_1;
				end
			STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_1:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= address[15:8];
					state <= STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_2;
				end
			STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_2:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= address[7:0];
					state <= STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_3;
				end
			STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_3:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= data_in;
					state <= STATE_WRITE_WAIT_SENT_DATA_BYTE;
				end
			STATE_WRITE_WAIT_SENT_DATA_BYTE:
				if (tx_sent) begin
					state <= STATE_FINISH;
				end
			STATE_READ_START:
				if (!last_clk_ic && clk_ic) begin
					CSn <= 0;			// enable device
					
					tx_rd_en <= 1;
					tx_data <= 8'h03;	// read command
					
					state <= STATE_READ_WAIT_SENT_COMMAND;
				end
			STATE_READ_WAIT_SENT_COMMAND:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= address[23:16];
					state <= STATE_READ_WAIT_SENT_ADDRESS_BYTE_1;
				end
			STATE_READ_WAIT_SENT_ADDRESS_BYTE_1:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= address[15:8];
					state <= STATE_READ_WAIT_SENT_ADDRESS_BYTE_2;
				end
			STATE_READ_WAIT_SENT_ADDRESS_BYTE_2:
				if (tx_sent) begin
					tx_rd_en <= 1;
					tx_data <= address[7:0];
					state <= STATE_READ_WAIT_SENT_ADDRESS_BYTE_3;
				end
			STATE_READ_WAIT_SENT_ADDRESS_BYTE_3:
				if (tx_sent) begin
					rx_rd_en <= 1;
					state <= STATE_READ_WAIT_RECEIVED_DATA_BYTE;
				end
			STATE_READ_WAIT_RECEIVED_DATA_BYTE:
				if (rx_received) begin
					data <= rx_data;
					state <= STATE_FINISH;
					CSn <= 1;
					completed <= 1;
				end
			STATE_FINISH:
				if (!last_clk_ic && clk_ic) begin
					state <= STATE_IDLE;
					CSn <= 1;
					completed <= 1;
				end
		endcase
	end
	
	assign data_out = data;
	
	/* Forwards the generated clock signal from the receive and send module.
	 * Only one of them should be active.
	 */
	wire tx_SCK, rx_SCK;
	wire SCK = tx_SCK | rx_SCK;
	
	spi_tx tx(
			.rd_en(tx_rd_en),
			.data_in(tx_data),
			
			.sent(tx_sent),
			
			.serial_out(SI),
			.serial_clock(tx_SCK),
			
			.clk_ic(clk_ic),
			.clk(clk)
		);
	
	spi_rx rx(
			.rd_en(rx_rd_en),
			.data_out(rx_data),
			
			.received(rx_received),
			
			.serial_in(SO),
			.serial_clock(rx_SCK),
			
			.clk_ic(clk_ic),
			.clk(clk)
		);
endmodule

/* protocol:
 * - 8/16/32 bit operation
 * - SPI
 * - SI data input
 * - SCK rising edge
 * - write to mem:
 * 	- CS low
 * 	- 0x02 (WRITE)	(data: SI, clock: SCK)
 * 	- 24bit address (data: SI, clock: SCK)
 * 	- write data byte (data: SI, clock: SCK) 
 * 	- CS high
 * 	
 * - read from mem:
 * 	- CS low
 * 	- 0x03 (READ)	(data: SI, clock: SCK)
 * 	- 24bit address (data: SI, clock: SCK)
 * 	- read data byte (data: SO, clock: SCK) 
 * 	- CS high
*/