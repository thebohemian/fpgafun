`include "rxuart.v"
`include "sid8580.v"
`include "fo_sigma_delta_dac.v"

module sidnboard2(
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
	localparam UART_FREQ = 230_400;
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;

	localparam DAC_CLOCK_FREQ = 48_000;
	localparam DAC_COUNTER = MAIN_CLOCK_FREQ / DAC_CLOCK_FREQ;
	reg [31:0] dac_counter = DAC_COUNTER - 1;

	reg [7:0] resetn_counter = 2;
	wire RSTn_i;

	localparam RX_WAIT_ADDR = 0;
	localparam RX_WAIT_DATA = 1;
	localparam RX_SID_DATA_PRESENT = 2'b10;
	
	/* FPGA runs at 12Mhz, SID at 1Mhz. So we have to let 12 main
	 * clock cycles pass before we have one clock cycle for the SID
	 */
	localparam SID_MAIN_CLK_CYCLES = 12;
	
	localparam COUNTER_WIDTH = 8;
	reg [COUNTER_WIDTH-1:0] sid_wait_cycles;		// no of SID cycles the sid should do nothing

	reg        sid_reset;					// set when to reset SID
	reg [3:0] sid_clk_delay;				// amount of main clock cycles to wait until talking to SID (makes it run at 1Mhz) 
	wire       sid_ce_1m;					// 1Mhz clock of the SID
	
	wire		rx_received;
	reg	[7:0]	rx_data;
	reg	[1:0]	rx_state = RX_WAIT_ADDR;

	reg        sid_data_present;			// set when data for SID is available
	reg [4:0]  sid_addr;					// addr
	reg [7:0]  sid_data;					// data
	reg        sid_write_en;				// set when writing to SID is possible

	wire [17:0] audio_dat;					// 18bit audio data output
	
	reg extfilter_en;

	// generates a 1Mhz signal for the SID (original speed)
	assign sid_ce_1m = sid_clk_delay == 0;
	
	always @(posedge CLK_IN) begin
		resetn_counter <= (resetn_counter > 0) ? resetn_counter - 1 : 0;
	end
	
	assign RSTn_i = (resetn_counter == 0);

	always @(posedge CLK_IN) begin
		dac_counter <= (dac_counter > 0) ? dac_counter - 1 : DAC_COUNTER - 1;
	end
	
	assign dac_ce = dac_counter == 0;

	always @(posedge CLK_IN) begin
		if (!RSTn_i) begin

			// SID
			sid_write_en <= 0;
			
			extfilter_en <= 0;
					
			// cause reset
			sid_reset <= 1;
			
			// SID clock
			sid_clk_delay <= SID_MAIN_CLK_CYCLES - 1;
		end
		else begin
			if (rx_state == RX_SID_DATA_PRESENT) begin
				// lets values flow into SID
				sid_write_en <= 1;
			end
			case (sid_clk_delay)
				// start of SID cycle: Read from ROM or wait
				(SID_MAIN_CLK_CYCLES-1): begin
				end
				0: begin
					// reset ends together with end of write cycle only 
					sid_reset <= 0;
		
					// clears writing to SID
					sid_write_en <= 0;
				end
			endcase
			sid_clk_delay <= (sid_clk_delay > 0) ? sid_clk_delay - 1 : SID_MAIN_CLK_CYCLES - 1;
		end
	end
	
	always @(negedge CLK_IN) begin
		if (rx_received) begin
			case (rx_state)
				RX_WAIT_ADDR: begin
					sid_addr <= rx_data[4:0];
					rx_state <= RX_WAIT_DATA;
				end
				RX_WAIT_DATA: begin
					sid_data <= rx_data;
					rx_state <= RX_SID_DATA_PRESENT;
				end
			endcase
		end
		else if (sid_clk_delay == SID_MAIN_CLK_CYCLES-1 && rx_state == RX_SID_DATA_PRESENT) begin
			rx_state <= RX_WAIT_ADDR;
		end
	end
	
	rxuart #(.CLOCK_DIVIDE(UART_COUNTER/4)) rxuart(
			.rx(UART_RX_i),
			.rx_byte(rx_data),
			.received(rx_received),
			.clk(CLK_IN)
		);

	sid8580 sid0(
			.we(sid_write_en),
			.addr(sid_addr),
			.data_in(sid_data),
			.audio_data(audio_dat),
			.ce_1m(sid_ce_1m),
			.extfilter_en(extfilter_en),
			.reset(sid_reset),
			.clk(CLK_IN)
		);

	fo_sigma_delta_dac #(.BITS(16)) dac1 (
			.in(audio_dat[17:2]),
			.out(GPIO_AUDIO),
			
			.clk(dac_ce)
		);

	// LEDs show the data byte
	//	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = {0,0,0, sid_addr };
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = sid_data;

endmodule
