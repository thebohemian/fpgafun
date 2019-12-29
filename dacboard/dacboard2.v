`include "../common/rxuart.v"
`include "../common/sigma_delta_dac.v"

module top(
		input CLK_IN,
		input RS232_RX_i,
		output GPIO_AUDIO,
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2);

	localparam MAIN_CLOCK_FREQ = 12_000_000;
	localparam UART_FREQ = 115_200;
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;

	localparam DAC_CLOCK_FREQ = 11_025;
	localparam DAC_COUNTER = MAIN_CLOCK_FREQ / DAC_CLOCK_FREQ;
	reg [31:0] dac_counter = DAC_COUNTER - 1;
	reg [1:0] dac_reset_counter = 2; 
	wire dac_reset;

	localparam RX_WAIT_DATA_0 = 0;
	localparam RX_WAIT_DATA_1 = 1;
	localparam RX_WAIT_DATA_2 = 2;
	localparam RX_DAC_DATA_PRESENT = 3;
	
	wire		rx_received;
	reg	[7:0]	rx_data;
	reg	[2:0]	rx_state = RX_WAIT_DATA_0;
//	reg [17:0]	rx_audio_buf = 0;
	reg [7:0]	rx_audio_buf = 0;

//	reg signed [17:0] audio_dat = 18'd2160000;					// 18bit audio data output
	reg [7:0] audio_dat = 8'd1;					// 8bit audio data output
	
	always @(posedge CLK_IN) begin
		dac_counter <= (dac_counter > 0) ? dac_counter - 1 : DAC_COUNTER - 1;
	end
	
	assign dac_reset = dac_reset_counter == 1;
	
	assign dac_ce = dac_counter == 0;

	always @(posedge CLK_IN) begin
		if (rx_state == RX_DAC_DATA_PRESENT) begin
			// lets values flow into DAC
//			audio_dat <= rx_audio_buf;
		end
		dac_reset_counter <= dac_reset_counter > 0 ? dac_reset_counter - 1 : 0;
	end
	
	always @(negedge CLK_IN) begin
		if (rx_received) begin
			case (rx_state)
				RX_WAIT_DATA_0: begin
					//rx_audio_buf[7:0] <= rx_data;
//					rx_state <= RX_WAIT_DATA_1;
					audio_dat <= rx_data;
					rx_state <= RX_DAC_DATA_PRESENT;
				end
/*				
				RX_WAIT_DATA_1: begin
					rx_audio_buf[15:8] <= rx_data;
					rx_state <= RX_WAIT_DATA_2;
				end
				RX_WAIT_DATA_2: begin
					rx_audio_buf[17:16] <= rx_data[1:0];
					rx_state <= RX_DAC_DATA_PRESENT;
				end
*/				
			endcase
		end
		else if (rx_state == RX_DAC_DATA_PRESENT) begin
			rx_state <= RX_WAIT_DATA_1;
		end
	end
	
	rxuart #(.CLOCK_DIVIDE(UART_COUNTER/4)) rxuart(
			.rx(RS232_RX_i),
			.rx_byte(rx_data),
			.received(rx_received),
			.clk(CLK_IN)
		);

//	sigma_delta_dac #(.MSBI(17), .INV(0)) dac1 (
	sigma_delta_dac #(.MSBI(7), .INV(0)) dac1 (
			.in(audio_dat),
			.out(GPIO_AUDIO),
			.reset(dac_reset),
			
			.clk(dac_ce)
		);

	// LEDs show the data byte
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = audio_dat;

endmodule
