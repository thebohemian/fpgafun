// Verilog test bench for sid8580
`timescale 1us/100ns

`include "sid8580.v"

module sid_tb();
	reg         tb_reset;

	reg         tb_clk;
	reg         tb_ce_1m;

	reg         tb_we;
	reg   [4:0] tb_addr;
	reg   [7:0] tb_data_in;
	wire [7:0] tb_data_out;

	reg   [7:0] tb_pot_x;
	reg   [7:0] tb_pot_y;

	reg         tb_extfilter_en;
	wire [17:0] tb_audio_dat;

	sid8580 dut(
		.clk(tb_clk),
		.reset(tb_reset),
		.ce_1m(tb_ce_1m),
		.we(tb_we),
		.addr(tb_addr),
		.data_in(tb_data_in),
		.data_out(tb_data_out),
		.pot_x(tb_pot_x),
		.pot_y(tb_pot_y),
		.extfilter_en(tb_extfilter_en),
		.audio_data(tb_audio_dat)
	);

	// clock, initial values, output
	// every x.5 there is a rising edge
	always #0.5 tb_clk = !tb_clk;

	initial begin
		tb_reset <= 1'b0;
		tb_clk <= 1'b0;

		// clock enable?
		tb_ce_1m <= 1'b1;

		$dumpfile("sid_tb.vcd");
		$dumpvars(0, sid_tb);

		// cause reset over the rising edge of the clock
		#0.4 tb_reset <= 1;

		// lower after we assume it was handled
		#0.2 tb_reset <= 0;

		#40 $finish;
	end

	initial begin

		#1.4 begin
			// set volume to maximum
			tb_addr <= 5'h18;
			tb_data_in <= 8'h0f;

			tb_we <= 1;
		end

		#1 begin
			// write lower part of 0x07d0 (2000)
			tb_addr <= 5'h00;
			tb_data_in <= 8'hd0;

			tb_we <= 1;
		end

		#1 begin
			// write higher part of 0x07d0 (2000)
			tb_addr <= 5'h01;
			tb_data_in <= 8'h07;

			tb_we <= 1;
		end

		#1 begin
			// write attack sustain
			tb_addr <= 5'h05;
			tb_data_in <= 8'h55;

			tb_we <= 1;
		end

		#1 begin
			// write sustain release
			tb_addr <= 5'h06;
			tb_data_in <= 8'hF5;

			tb_we <= 1;
		end

		#1 begin
			// select sawtooth wave and enable gate
			tb_addr <= 5'h04;
			tb_data_in <= 8'h21;

			tb_we <= 1;
		end

		#20 begin
			// select sawtooth wave and disable gate
			tb_addr <= 5'h04;
			tb_data_in <= 8'h20;

			tb_we <= 1;
		end
	end


	// autoreset write enabled
	always @ (negedge tb_clk)
		tb_we <= 0;

endmodule
