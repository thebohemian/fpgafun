
module sid_table_p_t(
		input            clock,
		input     [11:0] wave,
		output reg [7:0] out
		);

	always @(posedge clock) begin
		out <= wave_p_t[wave[11:1]];
	end

	//
	// convert combinatorial logic to ROM (Sorgelig)
	//

	reg [7:0] wave_p_t[2048];

	generate
		genvar i;

		for(i = 0; i<1024; i=i+1) begin
			initial wave_p_t[i] <=
				(i < 'h0ff) ? 8'h00 : (i < 'h100) ? 8'h07 : (i < 'h1fb) ? 8'h00 : (i < 'h1fc) ? 8'h1c :
				(i < 'h1fd) ? 8'h00 : (i < 'h1fe) ? 8'h3c : (i < 'h200) ? 8'h3f : (i < 'h2fd) ? 8'h00 :
				(i < 'h2fe) ? 8'h0c : (i < 'h2ff) ? 8'h5e : (i < 'h300) ? 8'h5f : (i < 'h377) ? 8'h00 :
				(i < 'h378) ? 8'h40 : (i < 'h37b) ? 8'h00 : (i < 'h37d) ? 8'h40 : (i < 'h37f) ? 8'h60 :
				(i < 'h380) ? 8'h6f : (i < 'h39f) ? 8'h00 : (i < 'h3a0) ? 8'h40 : (i < 'h3ae) ? 8'h00 :
				(i < 'h3b0) ? 8'h40 : (i < 'h3b3) ? 8'h00 : (i < 'h3b7) ? 8'h40 : (i < 'h3b8) ? 8'h60 :
				(i < 'h3ba) ? 8'h40 : (i < 'h3be) ? 8'h60 : (i < 'h3bf) ? 8'h70 : (i < 'h3c0) ? 8'h77 :
				(i < 'h3c5) ? 8'h00 : (i < 'h3cd) ? 8'h40 : (i < 'h3d0) ? 8'h60 : (i < 'h3d3) ? 8'h40 :
				(i < 'h3d7) ? 8'h60 : (i < 'h3d8) ? 8'h70 : (i < 'h3db) ? 8'h60 : (i < 'h3de) ? 8'h70 :
				(i < 'h3df) ? 8'h78 : (i < 'h3e0) ? 8'h7b : (i < 'h3e3) ? 8'h60 : (i < 'h3e4) ? 8'h70 :
				(i < 'h3e5) ? 8'h60 : (i < 'h3eb) ? 8'h70 : (i < 'h3ef) ? 8'h78 : (i < 'h3f0) ? 8'h7c :
				(i < 'h3f3) ? 8'h78 : (i < 'h3f4) ? 8'h7c : (i < 'h3f5) ? 8'h78 : (i < 'h3f7) ? 8'h7c :
				(i < 'h3f8) ? 8'h7e : (i < 'h3f9) ? 8'h7c : (i < 'h3fb) ? 8'h7e : 8'h7f;
		
			initial wave_p_t[i+1024] <=
				(i < 'h47f) ? 8'h00 : (i < 'h480) ? 8'h80 : (i < 'h4bd) ? 8'h00 : (i < 'h4c0) ? 8'h80 :
				(i < 'h4cf) ? 8'h00 : (i < 'h4d0) ? 8'h80 : (i < 'h4d7) ? 8'h00 : (i < 'h4d8) ? 8'h80 :
				(i < 'h4da) ? 8'h00 : (i < 'h4e0) ? 8'h80 : (i < 'h4e3) ? 8'h00 : (i < 'h4fe) ? 8'h80 :
				(i < 'h4ff) ? 8'h8e : (i < 'h500) ? 8'h9f : (i < 'h51f) ? 8'h00 : (i < 'h520) ? 8'h80 :
				(i < 'h52b) ? 8'h00 : (i < 'h52c) ? 8'h80 : (i < 'h52d) ? 8'h00 : (i < 'h530) ? 8'h80 :
				(i < 'h532) ? 8'h00 : (i < 'h540) ? 8'h80 : (i < 'h543) ? 8'h00 : (i < 'h544) ? 8'h80 :
				(i < 'h545) ? 8'h00 : (i < 'h57f) ? 8'h80 : (i < 'h580) ? 8'haf : (i < 'h5bb) ? 8'h80 :
				(i < 'h5bf) ? 8'ha0 : (i < 'h5c0) ? 8'hb7 : (i < 'h5cf) ? 8'h80 : (i < 'h5d0) ? 8'ha0 :
				(i < 'h5d6) ? 8'h80 : (i < 'h5db) ? 8'ha0 : (i < 'h5dc) ? 8'hb0 : (i < 'h5dd) ? 8'ha0 :
				(i < 'h5df) ? 8'hb0 : (i < 'h5e0) ? 8'hbb : (i < 'h5e6) ? 8'ha0 : (i < 'h5e8) ? 8'hb0 :
				(i < 'h5e9) ? 8'ha0 : (i < 'h5eb) ? 8'hb0 : (i < 'h5ec) ? 8'hb8 : (i < 'h5ed) ? 8'hb0 :
				(i < 'h5ef) ? 8'hb8 : (i < 'h5f0) ? 8'hbc : (i < 'h5f1) ? 8'hb0 : (i < 'h5f5) ? 8'hb8 :
				(i < 'h5f7) ? 8'hbc : (i < 'h5f8) ? 8'hbe : (i < 'h5fa) ? 8'hbc : (i < 'h5fb) ? 8'hbe :
				(i < 'h5fc) ? 8'hbf : (i < 'h5fd) ? 8'hbe : (i < 'h600) ? 8'hbf : (i < 'h63e) ? 8'h80 :
				(i < 'h640) ? 8'hc0 : (i < 'h657) ? 8'h80 : (i < 'h658) ? 8'hc0 : (i < 'h65a) ? 8'h80 :
				(i < 'h660) ? 8'hc0 : (i < 'h663) ? 8'h80 : (i < 'h664) ? 8'hc0 : (i < 'h665) ? 8'h80 :
				(i < 'h67f) ? 8'hc0 : (i < 'h680) ? 8'hcf : (i < 'h686) ? 8'h80 : (i < 'h689) ? 8'hc0 :
				(i < 'h68a) ? 8'h80 : (i < 'h6bf) ? 8'hc0 : (i < 'h6c0) ? 8'hd7 : (i < 'h6dd) ? 8'hc0 :
				(i < 'h6df) ? 8'hd0 : (i < 'h6e0) ? 8'hd9 : (i < 'h6e7) ? 8'hc0 : (i < 'h6e8) ? 8'hd0 :
				(i < 'h6e9) ? 8'hc0 : (i < 'h6ed) ? 8'hd0 : (i < 'h6ef) ? 8'hd8 : (i < 'h6f0) ? 8'hdc :
				(i < 'h6f2) ? 8'hd0 : (i < 'h6f5) ? 8'hd8 : (i < 'h6f7) ? 8'hdc : (i < 'h6f8) ? 8'hde :
				(i < 'h6fa) ? 8'hdc : (i < 'h6fb) ? 8'hde : (i < 'h6fc) ? 8'hdf : (i < 'h6fd) ? 8'hde :
				(i < 'h700) ? 8'hdf : (i < 'h71b) ? 8'hc0 : (i < 'h71c) ? 8'he0 : (i < 'h71d) ? 8'hc0 :
				(i < 'h720) ? 8'he0 : (i < 'h727) ? 8'hc0 : (i < 'h728) ? 8'he0 : (i < 'h72a) ? 8'hc0 :
				(i < 'h73f) ? 8'he0 : (i < 'h740) ? 8'he7 : (i < 'h75f) ? 8'he0 : (i < 'h760) ? 8'he8 :
				(i < 'h76e) ? 8'he0 : (i < 'h76f) ? 8'he8 : (i < 'h770) ? 8'hec : (i < 'h773) ? 8'he0 :
				(i < 'h776) ? 8'he8 : (i < 'h777) ? 8'hec : (i < 'h778) ? 8'hee : (i < 'h77b) ? 8'hec :
				(i < 'h77d) ? 8'hee : (i < 'h780) ? 8'hef : (i < 'h78d) ? 8'he0 : (i < 'h790) ? 8'hf0 :
				(i < 'h792) ? 8'he0 : (i < 'h7af) ? 8'hf0 : (i < 'h7b0) ? 8'hf4 : (i < 'h7b7) ? 8'hf0 :
				(i < 'h7b8) ? 8'hf4 : (i < 'h7b9) ? 8'hf0 : (i < 'h7bb) ? 8'hf4 : (i < 'h7bd) ? 8'hf6 :
				(i < 'h7c0) ? 8'hf7 : (i < 'h7c3) ? 8'hf0 : (i < 'h7c4) ? 8'hf8 : (i < 'h7c5) ? 8'hf0 :
				(i < 'h7db) ? 8'hf8 : (i < 'h7dd) ? 8'hfa : (i < 'h7e0) ? 8'hfb : (i < 'h7e1) ? 8'hf8 :
				(i < 'h7ed) ? 8'hfc : (i < 'h7f0) ? 8'hfd : (i < 'h7f8) ? 8'hfe : 8'hff;
		end
	endgenerate

endmodule
