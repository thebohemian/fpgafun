module main(
		input CLK_IN,
		output GLED5,
		output RLED1,
		output RLED2,
		output RLED3,
		output RLED4);

	/*
	typedef enum logic [2:0] {
		RED, GREEN, MAGENTA
	} color_t;
	*/

	localparam COUNTER_WIDTH = 24;

	// 2^24 = 16 million or so, approx 0.75 Hz with 12 MHz clock.
	reg [COUNTER_WIDTH-1:0] counter;

	always @(posedge CLK_IN)
		counter <= counter + 1;

	assign GLED5 = counter[COUNTER_WIDTH - 1]; // MSB
	assign RLED1 = counter[COUNTER_WIDTH - 2];
	assign RLED2 = counter[COUNTER_WIDTH - 3];
	assign RLED3 = counter[COUNTER_WIDTH - 4];
	assign RLED4 = counter[COUNTER_WIDTH - 5];

endmodule
