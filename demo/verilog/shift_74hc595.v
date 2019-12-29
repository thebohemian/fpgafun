module shift_74hc595(
		input rd_en,
		input [7:0] data_in,
		
		output data_out,
		output latch,
		output register_clock,
		
		input clk
		);
	
	localparam CLK_FREQ = 12_000_000;
	localparam SHIFT_REG_FREQ = 1_000_000;
	localparam SHIFT_REG_TICKS = CLK_FREQ / SHIFT_REG_FREQ;
	localparam SHIFT_REG_BITS = $clog2(SHIFT_REG_TICKS);
	
	reg [(SHIFT_REG_BITS-1):0] shift_reg_counter = 0;
	always @ (posedge clk)
		shift_reg_counter <= shift_reg_counter == 0 ? SHIFT_REG_TICKS - 1 : shift_reg_counter - 1;
	assign register_clock = shift_reg_counter == 0;
		
	reg [2:0] counter = 0;
	reg [7:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_START = 1;
	localparam STATE_SHIFTING = 2;
	localparam STATE_END = 3;
	reg [1:0] state = STATE_IDLE;
	
	always @ (posedge clk) begin
		case (state)
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg <= data_in;
					counter <= 7;
					state <= STATE_START;
				end
			end
			STATE_START: begin
				if (register_clock) begin
					state <= STATE_SHIFTING;
					latch <= 0;
				end
			end
			STATE_SHIFTING: begin
				if (register_clock) begin
					data_out <= shift_reg[counter];
					
					if (counter > 0) begin
						counter <= counter - 1;
					end else begin
						state <= STATE_END;
					end
				end
			end
			STATE_END: begin
				if (register_clock) begin
					state <= STATE_IDLE;
					latch <= 1;
				end
			end
		endcase
	end
	
endmodule
