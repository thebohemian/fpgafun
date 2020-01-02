`include "../common/iceclock/iceclock.v"
`include "../common/uart_rx.v"
`include "../common/fo_sigma_delta_dac.v"
`include "../common/clocks/counter_clock_enable.v"
`include "memory.v"
`include "fifo.v"

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
		
		output wire P16_o,
		output wire P15_o,
		output wire N16_o,
		output wire M15_o);
	
	// combines all leds under one name
	wire [7:0] leds;
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = leds;

//	localparam SPEED = 162;	// -> weirdest effect ever
//	localparam SPEED = 128; // -> also great effect
	localparam SPEED = 120;
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
	
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
	// UART frequency/speed
	localparam BAUDRATE = 3_000_000;

	// FIFO frequency (frequency of the PCM samples) 
	localparam FIFO_CLOCK_FREQ = 44_100;
	
	// DAC frequency (Sigma-Delta works best when oversampling many times)
//	localparam DAC_CLOCK_FREQ = 64*48_000;
	localparam DAC_CLOCK_FREQ = MAIN_CLOCK_FREQ;
	
	// byte transfer states
	localparam DAC_BITS = 16;
	localparam FIFO_BITS = 32;

	localparam RX_WAIT_DATA_0 = 0;
	localparam RX_WAIT_DATA_1 = 1;
	localparam RX_WAIT_DATA_2 = 2;
	localparam RX_WAIT_DATA_3 = 3;
	
	wire		rx_received;
	reg	[7:0]	rx_data;
	reg [7:0]	rx_audio_buf = 0;
	reg [1:0]	rx_state = RX_WAIT_DATA_0;
	
	wire		fifo_rd_en;
	reg			fifo_wr_en = 0;

	// data to write to fifo
	localparam FIFO_SIZE = 4096;
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
	
	wire [(DAC_BITS-1):0] dac_l_in;
	wire [(DAC_BITS-1):0] dac_r_in;
	wire dac_reset;
	
	// play output
	assign dac_l_in = fifo_out[31:16];
	assign dac_r_in = fifo_out[15:0];
	
	// reset dac when fifo invalid
	assign dac_reset = fifo_empty;
			
	always @(posedge sysclk) begin
		fifo_wr_en <= 0;
		
		if (rx_received) begin
			case (rx_state)
				RX_WAIT_DATA_0: begin
					fifo_wr_data[23:16] <= rx_data;
					
					rx_state <= RX_WAIT_DATA_1;
				end
				RX_WAIT_DATA_1: begin
					fifo_wr_data[31:24] <= rx_data;
					
					rx_state <= RX_WAIT_DATA_2;
				end
				RX_WAIT_DATA_2: begin
					fifo_wr_data[7:0] <= rx_data;
					
					rx_state <= RX_WAIT_DATA_3;
				end
				RX_WAIT_DATA_3: begin
					fifo_wr_data[15:8] <= rx_data;
					fifo_wr_en <= 1;
					
					rx_state <= RX_WAIT_DATA_0;
				end
			endcase
		end
	end
	
	counter_clock_enable
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(FIFO_CLOCK_FREQ),
		)
		fifo_clock_enable
		(
			.en(fifo_rd_en),
			
			.clk(sysclk)
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
			
			.clk(sysclk)
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
				
			.clk(sysclk)
		);

	// left channel dac
	fo_sigma_delta_dac #(.BITS(DAC_BITS), .INV(1))
		dac_l (
			.reset(dac_reset),
			.in(dac_l_in),
			.out(GPIO_AUDIO_L),
			
			.clk(sysclk)
		);
	
	// right channel dac
	fo_sigma_delta_dac #(.BITS(DAC_BITS), .INV(1))
		dac_r (
			.reset(dac_reset),
			.in(dac_r_in),
			.out(GPIO_AUDIO_R),
			
			.clk(sysclk)
		);
	
	assign leds = fifo_fill[(FIFO_MAX_BITS-1):(FIFO_MAX_BITS-9)];
	
	assign P16_o = fifo_empty;
	assign P15_o = fifo_full;

	assign N16_o = fifo_almost_empty;
	assign M15_o = fifo_almost_full;
	
	assign UART_CTS_o = ~fifo_almost_empty;
	assign UART_DSR_o = ~fifo_almost_full;
	
endmodule
