
module sid_table_ps_
		(
		input            clock,

		input     [11:0] wave,

		output reg [7:0] out
		);

	always @(posedge clock) begin
		out <= wave_ps_[wave];
	end

	//
	// convert combinatorial logic to ROM (Sorgelig)
	//
	wire [7:0] wave_ps_[4096];

	generate
		genvar i;

		for(i = 0; i<1024; i=i+1) begin
			assign wave_ps_[i] =
				(i < 'h07f) ? 8'h00 : (i < 'h080) ? 8'h03 : (i < 'h0bf) ? 8'h00 : (i < 'h0c0) ? 8'h01 :
				(i < 'h0ff) ? 8'h00 : (i < 'h100) ? 8'h0f : (i < 'h17f) ? 8'h00 : (i < 'h180) ? 8'h07 :
				(i < 'h1bf) ? 8'h00 : (i < 'h1c0) ? 8'h03 : (i < 'h1df) ? 8'h00 : (i < 'h1e0) ? 8'h01 :
				(i < 'h1fd) ? 8'h00 : (i < 'h1ff) ? 8'h07 : (i < 'h200) ? 8'h1f : (i < 'h27f) ? 8'h00 :
				(i < 'h280) ? 8'h03 : (i < 'h2bf) ? 8'h00 : (i < 'h2c0) ? 8'h03 : (i < 'h2df) ? 8'h00 :
				(i < 'h2e0) ? 8'h01 : (i < 'h2fe) ? 8'h00 : (i < 'h2ff) ? 8'h01 : (i < 'h300) ? 8'h0f :
				(i < 'h33f) ? 8'h00 : (i < 'h340) ? 8'h01 : (i < 'h37f) ? 8'h00 : (i < 'h380) ? 8'h17 :
				(i < 'h3bf) ? 8'h00 : (i < 'h3c0) ? 8'h3b : (i < 'h3df) ? 8'h00 : (i < 'h3e0) ? 8'h3d :
				(i < 'h3ef) ? 8'h00 : (i < 'h3f0) ? 8'h3e : (i < 'h3f7) ? 8'h00 : (i < 'h3f8) ? 8'h3f :
				(i < 'h3f9) ? 8'h00 : (i < 'h3fa) ? 8'h0c : (i < 'h3fb) ? 8'h1c : (i < 'h3fc) ? 8'h3f :
				(i < 'h3fd) ? 8'h1e : 8'h3f;
			
			assign wave_ps_[i+1024] =
				(i < 'h47f) ? 8'h00 : (i < 'h480) ? 8'h03 :
				(i < 'h4bf) ? 8'h00 : (i < 'h4c0) ? 8'h01 : (i < 'h4ff) ? 8'h00 : (i < 'h500) ? 8'h0f :
				(i < 'h53f) ? 8'h00 : (i < 'h540) ? 8'h01 : (i < 'h57f) ? 8'h00 : (i < 'h580) ? 8'h07 :
				(i < 'h5bf) ? 8'h00 : (i < 'h5c0) ? 8'h0b : (i < 'h5df) ? 8'h00 : (i < 'h5e0) ? 8'h0a :
				(i < 'h5ef) ? 8'h00 : (i < 'h5f0) ? 8'h5e : (i < 'h5f7) ? 8'h00 : (i < 'h5f8) ? 8'h5f :
				(i < 'h5fb) ? 8'h00 : (i < 'h5fc) ? 8'h5f : (i < 'h5fd) ? 8'h0c : (i < 'h600) ? 8'h5f :
				(i < 'h63f) ? 8'h00 : (i < 'h640) ? 8'h01 : (i < 'h67f) ? 8'h00 : (i < 'h680) ? 8'h47 :
				(i < 'h6bf) ? 8'h00 : (i < 'h6c0) ? 8'h43 : (i < 'h6df) ? 8'h00 : (i < 'h6e0) ? 8'h65 :
				(i < 'h6ef) ? 8'h00 : (i < 'h6f0) ? 8'h6e : (i < 'h6f7) ? 8'h00 : (i < 'h6f8) ? 8'h6f :
				(i < 'h6f9) ? 8'h00 : (i < 'h6fb) ? 8'h40 : (i < 'h6fc) ? 8'h6f : (i < 'h6fd) ? 8'h40 :
				(i < 'h700) ? 8'h6f : (i < 'h73f) ? 8'h00 : (i < 'h740) ? 8'h63 : (i < 'h75e) ? 8'h00 :
				(i < 'h75f) ? 8'h40 : (i < 'h760) ? 8'h61 : (i < 'h767) ? 8'h00 : (i < 'h768) ? 8'h40 :
				(i < 'h76b) ? 8'h00 : (i < 'h76c) ? 8'h40 : (i < 'h76d) ? 8'h00 : (i < 'h76f) ? 8'h40 :
				(i < 'h770) ? 8'h70 : (i < 'h772) ? 8'h00 : (i < 'h777) ? 8'h40 : (i < 'h778) ? 8'h70 :
				(i < 'h779) ? 8'h40 : (i < 'h77b) ? 8'h60 : (i < 'h77c) ? 8'h77 : (i < 'h77d) ? 8'h60 :
				(i < 'h780) ? 8'h77 : (i < 'h78f) ? 8'h00 : (i < 'h790) ? 8'h40 : (i < 'h796) ? 8'h00 :
				(i < 'h797) ? 8'h40 : (i < 'h798) ? 8'h60 : (i < 'h799) ? 8'h00 : (i < 'h79b) ? 8'h40 :
				(i < 'h79c) ? 8'h60 : (i < 'h79d) ? 8'h40 : (i < 'h79f) ? 8'h60 : (i < 'h7a0) ? 8'h79 :
				(i < 'h7a1) ? 8'h00 : (i < 'h7a7) ? 8'h40 : (i < 'h7a8) ? 8'h60 : (i < 'h7ab) ? 8'h40 :
				(i < 'h7af) ? 8'h60 : (i < 'h7b0) ? 8'h78 : (i < 'h7b1) ? 8'h40 : (i < 'h7b7) ? 8'h60 :
				(i < 'h7b8) ? 8'h78 : (i < 'h7b9) ? 8'h60 : (i < 'h7bb) ? 8'h70 : (i < 'h7bc) ? 8'h78 :
				(i < 'h7bd) ? 8'h70 : (i < 'h7be) ? 8'h79 : (i < 'h7c0) ? 8'h7b : (i < 'h7c7) ? 8'h60 :
				(i < 'h7c8) ? 8'h70 : (i < 'h7cb) ? 8'h60 : (i < 'h7cc) ? 8'h70 : (i < 'h7cd) ? 8'h60 :
				(i < 'h7cf) ? 8'h70 : (i < 'h7d0) ? 8'h7c : (i < 'h7d1) ? 8'h60 : (i < 'h7d7) ? 8'h70 :
				(i < 'h7d8) ? 8'h7c : (i < 'h7d9) ? 8'h70 : (i < 'h7db) ? 8'h78 : (i < 'h7dc) ? 8'h7c :
				(i < 'h7dd) ? 8'h78 : (i < 'h7df) ? 8'h7c : (i < 'h7e0) ? 8'h7d : (i < 'h7e1) ? 8'h70 :
				(i < 'h7e7) ? 8'h78 : (i < 'h7e8) ? 8'h7c : (i < 'h7e9) ? 8'h78 : (i < 'h7eb) ? 8'h7c :
				(i < 'h7ec) ? 8'h7e : (i < 'h7ed) ? 8'h7c : (i < 'h7f0) ? 8'h7e : (i < 'h7f3) ? 8'h7c :
				(i < 'h7f5) ? 8'h7e : (i < 'h7f8) ? 8'h7f : (i < 'h7f9) ? 8'h7e : (i < 'h7ff) ? 8'h7f :
				8'hff;

		end
		
		for(i = 0; i<512; i=i+1) begin
			assign wave_ps_[i+2048] =
				(i < 'h87f) ? 8'h00 : (i < 'h880) ? 8'h03 : (i < 'h8bf) ? 8'h00 :
				(i < 'h8c0) ? 8'h01 : (i < 'h8ff) ? 8'h00 : (i < 'h900) ? 8'h8f : (i < 'h93f) ? 8'h00 :
				(i < 'h940) ? 8'h01 : (i < 'h97f) ? 8'h00 : (i < 'h980) ? 8'h87 : (i < 'h9bf) ? 8'h00 :
				(i < 'h9c0) ? 8'h83 : (i < 'h9de) ? 8'h00 : (i < 'h9df) ? 8'h80 : (i < 'h9e0) ? 8'h8d :
				(i < 'h9e7) ? 8'h00 : (i < 'h9e8) ? 8'h80 : (i < 'h9eb) ? 8'h00 : (i < 'h9ec) ? 8'h80 :
				(i < 'h9ed) ? 8'h00 : (i < 'h9ef) ? 8'h80 : (i < 'h9f0) ? 8'h8e : (i < 'h9f3) ? 8'h00 :
				(i < 'h9f7) ? 8'h80 : (i < 'h9f8) ? 8'h8f : (i < 'h9fb) ? 8'h80 : (i < 'h9fc) ? 8'h9f :
				(i < 'h9fd) ? 8'h80 : 8'h9f;
			
			assign wave_ps_[i+2560] =
				(i < 'ha3f) ? 8'h00 : (i < 'ha40) ? 8'h01 :
				(i < 'ha6f) ? 8'h00 : (i < 'ha70) ? 8'h80 : (i < 'ha77) ? 8'h00 : (i < 'ha78) ? 8'h80 :
				(i < 'ha7b) ? 8'h00 : (i < 'ha7c) ? 8'h80 : (i < 'ha7d) ? 8'h00 : (i < 'ha7f) ? 8'h80 :
				(i < 'ha80) ? 8'h87 : (i < 'ha9f) ? 8'h00 : (i < 'haa0) ? 8'h80 : (i < 'haaf) ? 8'h00 :
				(i < 'hab0) ? 8'h80 : (i < 'hab7) ? 8'h00 : (i < 'hab8) ? 8'h80 : (i < 'habb) ? 8'h00 :
				(i < 'habf) ? 8'h80 : (i < 'hac0) ? 8'h83 : (i < 'hacf) ? 8'h00 : (i < 'had0) ? 8'h80 :
				(i < 'had5) ? 8'h00 : (i < 'had8) ? 8'h80 : (i < 'had9) ? 8'h00 : (i < 'hadf) ? 8'h80 :
				(i < 'hae0) ? 8'h81 : (i < 'haef) ? 8'h80 : (i < 'haf0) ? 8'h84 : (i < 'haf7) ? 8'h80 :
				(i < 'haf8) ? 8'h87 : (i < 'hafb) ? 8'h80 : (i < 'hafc) ? 8'h87 : (i < 'hafd) ? 8'h80 :
				(i < 'hafe) ? 8'h8f : (i < 'hb00) ? 8'haf : (i < 'hb0f) ? 8'h00 : (i < 'hb10) ? 8'h80 :
				(i < 'hb17) ? 8'h00 : (i < 'hb18) ? 8'h80 : (i < 'hb1b) ? 8'h00 : (i < 'hb20) ? 8'h80 :
				(i < 'hb23) ? 8'h00 : (i < 'hb24) ? 8'h80 : (i < 'hb26) ? 8'h00 : (i < 'hb28) ? 8'h80 :
				(i < 'hb29) ? 8'h00 : (i < 'hb3f) ? 8'h80 : (i < 'hb40) ? 8'h83 : (i < 'hb5f) ? 8'h80 :
				(i < 'hb60) ? 8'h81 : (i < 'hb6f) ? 8'h80 : (i < 'hb70) ? 8'ha0 : (i < 'hb77) ? 8'h80 :
				(i < 'hb78) ? 8'ha0 : (i < 'hb7b) ? 8'h80 : (i < 'hb7c) ? 8'ha0 : (i < 'hb7d) ? 8'h80 :
				(i < 'hb7e) ? 8'ha3 : (i < 'hb80) ? 8'hb7 : (i < 'hb9f) ? 8'h80 : (i < 'hba0) ? 8'hb1 :
				(i < 'hbaf) ? 8'h80 : (i < 'hbb0) ? 8'hb0 : (i < 'hbb7) ? 8'h80 : (i < 'hbb8) ? 8'hb0 :
				(i < 'hbb9) ? 8'h80 : (i < 'hbbb) ? 8'ha0 : (i < 'hbbc) ? 8'hb0 : (i < 'hbbd) ? 8'ha0 :
				(i < 'hbbe) ? 8'hb8 : (i < 'hbbf) ? 8'hb9 : (i < 'hbc0) ? 8'hbb : (i < 'hbc7) ? 8'h80 :
				(i < 'hbc8) ? 8'ha0 : (i < 'hbcb) ? 8'h80 : (i < 'hbcc) ? 8'ha0 : (i < 'hbcd) ? 8'h80 :
				(i < 'hbcf) ? 8'ha0 : (i < 'hbd0) ? 8'hb8 : (i < 'hbd1) ? 8'h80 : (i < 'hbd7) ? 8'ha0 :
				(i < 'hbd8) ? 8'hb8 : (i < 'hbd9) ? 8'ha0 : (i < 'hbdb) ? 8'hb0 : (i < 'hbdc) ? 8'hb8 :
				(i < 'hbdd) ? 8'hb0 : (i < 'hbdf) ? 8'hbc : (i < 'hbe0) ? 8'hbd : (i < 'hbe1) ? 8'ha0 :
				(i < 'hbe5) ? 8'hb0 : (i < 'hbe7) ? 8'hb8 : (i < 'hbe8) ? 8'hbc : (i < 'hbe9) ? 8'hb0 :
				(i < 'hbeb) ? 8'hb8 : (i < 'hbec) ? 8'hbc : (i < 'hbed) ? 8'hb8 : (i < 'hbee) ? 8'hbc :
				(i < 'hbf0) ? 8'hbe : (i < 'hbf1) ? 8'hb8 : (i < 'hbf3) ? 8'hbc : (i < 'hbf4) ? 8'hbe :
				(i < 'hbf5) ? 8'hbc : (i < 'hbf7) ? 8'hbe : (i < 'hbf8) ? 8'hbf : (i < 'hbf9) ? 8'hbe :
				8'hbf;

			assign wave_ps_[i+3072] =
				(i < 'hc03) ? 8'h00 : (i < 'hc04) ? 8'h80 : (i < 'hc07) ? 8'h00 :
				(i < 'hc08) ? 8'h80 : (i < 'hc0b) ? 8'h00 : (i < 'hc0c) ? 8'h80 : (i < 'hc0f) ? 8'h00 :
				(i < 'hc10) ? 8'h80 : (i < 'hc11) ? 8'h00 : (i < 'hc18) ? 8'h80 : (i < 'hc19) ? 8'h00 :
				(i < 'hc3f) ? 8'h80 : (i < 'hc40) ? 8'h81 : (i < 'hc7f) ? 8'h80 : (i < 'hc80) ? 8'hc7 :
				(i < 'hcbe) ? 8'h80 : (i < 'hcbf) ? 8'hc0 : (i < 'hcc0) ? 8'hc3 : (i < 'hccf) ? 8'h80 :
				(i < 'hcd0) ? 8'hc0 : (i < 'hcd7) ? 8'h80 : (i < 'hcd8) ? 8'hc0 : (i < 'hcdb) ? 8'h80 :
				(i < 'hcdc) ? 8'hc0 : (i < 'hcdd) ? 8'h80 : (i < 'hcdf) ? 8'hc0 : (i < 'hce0) ? 8'hc1 :
				(i < 'hce7) ? 8'h80 : (i < 'hce8) ? 8'hc0 : (i < 'hceb) ? 8'h80 : (i < 'hcf7) ? 8'hc0 :
				(i < 'hcf8) ? 8'hc7 : (i < 'hcfb) ? 8'hc0 : (i < 'hcfc) ? 8'hc7 : (i < 'hcfd) ? 8'hc0 :
				(i < 'hd00) ? 8'hcf : (i < 'hd1f) ? 8'h80 : (i < 'hd20) ? 8'hc0 : (i < 'hd2f) ? 8'h80 :
				(i < 'hd30) ? 8'hc0 : (i < 'hd36) ? 8'h80 : (i < 'hd38) ? 8'hc0 : (i < 'hd39) ? 8'h80 :
				(i < 'hd3f) ? 8'hc0 : (i < 'hd40) ? 8'hc3 : (i < 'hd47) ? 8'h80 : (i < 'hd48) ? 8'hc0 :
				(i < 'hd4b) ? 8'h80 : (i < 'hd4c) ? 8'hc0 : (i < 'hd4d) ? 8'h80 : (i < 'hd50) ? 8'hc0 :
				(i < 'hd51) ? 8'h80 : (i < 'hd5f) ? 8'hc0 : (i < 'hd60) ? 8'hc1 : (i < 'hd7d) ? 8'hc0 :
				(i < 'hd7e) ? 8'hc1 : (i < 'hd7f) ? 8'hc7 : (i < 'hd80) ? 8'hd7 : (i < 'hdaf) ? 8'hc0 :
				(i < 'hdb0) ? 8'hd0 : (i < 'hdb7) ? 8'hc0 : (i < 'hdb8) ? 8'hd0 : (i < 'hdbb) ? 8'hc0 :
				(i < 'hdbc) ? 8'hd0 : (i < 'hdbd) ? 8'hc0 : (i < 'hdbe) ? 8'hd0 : (i < 'hdbf) ? 8'hd8 :
				(i < 'hdc0) ? 8'hdb : (i < 'hdcf) ? 8'hc0 : (i < 'hdd0) ? 8'hd8 : (i < 'hdd7) ? 8'hc0 :
				(i < 'hdd8) ? 8'hd8 : (i < 'hddb) ? 8'hc0 : (i < 'hddc) ? 8'hd8 : (i < 'hddd) ? 8'hd0 :
				(i < 'hddf) ? 8'hd8 : (i < 'hde0) ? 8'hdd : (i < 'hde3) ? 8'hc0 : (i < 'hde4) ? 8'hd0 :
				(i < 'hde5) ? 8'hc0 : (i < 'hde7) ? 8'hd0 : (i < 'hde8) ? 8'hdc : (i < 'hde9) ? 8'hd0 :
				(i < 'hdeb) ? 8'hd8 : (i < 'hdec) ? 8'hdc : (i < 'hded) ? 8'hd8 : (i < 'hdef) ? 8'hdc :
				(i < 'hdf0) ? 8'hde : (i < 'hdf1) ? 8'hd8 : (i < 'hdf3) ? 8'hdc : (i < 'hdf4) ? 8'hde :
				(i < 'hdf5) ? 8'hdc : (i < 'hdf7) ? 8'hde : (i < 'hdf8) ? 8'hdf : (i < 'hdf9) ? 8'hde :
				8'hdf;
				
			assign wave_ps_[i+3584] =
				(i < 'he3f) ? 8'hc0 : (i < 'he40) ? 8'he3 : (i < 'he57) ? 8'hc0 :
				(i < 'he58) ? 8'he0 : (i < 'he5b) ? 8'hc0 : (i < 'he5c) ? 8'he0 : (i < 'he5d) ? 8'hc0 :
				(i < 'he5f) ? 8'he0 : (i < 'he60) ? 8'he1 : (i < 'he67) ? 8'hc0 : (i < 'he68) ? 8'he0 :
				(i < 'he6b) ? 8'hc0 : (i < 'he70) ? 8'he0 : (i < 'he71) ? 8'hc0 : (i < 'he7d) ? 8'he0 :
				(i < 'he7e) ? 8'he1 : (i < 'he7f) ? 8'he3 : (i < 'he80) ? 8'he7 : (i < 'he87) ? 8'hc0 :
				(i < 'he88) ? 8'he0 : (i < 'he8b) ? 8'hc0 : (i < 'he8c) ? 8'he0 : (i < 'he8d) ? 8'hc0 :
				(i < 'he90) ? 8'he0 : (i < 'he93) ? 8'hc0 : (i < 'he94) ? 8'he0 : (i < 'he95) ? 8'hc0 :
				(i < 'hebf) ? 8'he0 : (i < 'hec0) ? 8'heb : (i < 'hedb) ? 8'he0 : (i < 'hedc) ? 8'he8 :
				(i < 'hedd) ? 8'he0 : (i < 'hedf) ? 8'he8 : (i < 'hee0) ? 8'hed : (i < 'hee7) ? 8'he0 :
				(i < 'hee8) ? 8'hec : (i < 'heeb) ? 8'he0 : (i < 'heec) ? 8'hec : (i < 'heed) ? 8'he8 :
				(i < 'heef) ? 8'hec : (i < 'hef0) ? 8'hee : (i < 'hef3) ? 8'he8 : (i < 'hef5) ? 8'hec :
				(i < 'hef7) ? 8'hee : (i < 'hef8) ? 8'hef : (i < 'hef9) ? 8'hec : (i < 'hf00) ? 8'hef :
				(i < 'hf1f) ? 8'he0 : (i < 'hf20) ? 8'hf0 : (i < 'hf27) ? 8'he0 : (i < 'hf28) ? 8'hf0 :
				(i < 'hf2b) ? 8'he0 : (i < 'hf2c) ? 8'hf0 : (i < 'hf2d) ? 8'he0 : (i < 'hf30) ? 8'hf0 :
				(i < 'hf33) ? 8'he0 : (i < 'hf3f) ? 8'hf0 : (i < 'hf40) ? 8'hf3 : (i < 'hf43) ? 8'he0 :
				(i < 'hf5f) ? 8'hf0 : (i < 'hf60) ? 8'hf5 : (i < 'hf6d) ? 8'hf0 : (i < 'hf6f) ? 8'hf4 :
				(i < 'hf70) ? 8'hf6 : (i < 'hf73) ? 8'hf0 : (i < 'hf74) ? 8'hf4 : (i < 'hf75) ? 8'hf0 :
				(i < 'hf76) ? 8'hf4 : (i < 'hf77) ? 8'hf6 : (i < 'hf78) ? 8'hf7 : (i < 'hf79) ? 8'hf4 :
				(i < 'hf7b) ? 8'hf6 : (i < 'hf80) ? 8'hf7 : (i < 'hf87) ? 8'hf0 : (i < 'hf88) ? 8'hf8 :
				(i < 'hf8d) ? 8'hf0 : (i < 'hf90) ? 8'hf8 : (i < 'hf93) ? 8'hf0 : (i < 'hf94) ? 8'hf8 :
				(i < 'hf95) ? 8'hf0 : (i < 'hf9f) ? 8'hf8 : (i < 'hfa0) ? 8'hf9 : (i < 'hfaf) ? 8'hf8 :
				(i < 'hfb0) ? 8'hfa : (i < 'hfb7) ? 8'hf8 : (i < 'hfb8) ? 8'hfb : (i < 'hfb9) ? 8'hf8 :
				(i < 'hfbb) ? 8'hfa : (i < 'hfc0) ? 8'hfb : (i < 'hfc3) ? 8'hf8 : (i < 'hfc4) ? 8'hfc :
				(i < 'hfc5) ? 8'hf8 : (i < 'hfd7) ? 8'hfc : (i < 'hfd8) ? 8'hfd : (i < 'hfdb) ? 8'hfc :
				(i < 'hfe0) ? 8'hfd : (i < 'hfe2) ? 8'hfc : (i < 'hff0) ? 8'hfe : 8'hff;
		end

	endgenerate

endmodule
