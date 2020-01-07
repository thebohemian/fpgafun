`include "../common/uart_rx.v"
`include "../common/fo_sigma_delta_dac.v"
`include "../common/clocks/counter_clock_enable.v"
`include "memory.v"
`include "../common/fifo.v"

module top(
		input CLK_IN,
		
		input UART_RX_i,
		input UART_DTR_i,
		input UART_RTS_i,
		
		output UART_CTS_o,
		output UART_DSR_o,
		output UART_DCD_o,
		
		output GPIO_AUDIO_L,
		output GPIO_AUDIO_R,
		
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		output wire PIN_P16_o,
		output wire PIN_P15_o,
		output wire PIN_N16_o,
		output wire PIN_M15_o);
	
	// combines all leds under one name
	wire [7:0] leds;
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = leds;

	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	// UART frequency/speed
	localparam BAUDRATE = 3_000_000;
	
	// FIFO frequency (frequency of the PCM samples) 
	localparam FIFO_CLOCK_FREQ = 44_100;
	
	// DAC frequency (Sigma-Delta works best when oversampling many times)
	localparam DAC_CLOCK_FREQ = 64*48_000;
	
	// byte transfer states
	localparam DAC_BITS = 8;
	localparam FIFO_BITS = 16;

	localparam RX_WAIT_DATA_0 = 0;
	localparam RX_WAIT_DATA_1 = 1;
	
	wire		rx_received;
	reg	[7:0]	rx_data;
	reg [7:0]	rx_audio_buf = 0;
	reg			rx_state = RX_WAIT_DATA_0;
	reg			fifo_wr_en = 0;

	// data to write to fifo
	localparam FIFO_SIZE = 8192;
	localparam FIFO_MAX_BITS = $clog2(FIFO_SIZE);
	wire fifo_empty;
	wire fifo_full;
	wire [(FIFO_MAX_BITS-1):0] fifo_fill;
	reg [(FIFO_BITS-1):0] fifo_wr_data = 0;
	
	wire fifo_almost_empty;
	wire fifo_almost_full;
	
	assign fifo_almost_empty = (fifo_fill <= 3*(FIFO_SIZE / 10));
	assign fifo_almost_full = (fifo_fill >= FIFO_SIZE - 5*(FIFO_SIZE / 10));
	
	// data from fifo going to dac
	wire [(FIFO_BITS-1):0] fifo_out;
	wire fifo_rd_en;
	
	wire dac_ce;
	wire [(DAC_BITS-1):0] dac_l_in;
	wire [(DAC_BITS-1):0] dac_r_in;
	wire dac_reset;
	
	// play output
	assign dac_l_in = fifo_out[15:8];
	assign dac_r_in = fifo_out[7:0];
	
	// reset dac when fifo invalid
	assign dac_reset = fifo_empty;
			
	always @(posedge CLK_IN) begin
		fifo_wr_en <= 0;
		
		if (rx_received) begin
			case (rx_state)
				RX_WAIT_DATA_0: begin
					rx_audio_buf <= rx_data;
					
					rx_state <= RX_WAIT_DATA_1;
				end
				RX_WAIT_DATA_1: begin
					fifo_wr_data <= { rx_data, rx_audio_buf };
					fifo_wr_en <= 1;
					
					rx_state <= RX_WAIT_DATA_0;
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
			.COUNTER_FREQ(FIFO_CLOCK_FREQ),
		)
		fifo_clock_enable
		(
			.en(fifo_rd_en),
			
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
		
	fifo #(.BITS(FIFO_BITS), .SIZE(FIFO_SIZE))
		fifo1(
			.wr_en(fifo_wr_en),
			.wr_data(fifo_wr_data),
			
			.rd_en(fifo_rd_en),
			.rd_data(fifo_out),
			
			.fifo_empty(fifo_empty),
			.fifo_full(fifo_full),
						
			.fill(fifo_fill),
				
			.clk(CLK_IN)
		);

	// left channel dac
	fo_sigma_delta_dac #(.BITS(DAC_BITS), .INV(1))
		dac_l (
			.reset(dac_reset),
			.in(dac_l_in),
			.out(GPIO_AUDIO_L),
			
			.clk(dac_ce)
		);
	
	// right channel dac
	fo_sigma_delta_dac #(.BITS(DAC_BITS), .INV(1))
		dac_r (
			.reset(dac_reset),
			.in(dac_r_in),
			.out(GPIO_AUDIO_R),
			
			.clk(dac_ce)
		);
	
	assign leds = fifo_fill[(FIFO_MAX_BITS-1):(FIFO_MAX_BITS-9)];
	
	assign PIN_P16_o = fifo_empty;
	assign PIN_P15_o = fifo_full;

	assign PIN_N16_o = fifo_almost_empty;
	assign PIN_M15_o = fifo_almost_full;
	
	assign UART_CTS_o = ~fifo_almost_empty;
	assign UART_DSR_o = ~fifo_almost_full;
	
endmodule
