module spi_tx(
		input rd_en,
		input [7:0] data_in,
		
		output reg sent,				// signals completion
		
		output reg serial_out,			// to IC
		output reg serial_clock,		// to IC
		
		input clk_en,
		input clk
		);

	initial serial_clock <= 0;
	
	reg [2:0] counter = 0;
	reg [7:0] shift_reg;

	localparam STATE_IDLE = 0;
	localparam STATE_SHIFTING = 1;
	reg state = STATE_IDLE;
	
	always @ (posedge clk) begin
		sent <= 0;
		serial_clock <= 0;
		
		case (state)
			STATE_IDLE: begin
				if (rd_en) begin
					shift_reg <= data_in;
					counter <= 7;
					state <= STATE_SHIFTING;
				end
			end
			STATE_SHIFTING: begin
				if (clk_en) begin
					serial_out <= shift_reg[counter];
					serial_clock <= 1;
					
					if (counter > 0) begin
						counter <= counter - 1;
					end else begin
						sent <= 1;
						state <= STATE_IDLE;
					end
				end
			end
		endcase
	end
	
endmodule
