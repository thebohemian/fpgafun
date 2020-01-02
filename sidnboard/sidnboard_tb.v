`timescale 1ns/100ps

`include "sidnboard.v"

module sidnboard_tb();
	
	/*
    12MHz gives a length of 83ns per cycle
    so 41.5 units to change the edge
	 */
	localparam tb_fpga_freq = $itor(12_000_000);
	localparam tb_1s_in_ns = $itor(1_000_000_000);
	localparam tb_clock_length = (1/tb_fpga_freq*tb_1s_in_ns);
	localparam tb_phase_length = tb_clock_length / 2;
	
	localparam sample_rate = $itor(8000);
	localparam delay_audio_sample = (1/sample_rate*tb_1s_in_ns);
	localparam audio_test_cycles = sample_rate;
	
	reg     tb_clk = 1; 
    
	integer audio_fd;

	always #tb_phase_length tb_clk = !tb_clk;

	top dut(
			.CLK_IN(tb_clk)
		);

	initial begin
		$dumpfile("sidnboard_tb.vcd");
		$dumpvars(0, sidnboard_tb);

		#(83*12*1000) $finish;
	end
	
    /*
	integer i;
	initial begin
		audio_fd = $fopen("audio.pcm", "wb");
    	
		for (i=0; i < audio_test_cycles; i++)
		begin
			#delay_audio_sample;
			$fputc(dut.audio_dat[17:9], audio_fd);
			$fputc(dut.audio_dat[8:1], audio_fd);
			$display("%d / %d", i, audio_test_cycles);
		end
    	
		$fclose(audio_fd);
		
		$finish;
	end
	*/
endmodule
