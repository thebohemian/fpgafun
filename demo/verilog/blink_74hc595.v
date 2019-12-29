`include "../../common/iceclock/iceclock.v"
`include "../../common/clocks/monotonic_counter.v"
`include "../../common/clocks/binary_divider_clock_enable.v"
`include "../../common/shift_74hc595.v"
`include "../../common/uart_rx.v"

module blink_74hc595(
		input CLK_IN,
		
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input UART_RX_i,

		output PIN_C16_o,
		output PIN_B16_o,
		output PIN_D16_o,
		output PIN_E16_o
		
		);
	
	localparam SPEED = 30;
	wire       sysclk;							
	wire       locked;							
	iceclock #(.speed(SPEED)) clock0 (.clock12mhz_in(CLK_IN), .clock_out(sysclk), .locked(locked));
	
	localparam MAIN_CLOCK_FREQ = SPEED * 1_000_000;
	
	//localparam UART_FREQ = 115_200;
	//localparam UART_FREQ = 230_400;
	//localparam UART_FREQ = 460_800;
	localparam UART_FREQ = 921_600;
	
	localparam SHIFT_REG_FREQ = 15_000_000;

	wire shift_reg_wr_en;
	
	wire ds;	// serial data input (data)
	wire sh_cp; // shift register clock input (clock)
	wire st_cp; // storage register clock input (latch)
	
	assign PIN_C16_o = ds;
	assign PIN_D16_o = sh_cp;
	assign PIN_E16_o = st_cp;
	
	reg rd_en = 0;
	reg [7:0] data;
	
	wire [7:0] rx_data;
	wire received;
	
	always @(posedge sysclk) begin
		rd_en <= 0;
		
		if (received) begin
			data <= rx_data;
			rd_en <= 1;
		end
	end
	
	localparam COUNTER_BITS = 2;
	wire [COUNTER_BITS-1:0] counter;
	monotonic_counter #(
			.BITS(COUNTER_BITS)
		)
		cnt0(
			.value(counter),
			.clk(sysclk)
		);
	
	binary_divider_clock_enable
		#(
			.N(1)
		)
		bin_ce0
		(
			.en(shift_reg_wr_en),
			
			.counter_in(counter),
			
			.clk(sysclk)
		);
	
	shift_74hc595
		sr0(
			.rd_en(rd_en),
			.data_in(data),
			
			.wr_en(shift_reg_wr_en),
			.data_out(ds),
			.latch(st_cp),
			.register_clock(sh_cp),
			
			.clk(sysclk)
		);
	
	uart_rx #(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.BAUDRATE(UART_FREQ)
		)
		
		uart0
		(
			.rx(UART_RX_i),
			.rx_data(rx_data),
			.received(received),
			
			.clk(sysclk)
		);

	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = data;
	
endmodule
