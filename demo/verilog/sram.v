//`include "../../common/iceclock/iceclock.v"
`include "../../common/clocks/counter_clock_enable.v"
`include "../../common/uart_rx.v"
`include "../../common/sram_23lc1024.v"

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
		
		input UART_RX_i,

		output PIN_C16_o,
		input PIN_D16_i,
		output PIN_E16_o,

		output PIN_F16_o,
		output PIN_G16_o,
		output PIN_H16_o,
		
		output PIN_J15_o,
		output PIN_G14_o
		);
	
	wire [7:0] cables = { PIN_G14_o, PIN_J15_o, PIN_H16_o, PIN_G16_o, PIN_F16_o, PIN_E16_o, PIN_D16_i, PIN_C16_o };

	localparam SPEED = 12;
	/*
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	*/
	
	// Main clock speed is important for some modules to know.
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
	
	localparam SRAM_FREQ = 1_000_0000;
	
	// UART Baudrate
	localparam UART_FREQ = 115_200;
		
	// LC23A1024
	wire CSn = PIN_C16_o;
	
	// 1 - SO/SIO1
//	wire SO = PIN_D16_i;
	
	// 2 - SIO2
	wire SIO2 = PIN_E16_o;
	
	// 3 - HOLDn/SIO3
	wire SIO3 = PIN_F16_o;
	
	// 4 - SCK
	wire SCK = PIN_G16_o;
	
	// 5 - SI/SIO0
	wire SI = PIN_H16_o;
	
	// Read/write enable for SRAM
	reg sram_rd_en = 0;
	reg sram_wr_en = 0;
	
	// clock enable for the sram (max 20Mhz)
	wire clk_en;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire uart_received;
	
	
	reg [23:0] address = 24'h0_00;
	reg [7:0] data = 0;
	
	wire [7:0] sram_data;
	wire sram_completed;
	
	localparam STATE_IDLE = 0;
	localparam STATE_WAIT_WRITE_COMPLETED = 1;
	localparam STATE_WAIT_READ_COMPLETED = 2;
	reg [1:0] state = STATE_IDLE;
		
	always @(posedge sysclk) begin
		sram_rd_en <= 0;
		sram_wr_en <= 0;
		
		case (state)
			STATE_IDLE: begin
				// When data from UART arrives, forward it to the SRAM
				if (uart_received) begin
					data <= rx_data;
					sram_wr_en <= 1;
					state <= STATE_WAIT_WRITE_COMPLETED;
				end
			end
			STATE_WAIT_WRITE_COMPLETED: begin
				if (sram_completed) begin
					sram_rd_en <= 0;
					state <= STATE_WAIT_READ_COMPLETED;
				end
			end
			STATE_WAIT_READ_COMPLETED: begin
				if (sram_completed) begin
					data <= sram_data;
					state <= STATE_IDLE;
				end
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
	
	counter_clock_enable
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(SRAM_FREQ)
		)
		sram_clock_enable0(
			.en(sram_clk_en),
			.clk(sysclk)
		);
	
	sram_23lc1024 sram0
		(
			.wr_en(sram_wr_en),
			.rd_en(sram_rd_en),
			
			.address_in(address),
			.data_in(data),
			.data_out(sram_data),
			
			.completed(sram_completed),
			
			.CSn(CSn),
			.SI(SI),
			.SO(SO),
			.SCK(SCK),
			
			.clk_en(sram_clk_en),
			.clk(sysclk)
		);
	
	// The LEDs on the board itself reflect the byte received via UART
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = data;
	//	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = cables;
	
endmodule
