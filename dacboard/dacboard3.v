`include "../common/rxuart.v"
`include "../common/sigma_delta_dac.v"
`include "../common/fo_sigma_delta_dac.v"
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

	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	// UART frequency/speed
	//localparam UART_FREQ = 115_200;
	localparam UART_FREQ = 230_400;
//	localparam UART_FREQ = 460_800;
	//localparam UART_FREQ = 150;
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;
	localparam UART_CLOCK_DIVIDE = UART_COUNTER / 4;

	//localparam DAC_CLOCK_FREQ = 8_000;
	localparam DAC_CLOCK_FREQ = 11_025;
	//	localparam DAC_CLOCK_FREQ = 22_050;
	//	localparam DAC_CLOCK_FREQ = 44_100;
	//localparam DAC_CLOCK_FREQ = 48_000;
	localparam DAC_COUNTER = (MAIN_CLOCK_FREQ / DAC_CLOCK_FREQ);
	localparam DAC_BITS = $clog2(DAC_COUNTER);
	reg [(DAC_BITS-1):0] dac_counter = DAC_COUNTER - 1;
	
	localparam OS_DAC_CLOCK_FREQ = DAC_CLOCK_FREQ * 8;
	localparam OS_DAC_COUNTER = (MAIN_CLOCK_FREQ / OS_DAC_CLOCK_FREQ);
	localparam OS_DAC_BITS = $clog2(OS_DAC_COUNTER);
	reg [(OS_DAC_BITS-1):0] os_dac_counter = OS_DAC_COUNTER - 1;
	
	// byte transfer states
	localparam BITS = 16;

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
	reg [(BITS-1):0] fifo_wr_data = 0;
	
	wire fifo_almost_empty;
	wire fifo_almost_full;
	
	assign fifo_almost_empty = (fifo_fill <= FIFO_SIZE / 10);
	assign fifo_almost_full = (fifo_fill >= FIFO_SIZE - (FIFO_SIZE / 10));
	
	// data from fifo going to dac
	wire [(BITS-1):0] fifo_out;
	
	wire dac_ce;
	wire [(BITS-1):0] dac_in;
	wire dac_reset;

	assign fifo_rd_en = dac_ce;
	
	// play output
//	assign dac_in = ((dac_counter>>3) > 0) ? 16'h0000 : fifo_out;
	assign dac_in = fifo_out;
	
	// reset dac when fifo invalid
	assign dac_reset = fifo_empty;
	
	// updating dac cycle
	always @(posedge CLK_IN) begin
		dac_counter <= (dac_counter > 0) ? dac_counter - 1 : DAC_COUNTER - 1;
	end
	assign dac_ce = dac_counter == 0;

	// updating oversampled dac cycle
	always @(posedge CLK_IN) begin
		os_dac_counter <= (os_dac_counter > 0) ? os_dac_counter - 1 : OS_DAC_COUNTER - 1;
	end
	assign os_dac_ce = os_dac_counter == 0;
		
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
/*	
	always @(posedge CLK_IN) begin
		case ({fifo_rd_en, os_dac_ce })
			2'b10, 2'b11:
				dac_in <= fifo_out;
			2'b01:
				dac_in <= 0;
		endcase
	end
*/
	rxuart #(.CLOCK_DIVIDE(UART_CLOCK_DIVIDE))
		rxuart(
			.rx(UART_RX_i),
			.rx_byte(rx_data),
			.received(rx_received),
			.clk(CLK_IN)
		);

	fifo #(.BITS(BITS), .SIZE(FIFO_SIZE))
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

	fo_sigma_delta_dac #(.BITS(BITS), .INV(0))
		fo_dac1 (
			.reset(dac_reset),
			.in(dac_in),
			.out(GPIO_AUDIO_L),
			
			.clk(dac_ce)
		);
	
	assign leds = fifo_fill[(FIFO_MAX_BITS-1):(FIFO_MAX_BITS-9)];
	//assign leds = dac_in[15:8];
	
	assign P16_o = fifo_empty;
	assign P15_o = fifo_full;

	assign N16_o = fifo_almost_empty;
	assign M15_o = fifo_almost_full;
	
	assign UART_CTS_o = ~fifo_almost_empty;
	assign UART_DSR_o = ~fifo_almost_full;
	
endmodule
