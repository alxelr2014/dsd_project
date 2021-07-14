`timescale 1ns/1ns
`include "column_processor.v"

module column_processor_tb();

parameter size = 2;
parameter cell_width = 32;
parameter width = cell_width *size;

parameter half_cc = 1;
reg clk, reset , ready , ack;
reg [width - 1: 0 ] in_a;
reg [width - 1: 0 ] in_b;

wire [width - 1: 0] out_data;
wire out_ready;

column_processor #(.size(size)  , .cell_width(cell_width)) uut (
	.in_row_a (in_a),
	.in_col_b(in_b),
	.in_clk (clk),
	.in_reset (reset),
	.in_ready (ready),
	.out_ack (ack),
	.out_ready (out_ready),
	.out_cell_c (out_data));

initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
end

initial begin
	reset = 1'b1;
	#(half_cc) reset = 1'b0;
	#(half_cc) reset = 1'b1; 
	#1000
	$monitor("@ time = %d, in_a = %h , in_b = %h , in_ready = %b , out_ack = %b , out_ready = %b, out_data = %h , state = %b , mult = %h",$realtime,
	 in_a, in_b, ready , ack , out_ready , out_data , uut.r_states, uut.n_mult_out_z);

	in_a = 64'h40B33333409CCCCD;
	in_b = 64'h3F23D70A3D23D70A;
	ready = 1;
	#10000
	ack = 1;
	ready = 0;
	#(4*half_cc);
	in_b = 64'h3D34395841470A3D;
	ready = 1;
	#10000
	ack = 1;
	ready = 0;
	#(4*half_cc);
end
endmodule