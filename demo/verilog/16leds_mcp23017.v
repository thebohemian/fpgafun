`include "../../common/iceclock/iceclock.v"
`include "../../common/clocks/monotonic_counter.v"
`include "../../common/clocks/binary_divider_clock_enable.v"
`include "../../common/clocks/counter_clock.v"
`include "../../common/uart_rx.v"
`include "../../common/i2c_tx.v"

/**
 * Module: top
 * 
 * Controls 16 LEDs connected to a MCP 23017
 * IC. Which LEDs to light up depends on the byte
 * that is received via UART.
 * 
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
		output PIN_D16_o
		
		);
	
	// Using a PLL to set up the clock speed to something different
	// than the 12 MHz of CLK_IN.
	localparam SPEED = 18;
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
	// Main clock speed is important for some modules to know.
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
	localparam I2C_CLOCK_FREQ = 100_000;

	// UART Baudrate
	localparam UART_FREQ = 115_200;
	//localparam UART_FREQ = 230_400;
	//localparam UART_FREQ = 460_800;
	//localparam UART_FREQ = 921_600;
	//localparam UART_FREQ = 1_000_000;
	//localparam UART_FREQ = 3_000_000;
	//localparam UART_FREQ = 4_000_000;
	
	wire i2c_clock;
	
	// i2c pins
	wire sda;
	wire scl;
	
	// Assigment to FPGA pins
	assign PIN_C16_o = sda;
	assign PIN_D16_o = sck;
	
	// Read enable for shifting out
	reg rd_en = 0;
	reg [7:0] data;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire received;
	
	reg index = 0;
	
	always @(posedge sysclk) begin
		rd_en <= 0;
		
		// When data from UART arrives, forward it to the Shift Register
		if (received) begin
			data <= rx_data;
			index <= index + 1;
			rd_en <= 1;
		end
	end
	
	counter_clock
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(I2C_CLOCK_FREQ)
		)
		
		counter_clock0
		(
			.clk_out(i2c_clock),
			
			.clk(sysclk)
		);
		
	i2c_tx
		#(
			.BYTES(2)
		)
		mcp(
			.rd_en(rd_en),
			.data_in(data),
			.index_in(index),
			
			.sda(sda),
			.scl(scl),
			
			.i2c_clock(i2c_clock),
			.clk(sysclk)
		);
	
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
			.received(received),
			
			.clk(sysclk)
		);
	
	// The LEDs on the board itself reflect the byte received via UART
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = data;
	
endmodule
