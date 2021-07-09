
module column_processor #(parameter size , parameter width) (
	input [width - 1 : 0] in_a,
	input [width - 1: 0] in_b,
	input in_clk,
	input in_reset,
	input [0:1] i_mult,
	input [size -1 : 0] in_index,
	output out_ready,
	output [width - 1: 0] out_a,
	output [width - 1: 0] out_b,
	output [width - 1: 0] out_c);
