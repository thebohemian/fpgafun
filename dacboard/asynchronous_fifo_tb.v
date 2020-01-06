`timescale 1ns/100ps

`include "asynchronous_fifo.v"

module asynchronous_fifo_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	localparam PULSE_LENGTH = 83;
	localparam PHASE_LENGTH = (PULSE_LENGTH/2);
	
	reg     tb_clk = 0;
	reg     tb_wr_en = 0;
	reg [7:0]    tb_wr_data = 0;
	reg     tb_rd_en = 0;
	
	always #PHASE_LENGTH tb_clk = !tb_clk;
	
	asynchronous_fifo #(
			.BITS_IN(8),
			.BITS_OUT(32),
			.SIZE(64))
		dut(
			.wr_en(tb_wr_en),
			.wr_data(tb_wr_data),
			
			.rd_en(tb_rd_en),
			
			.clk(tb_clk)
		);
	
	task push;
		input [7:0] data;
		begin
			tb_wr_data <= data;
			tb_wr_en <= 1;
			
			#PULSE_LENGTH tb_wr_en <= 0;
		end
	endtask
	
	task pop;
		tb_rd_en <= 1;
			
		#PULSE_LENGTH tb_rd_en <= 0;
		
		begin
		end
	endtask

	initial begin
		$dumpfile("asynchronous_fifo_tb.vcd");
		$dumpvars(0, asynchronous_fifo_tb);
		
		#PULSE_LENGTH;

		push(8'hde);
		push(8'hea);
		push(8'hbe);
		push(8'hef);
		
		pop();
		
		push(8'h55);
		push(8'hAA);
		push(8'h66);
		push(8'hBB);
		
		pop();
		
		#PULSE_LENGTH $finish();
	end

endmodule
