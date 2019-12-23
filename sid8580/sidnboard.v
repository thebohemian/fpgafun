`include "sidnboard_rom.v"
`include "sid8580.v"
`include "fo_sigma_delta_dac.v"

module sidnboard(
		input CLK_IN,
		output GPIO_AUDIO
		);
	
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	//localparam DAC_CLOCK_FREQ = 44_100;
	localparam DAC_CLOCK_FREQ = 48_000;
	localparam DAC_COUNTER = MAIN_CLOCK_FREQ / DAC_CLOCK_FREQ;
	reg [31:0] dac_counter = DAC_COUNTER - 1;
	
	localparam DELAY_CMD = 5'h1f;
	
	reg [7:0] resetn_counter = 2;
	wire RSTn_i;
	
	/* FPGA runs at 12Mhz, SID at 1Mhz. So we have to let 12 main
	 * clock cycles pass before we have one clock cycle for the SID
	 */
	localparam SID_MAIN_CLK_CYCLES = 12;
	
	localparam COUNTER_WIDTH = 8;
	reg [COUNTER_WIDTH-1:0] sid_wait_cycles;		// no of SID cycles the sid should do nothing

	reg        sid_reset;					// set when to reset SID
	reg [3:0] sid_clk_delay;				// amount of main clock cycles to wait until talking to SID (makes it run at 1Mhz) 
	wire       sid_ce_1m;					// 1Mhz clock of the SID

	wire		rom_read_en;				// set when reading from rom should occur
	reg   [7:0] rom_index;					// address in ROM
	wire   [4:0] rom_addr;					// SID addr value from ROM (or wait cmd)
	wire   [7:0] rom_data;					// SID register value from ROM

	reg         sid_write_en;				// set when writing to SID is possible

	wire [17:0] audio_dat;					// 18bit audio data output
	
	reg	[2:0]	dac_reset_counter;
	wire dac_reset;
	
	reg extfilter_en;

	// reading from ROM is possible when no more wait cycles and we are in the
	// last step of the global clock before a SID cycle begins 
	assign rom_read_en = (sid_wait_cycles == 0) && (sid_clk_delay == SID_MAIN_CLK_CYCLES - 1);

	// generates a 1Mhz signal for the SID (original speed)
	assign sid_ce_1m = sid_clk_delay == 0;
	
	// DAC reset is held until there is proper audio data coming out of the SID
	// otherwise it will mess up the internal registers
	assign dac_reset = dac_reset_counter > 0;
	
	function [COUNTER_WIDTH-1:0] decrease_wait_cycles;
		input [COUNTER_WIDTH-1:0] cycles;
		begin
			// decreases wait cycles (from wait command)
			decrease_wait_cycles = (cycles > 0) ? cycles - 1 : 0;
		end
	endfunction
	
	always @(posedge CLK_IN) begin
		if (resetn_counter > 0) begin
			resetn_counter <= resetn_counter - 1;
		end
	end
	
	assign RSTn_i = (resetn_counter == 0);

	always @(posedge CLK_IN) begin
		dac_counter <= (dac_counter > 0) ? dac_counter - 1 : DAC_COUNTER - 1;
	end
	
	assign dac_ce = dac_counter == 0;
	
	always @(posedge CLK_IN) begin
		if (!RSTn_i) begin

			// ROM
			rom_index <= 8'h00;

			// SID
			sid_wait_cycles <= 1;
			sid_write_en <= 0;
			
			extfilter_en <= 0;
					
			// cause reset
			sid_reset <= 1;
			dac_reset_counter <= 3;
		end
		else begin
			case (sid_clk_delay)
				// start of SID cycle: Read from ROM or wait
				SID_MAIN_CLK_CYCLES-1: begin
					if (sid_wait_cycles == 0) begin
						if (rom_addr == DELAY_CMD) begin
							// loads delay counter instead
							sid_wait_cycles <= rom_data;
						end
						else begin
							// let values flow into SID
							sid_write_en <= 1;
						end
					end				
				end
				0: begin
					// reset ends together with end of write cycle only 
					sid_reset <= 0;
		
					// clears writing to SID
					sid_write_en <= 0;
					
					if (sid_wait_cycles == 0) begin
						rom_index <= rom_index + 1;
					end
					
					sid_wait_cycles <= decrease_wait_cycles(sid_wait_cycles);
					
					// keeps dac reset for a few cycles
					if (dac_reset_counter > 0)
						dac_reset_counter <= dac_reset_counter - 1;
				end
			endcase
		end
	end

	always @(posedge CLK_IN) begin
		if (!RSTn_i) begin
			// SID clock
			sid_clk_delay <= SID_MAIN_CLK_CYCLES-1;
		end
		else begin
			sid_clk_delay <= (sid_clk_delay > 0) ? sid_clk_delay - 1 : SID_MAIN_CLK_CYCLES - 1;
		end
	end

	sidnboard_rom rom(
			.addr(rom_index),
			.read_en(rom_read_en),
			.addr_out(rom_addr),
			.cmd_out(rom_data),
			
			.clk(CLK_IN)
		);
	
	sid8580 sid0(
			.we(sid_write_en),
			.addr(rom_addr),
			.data_in(rom_data),
			.audio_data(audio_dat),
			.ce_1m(sid_ce_1m),
			.extfilter_en(extfilter_en),
			.reset(sid_reset),
			.clk(CLK_IN)
		);

	fo_sigma_delta_dac #(.BITS(18)) dac1 (
			.in(audio_dat),
			.out(GPIO_AUDIO),
			
			.clk(dac_ce)
		);

endmodule
