/** 
 */
`include "../../common/uart_rx.v"

module top (
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input UART_RX_i,
		
		input CLK_IN
		);
	
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	//localparam UART_FREQ = 115_200;
	//localparam UART_FREQ = 230_400;
	//localparam UART_FREQ = 460_800;
	localparam UART_FREQ = 921_600;

	reg [7:0] data = 0;
	wire [7:0] rx_data;
	
	wire received;
	
	always @(posedge CLK_IN) begin
		if (received) begin
			data <= rx_data;
		end
	end
	
	uart_rx #(
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