module top (
    input CLK_IN,
    output PIN_C16_o,
    output PIN_D16_o,
    output LED_D9
);
	
	localparam MAIN_CLK_FREQ = 12_000_000;
	localparam TONE_A_FREQ = 440;
	
	localparam TONE_A_DELAY = MAIN_CLK_FREQ / TONE_A_FREQ;
	
	reg [31:0] counter = TONE_A_DELAY - 1;
	
	assign PIN_C16_o = counter > (TONE_A_DELAY/2 - 1);
	
	assign LED_D9 = counter > (TONE_A_DELAY/2 - 1);

always @ (posedge CLK_IN)
	counter <= (counter > 0) ? counter - 1 : TONE_A_DELAY - 1;
	
endmodule
