
module sid_table_pst
		(
		input            clock,

		input     [11:0] wave,

		output reg [7:0] out
		);

	always @(posedge clock) begin
		out <= wave_pst[wave];
	end

	//
	// convert combinatorial logic to ROM (Sorgelig)
	//
	reg [7:0] wave_pst[4096];

	generate
		genvar i;

		for(i = 0; i<4096; i=i+1) initial wave_pst[i] <=
				(i < 'h3ff) ? 8'h00 : (i < 'h400) ? 8'h1f : (i < 'h7ee) ? 8'h00 : (i < 'h7ef) ? 8'h20 :
				(i < 'h7f0) ? 8'h70 : (i < 'h7f1) ? 8'h60 : (i < 'h7f2) ? 8'h20 : (i < 'h7f7) ? 8'h70 :
				(i < 'h7fa) ? 8'h78 : (i < 'h7fc) ? 8'h7c : (i < 'h7fe) ? 8'h7e : (i < 'h800) ? 8'h7f :
				(i < 'hbfd) ? 8'h00 : (i < 'hbfe) ? 8'h08 : (i < 'hbff) ? 8'h1e : (i < 'hc00) ? 8'h3f :
				(i < 'hdf7) ? 8'h00 : (i < 'hdfe) ? 8'h80 : (i < 'hdff) ? 8'h8c : (i < 'he00) ? 8'h9f :
				(i < 'he3e) ? 8'h00 : (i < 'he40) ? 8'h80 : (i < 'he5e) ? 8'h00 : (i < 'he60) ? 8'h80 :
				(i < 'he66) ? 8'h00 : (i < 'he67) ? 8'h80 : (i < 'he6a) ? 8'h00 : (i < 'he80) ? 8'h80 :
				(i < 'he82) ? 8'h00 : (i < 'he83) ? 8'h80 : (i < 'he85) ? 8'h00 : (i < 'he89) ? 8'h80 :
				(i < 'he8a) ? 8'h00 : (i < 'heee) ? 8'h80 : (i < 'heff) ? 8'hc0 : (i < 'hf00) ? 8'hcf :
				(i < 'hf6f) ? 8'hc0 : (i < 'hf70) ? 8'he0 : (i < 'hf74) ? 8'hc0 : (i < 'hf7f) ? 8'he0 :
				(i < 'hf80) ? 8'he3 : (i < 'hfb6) ? 8'he0 : (i < 'hfda) ? 8'hf0 : (i < 'hfeb) ? 8'hf8 :
				(i < 'hff5) ? 8'hfc : (i < 'hff9) ? 8'hfe : 8'hff;
	endgenerate

endmodule
