
module memory #(
		parameter BITS=8, parameter SIZE=128
		)
		
		(
		input wr_en,
		input     [(MAX_BITS-1):0] wr_addr,
		input [(BITS-1):0] data_in,
		
		input rd_en,
		input     [(MAX_BITS-1):0] rd_addr,
		output reg [(BITS-1):0] data_out,

		input            clk
		);
	
	localparam MAX_BITS = $clog2(SIZE);

	always @(posedge clk) begin
		if (rd_en)
			data_out <= mem[rd_addr];
	end

	always @(posedge clk) begin
		if (wr_en)
			mem[wr_addr] <= data_in;
	end
	
	reg [(MAX_BITS-1):0] mem[SIZE];

	generate
		genvar i;

		for(i = 0; i<SIZE; i=i+1) begin
			initial mem[i] <= 0;
		end
	
	endgenerate
	
endmodule
