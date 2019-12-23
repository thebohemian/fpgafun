
module sid_table__st(
		input            clock,
		input     [11:0] wave,
		output reg [7:0] out
		);

	always @(posedge clock) begin
		out <= wave__st[wave];
	end

	//
	// convert combinatorial logic to ROM (Sorgelig)
	//
	reg [7:0] wave__st[4096];

	generate
		genvar i;

		for(i = 0; i<4096; i=i+1) begin initial wave__st[i] <=
				(i < 'h07e) ? 8'h00 : (i < 'h080) ? 8'h03 : (i < 'h0fc) ? 8'h00 : (i < 'h100) ? 8'h07 :
				(i < 'h17e) ? 8'h00 : (i < 'h180) ? 8'h03 : (i < 'h1f8) ? 8'h00 : (i < 'h1fc) ? 8'h0e :
				(i < 'h200) ? 8'h0f : (i < 'h27e) ? 8'h00 : (i < 'h280) ? 8'h03 : (i < 'h2fc) ? 8'h00 :
				(i < 'h300) ? 8'h07 : (i < 'h37e) ? 8'h00 : (i < 'h380) ? 8'h03 : (i < 'h3bf) ? 8'h00 :
				(i < 'h3c0) ? 8'h01 : (i < 'h3f0) ? 8'h00 : (i < 'h3f8) ? 8'h1c : (i < 'h3fa) ? 8'h1e :
				(i < 'h400) ? 8'h1f : (i < 'h47e) ? 8'h00 : (i < 'h480) ? 8'h03 : (i < 'h4fc) ? 8'h00 :
				(i < 'h500) ? 8'h07 : (i < 'h57e) ? 8'h00 : (i < 'h580) ? 8'h03 : (i < 'h5f8) ? 8'h00 :
				(i < 'h5fc) ? 8'h0e : (i < 'h5ff) ? 8'h0f : (i < 'h600) ? 8'h1f : (i < 'h67e) ? 8'h00 :
				(i < 'h680) ? 8'h03 : (i < 'h6fc) ? 8'h00 : (i < 'h700) ? 8'h07 : (i < 'h77e) ? 8'h00 :
				(i < 'h780) ? 8'h03 : (i < 'h7bf) ? 8'h00 : (i < 'h7c0) ? 8'h01 : (i < 'h7e0) ? 8'h00 :
				(i < 'h7f0) ? 8'h38 : (i < 'h7f7) ? 8'h3c : (i < 'h7f8) ? 8'h3e : (i < 'h800) ? 8'h7f :
				(i < 'h87e) ? 8'h00 : (i < 'h880) ? 8'h03 : (i < 'h8fc) ? 8'h00 : (i < 'h900) ? 8'h07 :
				(i < 'h97e) ? 8'h00 : (i < 'h980) ? 8'h03 : (i < 'h9f8) ? 8'h00 : (i < 'h9fc) ? 8'h0e :
				(i < 'ha00) ? 8'h0f : (i < 'ha7e) ? 8'h00 : (i < 'ha80) ? 8'h03 : (i < 'hafc) ? 8'h00 :
				(i < 'hb00) ? 8'h07 : (i < 'hb7e) ? 8'h00 : (i < 'hb80) ? 8'h03 : (i < 'hbbf) ? 8'h00 :
				(i < 'hbc0) ? 8'h01 : (i < 'hbf0) ? 8'h00 : (i < 'hbf8) ? 8'h1c : (i < 'hbfa) ? 8'h1e :
				(i < 'hbfe) ? 8'h1f : (i < 'hc00) ? 8'h3f : (i < 'hc7e) ? 8'h00 : (i < 'hc80) ? 8'h03 :
				(i < 'hcfc) ? 8'h00 : (i < 'hd00) ? 8'h07 : (i < 'hd7e) ? 8'h00 : (i < 'hd80) ? 8'h03 :
				(i < 'hdbf) ? 8'h00 : (i < 'hdc0) ? 8'h01 : (i < 'hdf8) ? 8'h00 : (i < 'hdfc) ? 8'h0e :
				(i < 'hdfe) ? 8'h0f : (i < 'he00) ? 8'h1f : (i < 'he7c) ? 8'h00 : (i < 'he7d) ? 8'h80 :
				(i < 'he7e) ? 8'h00 : (i < 'he80) ? 8'h83 : (i < 'hefc) ? 8'h80 : (i < 'heff) ? 8'h87 :
				(i < 'hf00) ? 8'h8f : (i < 'hf01) ? 8'hc0 : (i < 'hf03) ? 8'he0 : (i < 'hf05) ? 8'hc0 :
				(i < 'hf09) ? 8'he0 : (i < 'hf11) ? 8'hc0 : (i < 'hf13) ? 8'he0 : (i < 'hf18) ? 8'hc0 :
				(i < 'hf19) ? 8'he0 : (i < 'hf21) ? 8'hc0 : (i < 'hf23) ? 8'he0 : (i < 'hf25) ? 8'hc0 :
				(i < 'hf2b) ? 8'he0 : (i < 'hf2c) ? 8'hc0 : (i < 'hf2d) ? 8'he0 : (i < 'hf2e) ? 8'hc0 :
				(i < 'hf7e) ? 8'he0 : (i < 'hf80) ? 8'he3 : (i < 'hfbf) ? 8'hf0 : (i < 'hfc0) ? 8'hf1 :
				(i < 'hfe0) ? 8'hf8 : (i < 'hff0) ? 8'hfc : (i < 'hff8) ? 8'hfe : 8'hff;
		end

	endgenerate

endmodule
