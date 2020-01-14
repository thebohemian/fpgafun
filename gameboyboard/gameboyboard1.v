`include "../common/iceclock/iceclock.v"
`include "../common/uart_rx.v"
`include "../common/fo_sigma_delta_dac.v"
`include "../common/clocks/counter_clock.v"

`include "sound.v"

module top(
		input CLK_IN,
		
		input UART_RX_i,
		input UART_DTR_i,
		input UART_RTS_i,
		
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
	
	// DAC frequency (Sigma-Delta works best when oversampling many times, IOW run as fast as possible)
	//localparam DAC_SPEED = 276;	// still works but bad quality because of signals in the FPGA not reaching destinations in time
	localparam DAC_SPEED = 180;		// best results and within timing limits
	localparam DAC_CLOCK_FREQ = DAC_SPEED * 1_000_000;
	wire       dac_clk;							
	wire       locked;							
	iceclock #(.speed(DAC_SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(dac_clk), .locked(locked));
	
	// byte transfer states
	localparam DAC_BITS = 16;

	wire		rx_received;
	reg	[7:0]	rx_data;

	localparam RX_WAIT_ADDR = 0;
	localparam RX_WAIT_DATA = 1;
	reg			rx_state = RX_WAIT_ADDR;
	
	reg [(DAC_BITS-1):0] dac_l_in;
	reg [(DAC_BITS-1):0] dac_r_in;
	wire dac_reset;
	
	reg sound_reset = 1;
	reg sound_address = 0;
	reg sound_data = 0;
	reg sound_wr_en = 0;
	
	wire clk_512hz;
	wire clk_2mhz;
		
	always @(posedge CLK_IN) begin
		sound_wr_en <= 0;
		
		if (rx_received) begin
			sound_reset <= 0;
			
			case (rx_state)
				RX_WAIT_ADDR: begin
					sound_address <= { 8'hff, rx_data };
					rx_state <= RX_WAIT_DATA;
				end
				RX_WAIT_DATA: begin
					sound_data <= rx_data;
					rx_state <= RX_WAIT_ADDR;
					
					sound_wr_en <= 1;
				end
			endcase
		end
	end
	
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
		
	counter_clock #(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(512)
			)
			sound_clk0(
				.clk_out(clk_512hz),
				
				.clk(sysclk)
		);
	
	counter_clock #(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.COUNTER_FREQ(2_097_152)
		)
		sound_clk1(
			.clk_out(clk_2mhz),
				
			.clk(sysclk)
		);
	
	sound gameboysound0(
			.rst(sound_reset),
			.a(sound_address),
			.din(sound_data),
			.wr(sound_wr_en),
			.left(dac_l_in),
			.right(dac_r_in),
			
			.clk(sysclk),
			.clk_512hz(clk_512hz),
			.clk_2mhz(clk_2mhz)
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
	
	assign leds = rx_data;
	
endmodule
