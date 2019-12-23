`timescale 1ns/100ps

`include "dacboard3.v"

module dacboard3_tb();
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
	
	dacboard3 dut(
			.CLK_IN(tb_clk),
			.UART_RX_i(tb_rx)
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
	
	task send_audio;
		input [15:0] data;
		
		send_byte(data[7:0]);
		send_byte(data[15:8]);
		
		begin
		end
	endtask

	initial begin
		$dumpfile("dacboard3_tb.vcd");
		$dumpvars(0, dacboard3_tb);

		tb_clk <= 1'b0;
		tb_rx <= 1;

		#2213 send_audio(16'h4000);
		
		#324 send_audio(16'h6100);

		#13 send_audio(16'h9003);

		#4656 send_audio(16'h0029);
			
		#123 send_audio(16'h4009);
		
		#321 send_audio(16'h9119);
			
		#(83*12*1000) $finish;
	end

endmodule
