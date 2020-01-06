module fifo #(
		parameter BITS=16, parameter SIZE=128)
		(
		input wr_en,
		input [(BITS-1):0] wr_data,
		
		input rd_en,
		output reg [(BITS-1):0] rd_data,
		
		output reg fifo_empty = 1,
		output reg fifo_full = 0,

		output reg [(MAX_BITS-1):0] fill = 0,
		
		input clk
		);

	localparam MAX_BITS = $clog2(SIZE);
		
	reg [(BITS-1):0] buffer [SIZE];

	/* combinatorial
	reg [(MAX_BITS-1):0]	nxt_addr;
	
	reg	[(MAX_BITS-1):0]	rd_addr = 0;
	reg [(MAX_BITS-1):0]	wr_addr = 0;
	
	reg full;
	reg empty;
	
	always @(*)
		nxt_addr <= wr_addr + 1;

	always @(*) begin
		full  = (nxt_addr == rd_addr);
		empty = (wr_addr == rd_addr);
	end
	 */
	
	/* better solution
	 */	
	wire [(MAX_BITS-1):0]	nxt_addr;
	reg	[(MAX_BITS-1):0]	rd_addr = 0;
	reg [(MAX_BITS-1):0]	wr_addr = 0;

	wire full;
	wire empty;
	
	assign	nxt_addr = wr_addr + 1'b1;
	assign	full  = (nxt_addr == rd_addr);
	assign	empty = (wr_addr  == rd_addr);
	
	always @(posedge clk)
		if (wr_en)
			buffer[wr_addr] <= wr_data;

	always @(posedge clk)
		if (rd_en)
			rd_data <= buffer[rd_addr];
			
	always @(posedge clk)
		if (wr_en) begin
			// Update the FIFO write address any time a write is made to
			// the FIFO and it's not FULL.
			//
			// OR any time a write is made to the FIFO at the same time a
			// read is made from the FIFO.
			if ((!full) || (rd_en)) begin
				fifo_full <= 0;
				wr_addr <= wr_addr + 1;
			end
			else
				fifo_full <= 1;
		end
		
	always @(posedge clk)
		if (rd_en) begin
			// On any read request, increment the pointer if the FIFO isn't
			// empty--independent of whether a write operation is taking
			// place at the same time.
			if (!empty) begin
				fifo_empty <= 0;
				rd_addr <= rd_addr + 1;
			end
			else
				// If a read is requested, but the FIFO was full, set
				// an underrun error flag.
				fifo_empty <= 1;
		end
		
	always @(posedge clk)
		casez({ wr_en, rd_en, !full, !empty })
			4'b01?1: fill <= fill - 1'b1;	// A successful read
			4'b101?: fill <= fill + 1'b1;	// A successful write
			4'b1110: fill <= fill + 1'b1;	// Successful write, failed read
				// 4'b11?1: Successful read *and* write -- no change
			default: fill <= fill;	// Default, no change
		endcase
		
		
	generate
		genvar i;

		for(i = 0; i<SIZE; i=i+1) begin
			initial buffer[i] <= 0;
		end

	endgenerate
		
endmodule
		