module spi_rx(
		input rd_en,
		output [7:0] data_out,
		
		output reg received,			// signals completion
		
		input serial_in,			// from IC
		output reg serial_clock,		// to IC
		
		input clk_en,
		input clk
		);
	
	reg [8:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_SHIFTING_IN = 1;
	reg state = STATE_IDLE;
	
	always @ (posedge clk) begin
		received <= 0;
		
		case (state)
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg <= 9'b1_0000_0000;
					state <= STATE_SHIFTING_IN;
				end
			end
			STATE_SHIFTING_IN: begin
				if (serial_clock) begin
					// expect data
					shift_reg <= { serial_in, shift_reg[7:0] };
					serial_clock <= 0;
				end else if (clk_en) begin
					if (shift_reg[0]) begin
						// all bits read
						received <= 1;
						state <= STATE_IDLE;
					end else begin
						serial_clock <= 1;
					end
				end
			end
		endcase
	end
	
	assign data_out = shift_reg[8:1];
	
endmodule
