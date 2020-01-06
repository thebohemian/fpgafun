`include "../../common/clocks/counter_clock.v"
`include "../../common/clocks/monotonic_counter.v"
`include "../../common/uart_rx.v"
`include "../../common/io_mcp23017.v"

/**
 * Module: top
 * 
 * Controls 16 LEDs connected to a MCP 23017
 * IC. Which LEDs to light up depends on the byte
 * that is received via UART.
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

		output PIN_B2_o,
		output PIN_C2_o
		
		);
	
	localparam SPEED = 12;
	wire sysclk = CLK_IN;
	
	// Main clock speed is important for some modules to know.
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
//	localparam I2C_CLOCK_FREQ = 100_000;
	localparam I2C_CLOCK_FREQ = 2;

	// UART Baudrate
	localparam UART_FREQ = 115_200;
	//localparam UART_FREQ = 230_400;
	//localparam UART_FREQ = 460_800;
	//localparam UART_FREQ = 921_600;
	//localparam UART_FREQ = 1_000_000;
	//localparam UART_FREQ = 3_000_000;
	//localparam UART_FREQ = 4_000_000;
	
	wire i2c_clock;
	wire [2:0] counter;
	reg setup = 0;
	
	// i2c pins
	wire sda;
	wire sck;
	
	// Assigment to FPGA pins
	assign PIN_B2_o = sda;
	assign PIN_C2_o = sck;
	
	// Write enable for shifting out
	reg wr_en = 0;
	reg [7:0] data;
	reg [7:0] register_address;
	
	// Data from UART and signalisation
	wire [7:0] rx_data;
	wire received;
	
	always @(posedge sysclk) begin
		wr_en <= 0;
		
		if (counter == 7
				&& !setup) begin
				data <= 0;
				register_address <= 8'h00;
				wr_en <= 1;
		end
		
		// When data from UART arrives, forward it to the IO Extender
		if (received) begin
			data <= rx_data;
			register_address <= 8'h12;
			wr_en <= 1;
		end
	end
	
	monotonic_counter
		#(
			.BITS(3)
		)
		cnt0(
			.value(counter),
			.clk(sysclk)
		);
	
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
		
	io_mcp23017
		io0(
			.wr_en(wr_en),
			.hardware_address(3'b000),
			.register_address(register_address),
			.data_in(data),
			
			.SDA(sda),
			.SCK(sck),
			
			.clk_ic(i2c_clock),
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
