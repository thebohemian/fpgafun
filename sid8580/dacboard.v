`include "rxuart.v"
`include "sigma_delta_dac.v"
`include "fo_sigma_delta_dac.v"

module dacboard(
		input CLK_IN,
		input RS232_RX_i,
		output GPIO_AUDIO_L,
		output GPIO_AUDIO_R,
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2);

	localparam MAIN_CLOCK_FREQ = 12_000_000;
	//	localparam UART_FREQ = 115_200;
	localparam UART_FREQ = 230_400;
//	localparam UART_FREQ = 460_800;
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;

	//	localparam DAC_CLOCK_FREQ = 11_025;
	//	localparam DAC_CLOCK_FREQ = 22_050;
	//	localparam DAC_CLOCK_FREQ = 44_100;
	localparam DAC_CLOCK_FREQ = 48_000;
	localparam DAC_COUNTER = MAIN_CLOCK_FREQ / DAC_CLOCK_FREQ;
	reg [31:0] dac_counter = DAC_COUNTER - 1;
	reg [1:0] dac_reset_counter = 2; 
	wire dac_reset;

	localparam RX_WAIT_DATA_0 = 0;
	localparam RX_WAIT_DATA_1 = 1;
	localparam RX_WAIT_DATA_2 = 2;
	localparam RX_DAC_DATA_PRESENT = 3;
	
	localparam BITS = 16;
	
	wire		rx_received;
	reg	[7:0]	rx_data;
	reg [7:0]	rx_audio_buf = 0;
	reg			rx_second_byte = 0;

	reg [(BITS-1):0] audio_dat = 16'd1;					// 8bit audio data output
	
	always @(posedge CLK_IN) begin
		dac_counter <= (dac_counter > 0) ? dac_counter - 1 : DAC_COUNTER - 1;
	end
	
	assign dac_reset = dac_reset_counter == 1;
	
	assign dac_ce = dac_counter == 0;

	always @(posedge CLK_IN) begin
		dac_reset_counter <= dac_reset_counter > 0 ? dac_reset_counter - 1 : 0;
	end

	always @(negedge CLK_IN) begin
		if (rx_received) begin
			if (rx_second_byte) begin
				audio_dat <= { rx_data, rx_audio_buf };
				rx_second_byte <= 0;
			end
			else begin
				rx_audio_buf <= rx_data;
				rx_second_byte <= 1;
			end
		end
	end
	
	rxuart #(.CLOCK_DIVIDE(UART_COUNTER/4)) rxuart(
			.rx(RS232_RX_i),
			.rx_byte(rx_data),
			.received(rx_received),
			.clk(CLK_IN)
		);

	fo_sigma_delta_dac #(.BITS(16)) fo_dac1 (
			.in(audio_dat),
			.out(GPIO_AUDIO_L),
			
			.clk(dac_ce)
		);

	sigma_delta_dac #(.MSBI(15), .INV(1)) dac1 (
			.in(audio_dat),
			.out(GPIO_AUDIO_R),
			.reset(dac_reset),
			
			.clk(dac_ce)
		);

	// LEDs show the data byte
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = audio_dat[15:8];

endmodule
