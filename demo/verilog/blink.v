module top(
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input CLK_IN
		);

	localparam COUNTER_WIDTH = 24;

	// 2^24 = 16 million or so, approx 0.75 Hz with 12 MHz clock.
	reg [COUNTER_WIDTH-1:0] counter;

	always @(posedge CLK_IN)
		counter <= counter + 1;

		assign LED_D9 = counter[COUNTER_WIDTH - 1];
		assign LED_D8 = counter[COUNTER_WIDTH - 2];
		assign LED_D7 = counter[COUNTER_WIDTH - 3];
		assign LED_D6 = counter[COUNTER_WIDTH - 4];
		assign LED_D5 = counter[COUNTER_WIDTH - 5];
		assign LED_D4 = counter[COUNTER_WIDTH - 6];
		assign LED_D3 = counter[COUNTER_WIDTH - 7];
		assign LED_D2 = counter[COUNTER_WIDTH - 8];

endmodule
