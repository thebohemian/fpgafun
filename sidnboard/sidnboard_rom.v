module sidnboard_rom(
		input [7:0] addr,
		input read_en,
		output reg [4:0] addr_out,
		output reg [7:0] cmd_out,
		
		input clk
		);
	
	// ROM
	always @(posedge clk) begin
		if (read_en) begin
			case (addr)
				8'h00: begin
					addr_out <= 5'h18;
					cmd_out <= 8'h04;
				end
				8'h01: begin
					addr_out <= 5'h00;
					cmd_out <= 8'h00;
				end
				8'h02: begin
					addr_out <= 5'h01;
					cmd_out <= 8'h20;
				end
				8'h03: begin
					addr_out <= 5'h05;
					cmd_out <= 8'h80;
				end
				8'h04: begin
					addr_out <= 5'h06;
					cmd_out <= 8'hf5;
				end
				8'h05: begin
					addr_out <= 5'h04;
					cmd_out <= 8'h11;
				end
				default: begin
					addr_out <= 5'h1f;
					cmd_out <= 8'hff;
				end
			endcase
		end
	end

endmodule
