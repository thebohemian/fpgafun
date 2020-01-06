`timescale 1ns/100ps

`include "../../common/io_mcp23017.v"

module io_mcp23017_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	/* based on 100kHz */
	localparam I2C_FREQ = 100_000;
	
	localparam CLOCK_PERIOD = 83;
	
	localparam I2C_PERIOD = 10_000;
	
	reg		tb_wr_en;
	reg	[2:0] tb_hardware_address;
	reg	[7:0] tb_data_in;
	reg [7:0] tb_register_address;
	
	reg		tb_clk_ic = 0;
	always #(I2C_PERIOD) tb_clk_ic = !tb_clk_ic;

	reg     tb_clk = 0;
	always #41.5 tb_clk = !tb_clk;
	
	io_mcp23017
		dut
		(
			.wr_en(tb_wr_en),
			.hardware_address(tb_hardware_address),
			.data_in(tb_data_in),
			.register_address(tb_register_address),
			
			.clk_ic(tb_clk_ic),
			.clk(tb_clk)
		);
	
	task mcp23017_send;
		input [2:0] hw_address;
		input [7:0] register_address;
		input [7:0] data;
		begin
			tb_hardware_address <= hw_address;
			tb_register_address <= register_address;
			tb_data_in <= data;
			tb_wr_en <= 1;
			
			#(CLOCK_PERIOD) tb_wr_en <= 0;
			
			#((2*9+2)*I2C_PERIOD);
		end
	endtask
	
	initial begin
		$dumpfile("io_mcp23017_tb.vcd");
		$dumpvars(0, io_mcp23017_tb);

		#(CLOCK_PERIOD*20) mcp23017_send(3'b100, 8'h12, 8'h55);
		
		#(I2C_PERIOD*100) $finish;
	end

endmodule
