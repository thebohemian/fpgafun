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

		output reg PIN_C16_o,
		output reg PIN_D16_o,
		output reg PIN_E16_o,

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
	//localparam UART_FREQ = 230_400;
	//localparam UART_FREQ = 460_800;
	//localparam UART_FREQ = 921_600;
	//localparam UART_FREQ = 1_000_000;
	//localparam UART_FREQ = 3_000_000;
	//localparam UART_FREQ = 4_000_000;
	
	reg [7:0] cables; 
//	assign { PIN_C16, PIN_D16, PIN_E16, PIN_F16, PIN_G16, PIN_H16, PIN_J15, PIN_G14 } = cables; 
//	assign { PIN_G14, PIN_J15, PIN_H16, PIN_G16, PIN_F16, PIN_E16, PIN_D16, PIN_C16 } = cables; 
	
	// Read enable for shifting out
	reg rd_en = 0;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire received;
	
	wire pin_clock;
	
	always @(posedge sysclk) begin
		rd_en <= 0;
		
		// When data from UART arrives, forward it to the Shift Register
		if (received) begin
			cables <= rx_data;
			PIN_C16_o <= rx_data[0];
			PIN_D16_o <= rx_data[1];
			PIN_E16_o <= rx_data[2];
			
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
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = cables;
	
endmodule
