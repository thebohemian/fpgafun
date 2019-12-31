`include "../../common/iceclock/iceclock.v"
`include "../../common/clocks/discrete_binary_divider_clock_enable.v"
`include "../../common/shift_4094be.v"
`include "../../common/uart_rx.v"

/**
 * Module: top
 * 
 * Controls 8 LEDs connected to a TI 4094BE
 * IC. Which LEDs to light up depends on the byte
 * that is received via UART.
 * 
 * Put a 4094BE on a breadboard,
 * wire 8 LEDs to its Q0..Q7 pins, connect
 * STROBE, DATA and CLOCK with the FPGA.
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
		output PIN_D16_o,
		output PIN_E16_o
		
		);
	
	// Using a PLL to set up the clock speed to something different
	// than the 12 MHz of CLK_IN.
	localparam SPEED = 12;
	wire       sysclk = CLK_IN;							
	//wire       locked;							
	//iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
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
	
	// Write enable for the shift register (set up later)
	wire shift_reg_wr_en;
	
	// Shift register pins
	wire sr_strobe; // strobe
	wire sr_data;	// serial data input
	wire sr_clock; // clock
	
	// Assigment to FPGA pins
	assign PIN_E16_o = sr_strobe;
	assign PIN_D16_o = sr_data;
	assign PIN_C16_o = sr_clock;
	
	// Read enable for shifting out
	reg rd_en = 0;
	reg [7:0] data;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire received;
	
	always @(posedge sysclk) begin
		rd_en <= 0;
		
		// When data from UART arrives, forward it to the Shift Register
		if (received) begin
			data <= rx_data;
			rd_en <= 1;
		end
	end
	
	discrete_binary_divider_clock_enable
		#(
			.N(2)
		)
		bindiv_clock0
		(
			.en(shift_reg_wr_en),
			
			.clk(sysclk)
		);
		
	wire[2:0] counter_out;
	wire[1:0] state_out;
	
	// The shift register itself.
	shift_4094be
		sr0(
			.rd_en(rd_en),
			.data_in(data),
			
			.wr_en(shift_reg_wr_en),
			.data_out(sr_data),
			.strobe(sr_strobe),

			.register_clock(sr_clock),
			
			.clk(sysclk),
			
			.counter_out(counter_out),
			.state_out(state_out)
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
//	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = { sr_strobe, sr_data, shift_reg_wr_en, state_out, counter_out };
	
endmodule
