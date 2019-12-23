`timescale 1ns/100ps

`include "memory.v"
`include "fifo_mem.v"

module fifo_mem_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	localparam PULSE_LENGTH = 82;
	localparam PHASE_LENGTH = (PULSE_LENGTH/2);
	
	reg     tb_clk = 0;
	reg     tb_wr_en = 0;
	reg [3:0]    tb_wr_data = 0;
	reg     tb_rd_en = 0;
	wire [3:0]    tb_rd_data = 0;
	
	always #PHASE_LENGTH tb_clk = !tb_clk;
	
	fifo #(.BITS(4), .SIZE(4)) dut(
			.wr_en(tb_wr_en),
			.wr_data(tb_wr_data),
			
			.rd_en(tb_rd_en),
			.rd_data(tb_rd_data),
			
			.clk(tb_clk)
		);
	
	task push;
		input [3:0] data;
		begin
			tb_wr_data <= data;
			tb_wr_en <= 1;
			
			#PULSE_LENGTH tb_wr_en <= 0;
		end
	endtask
	
	task pop;
		tb_rd_en <= 1;
			
		#PHASE_LENGTH tb_rd_en <= 0;
		#PHASE_LENGTH tb_rd_en <= 0;
		
		begin
		end
	endtask

	initial begin
		$dumpfile("fifo_mem_tb.vcd");
		$dumpvars(0, fifo_mem_tb);
		
		#PULSE_LENGTH;
		#PHASE_LENGTH;

		push(4'hd);
		push(4'he);
		push(4'ha);
		push(4'h4);
		
		pop();
		pop();
		pop();
		pop();
			
		#(83*12*1000) $finish;
	end

endmodule
