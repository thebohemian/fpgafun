`include "../../common/iceclock/iceclock.v"
`include "../../common/uart_rx.v"

/**
 * Module: top
 * 
 * Controls 8 LEDs connected to a NXP 74HC595N
 * IC. Which LEDs to light up depends on the byte
 * that is received via UART.
 * 
 * Put a NCP 74HC595N on a breadboard,
 * wire 8 LEDs to its Q0..Q7 pins, connect
 * DS, ST_CP and SH_CP with the FPGA.
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
		output PIN_D16_i,
		output PIN_E16_o,

		output PIN_F16_o,
		output PIN_G16_o,
		output PIN_H16_o,
		
		output PIN_J15_o,
		output PIN_G14_o
		);
	
	// Using a PLL to set up the clock speed to something different
	// than the 12 MHz of CLK_IN.
	localparam SPEED = 18;
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
	// Main clock speed is important for some modules to know.
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
	
	// UART Baudrate
	localparam UART_FREQ = 115_200;
	
	reg [7:0] cables; 
	reg nc0;
	assign { PIN_G14_o, PIN_J15_o, PIN_H16_o, PIN_G16_o, PIN_F16_o, PIN_E16_o, nc0, PIN_C16_o } = cables;
	
	// LC23A1024
	// 0 - CSn
	// 1 - SO/SIO1
	// 2 - SIO2
	// 3 - HOLDn/SIO3
	// 4 - SCK
	// 5 - SI/SIO0
	
	// Read enable for shifting out
	reg rd_en = 0;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire received;
		
	always @(posedge sysclk) begin
		rd_en <= 0;
		
		// When data from UART arrives, forward it to the Shift Register
		if (received) begin
			cables <= rx_data;
			
			rd_en <= 1;
		end
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
			.received(received),
			
			.clk(sysclk)
		);
	
	// The LEDs on the board itself reflect the byte received via UART
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = { cables[7:2], PIN_D16_i, cables[0] };
	
endmodule
