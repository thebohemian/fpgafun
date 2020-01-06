`include "../common/iceclock/iceclock.v"
`include "../common/uart_rx.v"
`include "../common/fo_sigma_delta_dac.v"
`include "../common/clocks/counter_clock_enable.v"
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
		
		output wire P16_o,
		output wire P15_o,
		output wire N16_o,
		output wire M15_o);
	
	// combines all leds under one name
	wire [7:0] leds;
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = leds;

	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	// UART frequency/speed
	localparam BAUDRATE = 3_000_000;
	wire		sysclk = CLK_IN;

	// FIFO frequency (frequency of the PCM samples) 
	localparam FIFO_CLOCK_FREQ = 44_100;
	
	// DAC frequency (Sigma-Delta works best when oversampling many times, IOW run as fast as possible)
	//localparam DAC_SPEED = 276;	// still works but bad quality because of signals in the FPGA not reaching destinations in time
	localparam DAC_SPEED = 180;		// best results and within timing limits
	localparam DAC_CLOCK_FREQ = DAC_SPEED * 1_000_000;
	wire       dac_clk;							
	wire       locked;							
	iceclock #(.speed(DAC_SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(dac_clk), .locked(locked));
	
	// byte transfer states
	localparam DAC_BITS = 16;
	localparam FIFO_BITS = 8;

	wire		rx_received;
	reg	[7:0]	rx_data;
	reg [7:0]	rx_audio_buf = 0;
	
	// data to write to fifo
	localparam FIFO_SIZE = 16384;
	localparam FIFO_ALMOST_EMPTY_SIZE = 3*(FIFO_SIZE / 10);	// 30% 
	localparam FIFO_ALMOST_FULL_SIZE = FIFO_SIZE - 5*(FIFO_SIZE / 10);	// 50% 
	localparam FIFO_MAX_BITS = $clog2(FIFO_SIZE);
	
	wire fifo_empty;
	wire fifo_full;
	wire [(FIFO_MAX_BITS-1):0] fifo_fill;
	reg [(FIFO_BITS-1):0] fifo_wr_data = 0;
	
	wire fifo_almost_empty;
	wire fifo_almost_full;
	
	assign fifo_almost_empty = fifo_fill <= FIFO_ALMOST_EMPTY_SIZE;
	assign fifo_almost_full = fifo_fill >= FIFO_ALMOST_FULL_SIZE;

	// fifo read and write enable
	reg 		fifo_rd_en;
	reg			fifo_wr_en = 0;
	
	// data from fifo going to dac
	wire [(FIFO_BITS-1):0] fifo_out;
	
	reg [(DAC_BITS-1):0] dac_l_in;
	reg [(DAC_BITS-1):0] dac_r_in;
	wire dac_reset;
	reg [7:0] buffer [3];
		
	// reset dac when fifo invalid
	assign dac_reset = fifo_empty;
	
	localparam STATE_IDLE = 0;
	localparam STATE_WAIT_BYTE = 1;
	reg [2:0] count = 0;
	reg [2:0] state = STATE_IDLE;
	
	wire samplerate_en;
			
	always @(posedge sysclk) begin
		fifo_wr_en <= 0;
		
		if (rx_received) begin
			fifo_wr_data <= rx_data;
			fifo_wr_en <= 1;
		end
	end
		
	always @(posedge sysclk) begin
		case (state)
			STATE_IDLE:
				if (samplerate_en && fifo_fill > 3) begin
					state <= STATE_WAIT_BYTE;
					count <= 3;
					fifo_rd_en <= 1;
				end
			STATE_WAIT_BYTE: begin
				
				if (count == 0) begin
					// Places the 4 bytes into the DAC
					dac_l_in[15:8] <= buffer[2];
					dac_l_in[7:0] <= buffer[1];
					dac_r_in[15:8] <= buffer[0];
					dac_r_in[7:0] <= fifo_out;
					
					state <= STATE_IDLE;
					fifo_rd_en <= 0;
				end else begin
					buffer[count - 1] <= fifo_out;
				end
				
				count <= count - 1;
			end
		endcase
	end
	
	counter_clock_enable
		#(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(FIFO_CLOCK_FREQ),
		)
		fifo_clock_enable
		(
			.en(samplerate_en),
			
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
		
	fifo
		#(
			.BITS(FIFO_BITS),
			.SIZE(FIFO_SIZE))
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
			
			.clk(dac_clk)
		);
	
	// right channel dac
	fo_sigma_delta_dac #(.BITS(DAC_BITS), .INV(1))
		dac_r (
			.reset(dac_reset),
			.in(dac_r_in),
			.out(GPIO_AUDIO_R),
			
			.clk(dac_clk)
		);
	
	//assign leds = fifo_fill[(FIFO_MAX_BITS-1):(FIFO_MAX_BITS-9)];
	assign leds = fifo_fill;
	
	assign P16_o = fifo_empty;
	assign P15_o = fifo_full;

	assign N16_o = fifo_almost_empty;
	assign M15_o = fifo_almost_full;
	
	assign UART_CTS_o = ~fifo_almost_empty;
	assign UART_DSR_o = ~fifo_almost_full;
	
endmodule
