`include "spi_rx.v"
`include "spi_tx2.v"

module sram_23lc1024 
		(
		input wr_en,	// write
		input rd_en,	// read
		
		input [23:0] address_in,
		input [7:0] data_in,
		output [7:0] data_out,
		
		output reg completed,
		
		output reg CSn,
		output HOLDn,
			
		output SI,
		input SO,
			
		output SCK,

		input clk_en,
		input clk
		);
	
	localparam STATE_IDLE = 0;
	localparam STATE_READ_WAIT_SENT_COMMAND = 1;
	localparam STATE_READ_WAIT_SENT_ADDRESS_BYTE_1 = 2;
	localparam STATE_READ_WAIT_SENT_ADDRESS_BYTE_2 = 3;
	localparam STATE_READ_WAIT_SENT_ADDRESS_BYTE_3 = 4;
	localparam STATE_READ_WAIT_RECEIVED_DATA_BYTE = 5;
	localparam STATE_WRITE_WAIT_SENT_COMMAND = 6;
	localparam STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_1 = 7;
	localparam STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_2 = 8;
	localparam STATE_WRITE_WAIT_SENT_ADDRESS_BYTE_3 = 9;
	localparam STATE_WRITE_WAIT_SENT_DATA_BYTE = 10;
	reg [3:0] state = STATE_IDLE;
	
	initial CSn <= 1;
	
	reg [7:0] data;
	reg [23:0] address;
	
	reg tx_rd_en = 0;
	reg [7:0] tx_data = 0;
	wire tx_sent;
	
	reg rx_rd_en = 0;
	wire [7:0] rx_data;
	wire rx_received;
	
	always @ (posedge clk) begin
		completed <= 0;
		tx_rd_en <= 0;
		rx_rd_en <= 0;
		
		case (state)
			STATE_IDLE:
				if (rd_en) begin
					address <= address_in;
					tx_rd_en <= 1;
					tx_data <= 8'h03;	// read command
					
					state <= STATE_READ_WAIT_SENT_COMMAND;
					CSn <= 0;
				end else if (wr_en) begin
					address <= address_in;
					data <= data_in;
					
					tx_rd_en <= 1;
					tx_data <= 8'h02;	// write command
					state <= STATE_WRITE_WAIT_SENT_COMMAND;
					CSn <= 0;
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
					state <= STATE_IDLE;
					CSn <= 1;
					completed <= 1;
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
					state <= STATE_IDLE;
					CSn <= 1;
					completed <= 1;
				end
		endcase
	end
	
	assign data_out = data;
	
	wire tx_SCK, rx_SCK;
	wire SCK = tx_SCK | rx_SCK;
	
	spi_tx tx(
			.rd_en(tx_rd_en),
			.data_in(tx_data),
			
			.sent(tx_sent),
			
			.serial_out(SI),
			.serial_clock(tx_SCK),
			
			.clk_en(clk_en),
			.clk(clk)
		);
	
	spi_rx rx(
			.rd_en(rx_rd_en),
			.data_out(rx_data),
			
			.received(rx_received),
			
			.serial_in(SO),
			.serial_clock(rx_SCK),
			
			.clk_en(clk_en),
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