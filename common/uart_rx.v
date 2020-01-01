module uart_rx
		#(
		parameter CLK_FREQ=12_000_000,
		parameter BAUDRATE=9600
		)
		(
		input rx,
		output [7:0] rx_data,
		output reg received,
		
		input clk);

	localparam STATE_IDLE = 0;	
	localparam STATE_CHECK_START = 1;	
	localparam STATE_BITS = 2;	
	localparam STATE_CHECK_STOP = 3;	
	
	localparam BIT_SAMPLE_COUNTER = CLK_FREQ / BAUDRATE;
	localparam HALF_BIT_SAMPLE_COUNTER = BIT_SAMPLE_COUNTER / 2;
	
	localparam COUNTER_BITS = $clog2(BIT_SAMPLE_COUNTER);
	
	reg [COUNTER_BITS-1:0] counter;
	reg [1:0] state = STATE_IDLE;
	reg [8:0] bits;
	
	/* handles metastability */
	/*
	reg rx_metastable = 0;
	reg rx_stable = 0;
	always @ (posedge clk) begin
		rx_metastable <= rx;
		rx_stable <= rx_metastable;
	end*/
	wire rx_stable = rx;
	
	always @ (posedge clk) begin
		// clears received flag
		received <= 0;
		
		if (counter > 0) begin
			counter <= counter - 1;
		end else begin
			case (state)
				STATE_IDLE: begin
					if (!rx_stable) begin
						counter <= HALF_BIT_SAMPLE_COUNTER - 1;
						state <= STATE_CHECK_START;
					end
					else begin
						counter <= 0;
						state <= STATE_IDLE;
					end
				end
				STATE_CHECK_START: begin
					// when signal still lowered, then we detected a start
					if (!rx_stable) begin
						counter <= BIT_SAMPLE_COUNTER - 1;
						state <= STATE_BITS;
						bits <= 9'b1_0000_0000;
					end
					else begin
						// if not, then go back to idle state
						counter <= 0;
						state <= STATE_IDLE;
					end
				end
				STATE_BITS: begin
					if (bits[1]) begin
						state <= STATE_CHECK_STOP;
					end
					counter <= BIT_SAMPLE_COUNTER - 1;
					
					// place new bit into output
					bits <= { rx_stable, bits[8:1] };
				end
				STATE_CHECK_STOP: begin
					if (rx_stable) begin
						// stop bit is high, as expected, place read data on output
						state <= STATE_IDLE;
						
						received <= 1;
					end
					else begin
						// something went wrong, we cant recover
						counter <= HALF_BIT_SAMPLE_COUNTER - 1;
						state <= STATE_IDLE;
					end
				end
			endcase
		end
	end
	
	assign rx_data = bits[8:1];
	
endmodule