module fifo_extmem #(
		parameter BITS=8, parameter SIZE=1024*1024)
		(
		input wr_en,
		input [(BITS-1):0] wr_data,
		
		input rd_en,
		output reg [(BITS-1):0] rd_data,
		output reg completed,
		
		output reg fifo_empty = 1,
		output reg fifo_full = 0,

		output reg [(MAX_BITS-1):0] fill = 0,
		
		output mem_wr_en,
		output mem_rd_en,
		output reg [(MAX_BITS-1):0] mem_address,
		output reg [(BITS-1):0] mem_data_out,
		input [(BITS-1):0] mem_data_in,
		input mem_completed,
		
		input clk
		);

	localparam MAX_BITS = $clog2(SIZE);
		
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
	
	localparam STATE_IDLE = 0;
	localparam STATE_READING = 1;
	localparam STATE_WRITING = 2;
	reg [1:0] state = STATE_IDLE;
	
	always @(posedge clk) begin
		mem_wr_en <= 0;
		mem_rd_en <= 0;
		rd_data_en <= 0;
		completed <= 0;
		
		case (state)
			STATE_IDLE:
				if (rd_en) begin
					mem_rd_en <= 1;
					mem_address <= rd_addr;
					state <= STATE_READING;
				end else if (wr_en) begin
					mem_wr_en <= 1;
					mem_address <= wr_addr;
					mem_data_out <= wr_data;
					state <= STATE_WRITING;
				end
			STATE_READING:
				if (mem_completed) begin
					rd_data <= mem_data_in;
					completed <= 1;
					state <= STATE_IDLE;
				end
			STATE_WRITING:
				if (mem_completed) begin
					completed <= 1;
					state <= STATE_IDLE;
				end
		endcase
		
	end
			
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
		
endmodule
		