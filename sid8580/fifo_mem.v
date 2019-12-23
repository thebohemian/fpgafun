module fifo #(
		parameter BITS=16, parameter SIZE=256)
		(
		input wr_en,
		input [(BITS-1):0] wr_data,
		
		input rd_en,
		output [(BITS-1):0] rd_data,
		
		output reg fifo_empty = 0,
		output reg fifo_full = 0,
		
		output reg [(MAX_BITS-1):0] fill = 0,

		output [7:0] info,

		input clk
		);
	
	localparam MAX_BITS = $clog2(SIZE);
	
	reg [(MAX_BITS):0] buffer_rd_data;

	// the memory the FIFO operates on
	memory #(.BITS(BITS), .SIZE(SIZE))
		buffer (
			.wr_en(wr_en),
			.wr_addr(wr_addr),
			.data_in(wr_data),
			
			.rd_en(rd_en),
			.rd_addr(rd_addr),
			.data_out(rd_data),
			
			.clk(clk)
		);
	
	reg [(MAX_BITS-1):0]	nxt_addr = 0;
	
	reg	[(MAX_BITS-1):0]	rd_addr = 0;
	reg [(MAX_BITS-1):0]	wr_addr = 0;
	
	reg full = 0;
	reg empty = 0;
	
	assign info = wr_addr;
	
	always @(*)
		nxt_addr <= wr_addr + 1;

	always @(*) begin
		full  = (nxt_addr == rd_addr);
		empty = (wr_addr == rd_addr);
	end

	always @(posedge clk)
		if (wr_en) begin
			// Update the FIFO write address any time a write is made to
			// the FIFO and it's not FULL.
			//
			// OR any time a write is made to the FIFO at the same time a
			// read is made from the FIFO.
			if ((!full)||(rd_en)) begin
				fifo_full <= 0;
				wr_addr <= wr_addr + 1;
			end
			else begin
				fifo_full <= 1;
			end
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
			else begin
				// If a read is requested, but the FIFO was full, set
				// an underrun error flag.
				fifo_empty <= 1;
			end
		end
		
	always @(posedge clk)
		casez({ wr_en, rd_en, !full, !empty })
			4'b01?1: fill <= fill - 1'b1;	// A successful read
			4'b101?: fill <= fill + 1'b1;	// A successful write
			4'b1110: fill <= fill + 1'b1;	// Successful write, failed read
				// 4'b11?1: Successful read *and* write -- no change
			default: fill <= fill;	// Default, no change
		endcase
		
endmodule
		