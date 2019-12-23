/*
`include "sid_table__st.v"
`include "sid_table_p_t.v"
`include "sid_table_ps_.v"
`include "sid_table_pst.v"
*/

`include "sid_table__st_mem.v"
`include "sid_table_p_t_mem.v"
`include "sid_table_ps__mem.v"
`include "sid_table_pst_mem.v"

module sid_tables
(
	input            clock,

	input     [11:0] sawtooth,
	input     [11:0] triangle,

	output reg [7:0] _st_out,
	output reg [7:0] p_t_out,
	output reg [7:0] ps__out,
	output reg [7:0] pst_out
);

	sid_table__st table__st(
		.clock(clock),
		.wave(sawtooth),
		.out(_st_out)
	);

	sid_table_p_t table_p_t(
		.clock(clock),
		.wave(triangle),
		.out(p_t_out)
	);

	sid_table_ps_ table_ps_(
		.clock(clock),
		.wave(sawtooth),
		.out(ps__out)
	);

	sid_table_pst table_pst(
		.clock(clock),
		.wave(sawtooth),
		.out(pst_out)
	);

endmodule
