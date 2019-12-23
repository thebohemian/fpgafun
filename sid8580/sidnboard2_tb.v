`timescale 1ns/100ps

`include "sidnboard2.v"

module sidnboard2_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	localparam UART_FREQ = 115_200;
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;
	localparam PULSE_LENGTH = 83*UART_COUNTER;

	reg     tb_clk;
    
	reg		tb_rx;

	always #41.5 tb_clk = !tb_clk;
	
	sidnboard2 dut(
			.CLK_IN(tb_clk),
			.RS232_RX_i(tb_rx)
		);
	
	task send_byte;
		input [7:0] data;
		begin
			/// start bit
			#(PULSE_LENGTH) tb_rx <= 0;
		
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
		end
	endtask

	initial begin
		$dumpfile("sidnboard2_tb.vcd");
		$dumpvars(0, sidnboard2_tb);

		tb_clk <= 1'b0;
		tb_rx <= 1;

		send_byte(8'h18);
		send_byte(8'h0f);
		
		#324
	
		send_byte(8'h00);
		send_byte(8'hd0);

		#13

		send_byte(8'h01);
		send_byte(8'h07);
	
		#4656
			
		send_byte(8'h05);
		send_byte(8'h55);

		#123
		
		send_byte(8'h06);
		send_byte(8'hf5);

		#321
			
		send_byte(8'h04);
		send_byte(8'h11);

		#(83*12*1000) $finish;
	end

endmodule
