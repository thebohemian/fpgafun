`include "shift_74hc595.v"
`include "../../common/rxuart2.v"

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
	
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	//localparam UART_FREQ = 115_200;
	//localparam UART_FREQ = 230_400;
	//localparam UART_FREQ = 460_800;
	localparam UART_FREQ = 921_600;
	
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
	
	always @(posedge CLK_IN) begin
		rd_en <= 0;
		
		if (received) begin
			data <= rx_data;
			rd_en <= 1;
		end
	end
	
	shift_74hc595 sr0(
			.rd_en(rd_en),
			.data_in(data),
			
			.data_out(ds),
			.latch(st_cp),
			.register_clock(sh_cp),
			
			.clk(CLK_IN)
		);
	
	rxuart #(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.BAUDRATE(UART_FREQ)
		)
		
		uart0
		(
			.rx(UART_RX_i),
			.rx_data(rx_data),
			.received(received),
			
			.clk(CLK_IN)
		);

	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = data;
	
endmodule
