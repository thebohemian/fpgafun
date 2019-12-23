`include "../common/rxuart.v"
`include "../common/sid/sid8580.v"
`include "../common/fo_sigma_delta_dac.v"

module sidnboard2dual(
		input CLK_IN,
		input RSTn_i,
		input RS232_RX_i,
		output GPIO_AUDIO_L,
		output GPIO_AUDIO_R
		);
	
	localparam DELAY_CMD = 5'h1f;

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
	reg	[1:0]	rx_state;

	reg        sid_data_present;			// set when data for SID is available
	reg [4:0]  sid_addr;					// addr
	reg [7:0]  sid_data;					// data
	reg        sid_write_en;				// set when writing to SID is possible

	wire [17:0] audio_data0;				// 18bit audio data output
	wire [17:0] audio_data1;				// 18bit audio data output
	
	reg	[2:0]	dac_reset_counter;
	wire dac_reset;
	
	reg extfilter_en;

	// generates a 1Mhz signal for the SID (original speed)
	assign sid_ce_1m = sid_clk_delay > ((SID_MAIN_CLK_CYCLES/2)-1);
	
	// DAC reset is held until there is proper audio data coming out of the SID
	// otherwise it will mess up the internal registers
	assign dac_reset = dac_reset_counter > 0;
	
	always @(posedge CLK_IN) begin
		if (!RSTn_i) begin

			// SID
			sid_write_en <= 0;
			
			extfilter_en <= 0;
					
			// cause reset
			sid_reset <= 1;
			dac_reset_counter <= 3;
			
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
					
					// keeps dac reset for a few cycles
					if (dac_reset_counter > 0)
						dac_reset_counter <= dac_reset_counter - 1;
				end
			endcase
			sid_clk_delay <= (sid_clk_delay > 0) ? sid_clk_delay - 1 : SID_MAIN_CLK_CYCLES - 1;
		end
	end
	
	always @(negedge CLK_IN) begin
		if(!RSTn_i) begin
			rx_state <= RX_WAIT_ADDR;
		end
		else if (rx_received) begin
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
	
	rxuart rxuart(
			.rx(RS232_RX_i),
			.rx_byte(rx_data),
			.received(rx_received),
			.reset(sid_reset),
			.clk(CLK_IN)
		);

	sid8580 sid0(
			.we(sid_write_en),
			.addr(sid_addr),
			.data_in(sid_data),
			.audio_data(audio_data0),
			.ce_1m(sid_ce_1m),
			.extfilter_en(extfilter_en),
			.reset(sid_reset),
			.clk(CLK_IN)
			);

	sigma_delta_dac dac0(
			.in(audio_data0),
			.out(GPIO_AUDIO_L),
			.reset(dac_reset),
			
			.clk(CLK_IN)
		);

	sid8580 sid1(
			.we(sid_write_en),
			.addr(sid_addr),
			.data_in(sid_data),
			.audio_data(audio_data1),
			.ce_1m(sid_ce_1m),
			.extfilter_en(extfilter_en),
			.reset(sid_reset),
			.clk(CLK_IN)
		);

	sigma_delta_dac dac1(
			.in(audio_data1),
			.out(GPIO_AUDIO_R),
			.reset(dac_reset),
			
			.clk(CLK_IN)
		);

endmodule
