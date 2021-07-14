`timescale 1ns/1ns
`include "column_mult.v"

module column_multiplier_tb();

parameter size = 2;
parameter cell_width = 32;
parameter width = cell_width *size;

parameter half_cc = 1;
reg clk, reset , ready , ack;
reg [width - 1: 0 ] in_a;
reg [width - 1: 0 ] in_b;

wire [width - 1: 0] out_data;
wire out_ready;

column_multiplier #(.size(size)  , .cell_width(cell_width)) uut (
	.in_a (in_a),
	.in_b(in_b),
	.in_clk (clk),
	.in_reset (reset),
	.in_ready (ready),
	.out_ack (ack),
	.out_ready (out_ready),
	.out_c (out_data));

initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
end

integer  i,j, k;
integer file;
reg [cell_width - 1:0] my_reg;


initial begin
	reset = 1'b1;
	#(half_cc) reset = 1'b0;
	#(half_cc) reset = 1'b1; 
	#1000
	$monitor("@ time = %d, in_a = %h , in_b = %h , in_ready = %b , out_ack = %b , out_ready = %b, out_data = %h , state = %b",$realtime, in_a, in_b, ready , ack , out_ready , out_data , uut.r_state);

	in_a = 64'h40A9EB853EDCAC08;
	in_b = 64'h3D8CB29639A2877F;
	ready = 1;
	#2000
	ack = 1;
	#(4*half_cc);
	
end
endmodule
