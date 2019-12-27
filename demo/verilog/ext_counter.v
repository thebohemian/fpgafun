/** measures a value on PIN D16
 * and counts up each time a "posedge" is detected.
 * 
 * the input value must be between 0 and 3.3V to be
 * detected.
 * 
 * the implementation of the detection is independant
 * of the input frequency. it is able to detect very slow
 * and very fast changes equally.
 * /
module ext_counter (
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2,
		
		input D16_i,
		
		input CLK_IN
		);
	
	reg input_latch_unstable = 0;
	reg input_latch_next = 0;
	reg input_latch_last = 0;
	reg last_value = 0;
	
	reg [15:0] led_counter = 0;

	always @ (posedge CLK_IN) begin
		input_latch_unstable <= D16_i;	// metastable
		input_latch_next <= input_latch_unstable;	// stable
		input_latch_last <= input_latch_next;		// last value
		
		if (!input_latch_last && input_latch_next) begin
			// posedge
			led_counter <= led_counter + 1;
		end
	end

	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = led_counter[7:0];

endmodule