`timescale 1ns/100ps

`include "../../common/clocks/discrete_binary_divider_clock.v"
`include "../../common/i2c_tx.v"

module i2c_tx_tb();
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	localparam UART_FREQ = 230_400;
	
	localparam CLOCK_PERIOD = 83;
	
	localparam UART_COUNTER = MAIN_CLOCK_FREQ / UART_FREQ;
	
	localparam PULSE_LENGTH = 83*UART_COUNTER;
	
	/* based on 100kHz */
	localparam I2C_PERIOD = 10000;
	
	reg		tb_rd_en;
	reg	[7:0] tb_data_in;
	reg [0:0] tb_index_in;
	
	reg		tb_i2c_clock = 0;
	always #10000 tb_i2c_clock = !tb_i2c_clock;

	reg     tb_clk = 0;
	always #41.5 tb_clk = !tb_clk;
	
	i2c_tx #(
			.BYTES(2)
		)
		dut
		(
			.rd_en(tb_rd_en),
			.data_in(tb_data_in),
			.index_in(tb_index_in),
			
			.i2c_clock(tb_i2c_clock),
			
			.clk(tb_clk)
		);
	
	task i2c_send;
		input [7:0] data0;
		input [7:0] data1;
		begin
			tb_index_in <= 0;
			tb_data_in <= data0;
			tb_rd_en <= 1;
			
			#(CLOCK_PERIOD) tb_rd_en <= 0;
			
			tb_index_in <= 1;
			tb_data_in <= data1;
			tb_rd_en <= 1;
			
			#(CLOCK_PERIOD) tb_rd_en <= 0;
			
			#((24+3)*I2C_PERIOD);
		end
	endtask
	
	initial begin
		$dumpfile("i2c_tx_tb.vcd");
		$dumpvars(0, i2c_tx_tb);
		$dumpvars(0, i2c_tx_tb.dut.shift_reg[0]);
		$dumpvars(0, i2c_tx_tb.dut.shift_reg[1]);

		tb_clk <= 1'b0;

		#(CLOCK_PERIOD*20) i2c_send(8'h50, 8'haa);
		
		#(I2C_PERIOD*100) $finish;
	end

endmodule
