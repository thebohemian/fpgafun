`timescale 1ns/100ps

`include "sidnboard2dual.v"

module sidnboard2dual_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam PULSE_LENGTH = 83*312*4;

	reg     tb_clk;
	reg     tb_rstn;
    
	reg		tb_rx;

	always #41.5 tb_clk = !tb_clk;
	
	sidnboard2dual dut(
			.CLK_IN(tb_clk),
			.RSTn_i(tb_rstn),
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
		$dumpfile("sidnboard2dual_tb.vcd");
		$dumpvars(0, sidnboard2dual_tb);

		tb_clk <= 1'b0;
		tb_rstn <= 1;
		tb_rx <= 1;

		#83 tb_rstn <= 0;
		#83 tb_rstn <= 1;
		
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
