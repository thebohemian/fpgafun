`include "../common/uart_rx.v"
`include "../common/clocks/counter_clock_enable.v"
`include "../common/sid/sid8580.v"
`include "../common/fo_sigma_delta_dac.v"

module top(
		input CLK_IN,
		
		input UART_RX_i,
		
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
	
	localparam IDEAL_SID_CLOCK_FREQ = 1_000_000;
	localparam PAL_SID_CLOCK_FREQ = 985_250;
	localparam NTSC_SID_CLOCK_FREQ = 1_022_730;
	localparam SID_CLOCK_FREQ = IDEAL_SID_CLOCK_FREQ;
	
	localparam DAC_CLOCK_FREQ = 48_000;
	
	localparam BAUDRATE = 3_000_000;

	localparam RX_WAIT_ADDR = 0;
	localparam RX_WAIT_DATA = 1;
	
	// SID
	reg        sid_reset = 1;				// set when to reset SID
	wire       sid_ce;						// 1Mhz clock of the SID
	
	reg        sid_data_present;			// set when data for SID is available
	reg [4:0]  sid_addr;					// addr
	reg [7:0]  sid_data;					// data
	reg        sid_write_en = 0;			// set when writing to SID is possible

	// DAC
	wire [17:0] audio_dat;					// 18bit audio data SID output and DAC input
	wire dac_ce;
	
	// UART
	wire		rx_received;
	reg	[7:0]	rx_data;
	reg			rx_state = RX_WAIT_ADDR;

	always @(posedge CLK_IN) begin
		sid_write_en <= 0;
		
		if (rx_received) begin
			// Unresets SID upon first byte from UART
			sid_reset <= 0;
			
			case (rx_state)
				RX_WAIT_ADDR: begin
					sid_addr <= rx_data[4:0];
					rx_state <= RX_WAIT_DATA;
				end
				RX_WAIT_DATA: begin
					sid_data <= rx_data;
					rx_state <= RX_WAIT_ADDR;
					
					sid_write_en <= 1;
				end
			endcase
		end
	end
	
	counter_clock_enable
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(DAC_CLOCK_FREQ),
		)
		dac_clock_enable
		(
			.en(dac_ce),
			
			.clk(CLK_IN)
		);
		
	counter_clock_enable
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(SID_CLOCK_FREQ),
		)
		sid_clock_enable
		(
			.en(sid_ce),
			
			.clk(CLK_IN)
		);

	uart_rx
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.BAUDRATE(BAUDRATE)
		)
		uart0(
			.rx(UART_RX_i),
			.rx_data(rx_data),
			.received(rx_received),
			
			.clk(CLK_IN)
		);

	sid8580 sid0(
			.ce_1m(sid_ce),

			.we(sid_write_en),
			.addr(sid_addr),
			.data_in(sid_data),
			
			.audio_data(audio_dat),
			
			.reset(sid_reset),
			
			.clk(CLK_IN)
		);

	fo_sigma_delta_dac
		#(.BITS(18)) dac1 (
			.in(audio_dat),
			.out(GPIO_AUDIO),
			
			.clk(dac_ce)
		);

	// LEDs show the data byte
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = sid_data;

endmodule
