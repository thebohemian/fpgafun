`timescale 1ns/100ps

`include "../../common/clocks/counter_clock.v"
`include "../../common/i2c_tx.v"

module i2c_tx_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	/* based on 100kHz */
	localparam I2C_FREQ = 100_000;
	
	localparam CLOCK_PERIOD = 83;
	
	localparam I2C_PERIOD = 10_000;
	
	reg		tb_rd_en;
	reg	[7:0] tb_data_in;
	
	reg		tb_i2c_clock = 0;
	always #(I2C_PERIOD) tb_i2c_clock = !tb_i2c_clock;

	reg     tb_clk = 0;
	always #41.5 tb_clk = !tb_clk;
	
	i2c_tx
		dut
		(
			.rd_en(tb_rd_en),
			.data_in(tb_data_in),
			
			.clk_i2c(tb_i2c_clock),
			.clk(tb_clk)
		);
	
	task i2c_send;
		input [7:0] data;
		begin
			tb_data_in <= data;
			tb_rd_en <= 1;
			
			#(CLOCK_PERIOD) tb_rd_en <= 0;
			
			#((9+2)*I2C_PERIOD);
		end
	endtask
	
	initial begin
		$dumpfile("i2c_tx_tb.vcd");
		$dumpvars(0, i2c_tx_tb);

		#(CLOCK_PERIOD*20) i2c_send(8'h55);
		
		#(I2C_PERIOD*100) $finish;
	end

endmodule
