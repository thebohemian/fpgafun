module top(
		input PIN_E16_i,
		output PIN_C16_o);

	assign PIN_C16_o = ~PIN_E16_i;

endmodule
