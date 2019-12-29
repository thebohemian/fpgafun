`timescale 1ns/100ps

`include "../../common/uart_rx.v"

module rxuart2_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	localparam UART_FREQ = 230_400;
	
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;
	
	localparam PULSE_LENGTH = 83*UART_COUNTER;
	
	reg     tb_clk = 0;
	reg		tb_rx;

	always #41.5 tb_clk = !tb_clk;
	
	uart_rx #(
			.CLK_FREQ(MAIN_CLOCK_FREQ),
			.BAUDRATE(UART_FREQ)
		)
		dut(
			.rx(tb_rx),
			
			.clk(tb_clk)
		);
	
	task send_byte;
		input [7:0] data;
		begin
			/// start bit
			tb_rx <= 0;
		
			// data bits
			#(PULSE_LENGTH) tb_rx <= data[0];
			#(PULSE_LENGTH) tb_rx <= data[1];
			#(PULSE_LENGTH) tb_rx <= data[2];
			#(PULSE_LENGTH) tb_rx <= data[3];
			#(PULSE_LENGTH) tb_rx <= data[4];
			#(PULSE_LENGTH) tb_rx <= data[5];
			#(PULSE_LENGTH) tb_rx <= data[6];
			#(PULSE_LENGTH) tb_rx <= data[7];

				// stop bit
			#(PULSE_LENGTH) tb_rx <= 1;
			
			#(PULSE_LENGTH);
		end
	endtask
	
	initial begin
		$dumpfile("uart_rx_tb.vcd");
		$dumpvars(0, uart_rx_tb);

		tb_clk <= 1'b0;
		tb_rx <= 1;

		#2213 send_byte(8'h40);
		
		#324 send_byte(8'h61);

		#13 send_byte(8'h93);

		#4656 send_byte(8'h29);
			
		#123 send_byte(8'h49);
		
		#321 send_byte(8'h19);
			
		#(83*100) $finish;
	end

endmodule
