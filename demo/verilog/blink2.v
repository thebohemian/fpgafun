module main(
		input CLK_IN,
		input PIN_C16_i,
		input PIN_D16_i,
		output LED_D9,
		output LED_D8,
		output LED_D7,
		output LED_D6,
		output LED_D5,
		output LED_D4,
		output LED_D3,
		output LED_D2);
	
	localparam MAIN_CLOCK_FREQ = 12_000_000;
	
	localparam SWITCH_LIGHT_FREQ = 4;
	localparam SWITCH_LIGHT_COUNT = MAIN_CLOCK_FREQ/SWITCH_LIGHT_FREQ;
	reg [31:0] switch_light_counter = SWITCH_LIGHT_COUNT - 1;

	localparam SAMPLE_FREQ = 8;
	localparam SAMPLE_COUNT = MAIN_CLOCK_FREQ/SAMPLE_FREQ;
	reg [31:0] sample_counter = 0;
	
	reg [7:0] led = 1;
	
	reg [2:0] button_sampling = 0;
	reg button = 1;
	reg button2 = 1;
	reg buttonMs = 1;
	
	wire sample_ce = (switch_light_counter == 0);

	always @ (posedge CLK_IN) begin
		switch_light_counter <= (switch_light_counter > 0) ? switch_light_counter - 1 : SWITCH_LIGHT_COUNT - 1;
			
		if (switch_light_counter == 0) begin
			// left
			if (!button2)
				led <= led[7] ? 1 : led << 1;

			// right
			if (!button) 
				led <= led[0] ? 8'b1000_0000 : led >> 1;
			
		end

	end

	always @ (posedge CLK_IN) begin
		case(button_sampling)
			0: begin
				if (PIN_D16_i != button2) begin
					buttonMs = PIN_D16_i;		// metastable
					sample_counter <= SAMPLE_COUNT - 1;
					button_sampling <= 2;
				end
				if (PIN_C16_i != button) begin
					buttonMs = PIN_C16_i;		// metastable
					sample_counter <= SAMPLE_COUNT - 1;
					button_sampling <= 1;
				end
			end
			1: begin
				if (sample_counter == 0) begin
					button <= buttonMs;
					button_sampling <= 0;
				end
				sample_counter <= (sample_counter > 0) ? sample_counter - 1 : 0;
			end
			2: begin
				if (sample_counter == 0) begin
					button2 <= buttonMs;
					button_sampling <= 0;
				end
				sample_counter <= (sample_counter > 0) ? sample_counter - 1 : 0;
			end
		endcase
		
	end
	
	assign PIN_D16_o = button_sampling;
	
	assign { LED_D9, LED_D8, LED_D7, LED_D6, LED_D5, LED_D4, LED_D3, LED_D2 } = led;
	
endmodule
