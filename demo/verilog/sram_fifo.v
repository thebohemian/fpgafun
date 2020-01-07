`include "../../common/iceclock/iceclock.v"
`include "../../common/clocks/counter_clock.v"
`include "../../common/uart_rx.v"
`include "../../common/sram_23lc1024.v"
`include "../../common/fifo_extmem.v"

/**
 * Module: top
 * 
 */
module top(
		input CLK_IN,
		
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input UART_DTR_i,		// flag read operation
		input UART_RX_i,
		
		output wire PIN_C16_o,	// SI
		output wire PIN_D16_o,	// SCK
		input wire PIN_E16_i,	// SO

		output wire PIN_F16_o,	// CSn
		output PIN_G16_o,
		output PIN_H16_o,
		
		output PIN_J15_o,
		output PIN_G14_o
		);

	wire [7:0] leds = { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 };
	wire [7:0] cables = { PIN_G14_o, PIN_J15_o, PIN_H16_o, PIN_G16_o, PIN_F16_o, PIN_E16_i, PIN_D16_o, PIN_C16_o };

	localparam SPEED = 60;
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	/*	wire sysclk = CLK_IN;
	 */	
	// Main clock speed is important for some modules to know.
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
	
	localparam SRAM_FREQ = 30_000_000;
	localparam SRAM_FREQ = 1_000_000;
	// watch the data transfer is slow motion
	//	localparam SRAM_FREQ = 2;
	
	// UART Baudrate
	localparam UART_FREQ = 115_200;
		
	// LC23A1024
	wire CSn = PIN_F16_o;
	
	// 1 - SO/SIO1
	wire SO = PIN_E16_i;
	
	// 2 - SIO2
	//	wire SIO2 = PIN_E16_o;
	
	// 3 - HOLDn/SIO3
	//	wire SIO3 = PIN_F16_o;
	
	// 4 - SCK
	wire SCK = PIN_D16_o;
	
	// 5 - SI/SIO0
	wire SI = PIN_C16_o;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire uart_received;
	
	// data to write to fifo
	localparam FIFO_SIZE = 1024*1024;
	localparam FIFO_MAX_BITS = $clog2(FIFO_SIZE);
	
	wire fifo_empty;
	wire fifo_full;
	wire [(FIFO_MAX_BITS-1):0] fifo_fill;
	
	// fifo read and write enable
	reg 		fifo_rd_en = 0;
	wire [7:0] fifo_out;
	
	reg			fifo_wr_en = 0;
	reg [7:0] fifo_wr_data = 0;
	
	wire fifo_completed;

	localparam STATE_IDLE = 0;
	localparam STATE_WAIT_WRITE_COMPLETED = 1;
	localparam STATE_WAIT_READ_COMPLETED = 2;
	reg [1:0] state = STATE_IDLE;
	
	reg [7:0] sram_data_read = 0;
	
	always @(posedge sysclk) begin
		fifo_rd_en <= 0;
		fifo_wr_en <= 0;
		
		case (state)
			STATE_IDLE: begin
				// When data from UART arrives, forward it to the FIFO
				if (uart_received) begin
					if (UART_DTR_i) begin
						fifo_rd_en <= 1;
						state <= STATE_WAIT_READ_COMPLETED;
					end else begin
						fifo_wr_data <= rx_data;
						fifo_wr_en <= 1;
						state <= STATE_WAIT_WRITE_COMPLETED;
					end
				end
			end
			STATE_WAIT_WRITE_COMPLETED:
				if (fifo_completed) begin
					state <= STATE_IDLE;
				end
			STATE_WAIT_READ_COMPLETED:
				if (fifo_completed) begin
					sram_data_read <= fifo_out;
					state <= STATE_IDLE;
				end
		endcase
	end

	// UART module which configures itself from the given system frequency
	// and target baudrate
	uart_rx #(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.BAUDRATE(UART_FREQ)
		)
		
		uart0
		(
			.rx(UART_RX_i),
			.rx_data(rx_data),
			.received(uart_received),
			
			.clk(sysclk)
		);
	
	counter_clock
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(SRAM_FREQ)
		)
		sram_clock0(
			.clk_out(sram_clk),
			.clk(sysclk)
		);
	
	wire sram_clk;
	wire sram_wr_en, sram_rd_en;
	wire [(FIFO_MAX_BITS-1):0] sram_address_in;
	wire [7:0] sram_data_in, sram_data_out;
	wire sram_completed;
	
	fifo_extmem
		#(
			.BITS(8),
			.SIZE(FIFO_SIZE))
		fifo1(
			.wr_en(fifo_wr_en),
			.wr_data(fifo_wr_data),
			
			.rd_en(fifo_rd_en),
			.rd_data(fifo_out),
			.completed(fifo_completed),
			
			.fifo_empty(fifo_empty),
			.fifo_full(fifo_full),
						
			.fill(fifo_fill),

			.mem_wr_en(sram_wr_en),
			.mem_rd_en(sram_rd_en),
			.mem_address(sram_address_in),
			.mem_data_out(sram_data_in),
			.mem_data_in(sram_data_out),
			.mem_completed(sram_completed),

			.clk(sysclk)
		);

	sram_23lc1024 sram0
		(
			.wr_en(sram_wr_en),
			.rd_en(sram_rd_en),
			
			.address_in(sram_address_in),
			.data_in(sram_data_in),
			.data_out(sram_data_out),
			
			.completed(sram_completed),
			
			.CSn(CSn),
			.SI(SI),
			.SO(SO),
			.SCK(SCK),
			
			.clk_ic(sram_clk),
			.clk(sysclk)
		);
	
	// The LEDs on the board itself reflect the byte received via UART
	//assign leds = sram_data_read;
	//assign leds = cables;
	assign leds = fifo_fill;
	
endmodule
