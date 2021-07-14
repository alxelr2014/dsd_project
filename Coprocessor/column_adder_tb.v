`timescale 1ns/1ns
`include "column_adder.v"

module column_adder_tb();

parameter size = 4;
parameter cell_width = 32;
parameter width = cell_width *size;

parameter half_cc = 1;
reg clk, reset , ready , ack;
reg [width - 1: 0 ] in_a;

wire [cell_width - 1:0] out_data;
wire out_ready;

column_adder #(.size(size)  , .cell_width(cell_width)) uut (
	.in_col (in_a),
	.in_clk (clk),
	.in_reset (reset),
	.in_ready (ready),
	.out_ack (ack),
	.out_ready (out_ready),
	.out_cell (out_data));

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
	$monitor("@ time = %d, in_col = %h , in_ready = %b , out_ack = %b , out_ready = %b, out_data = %h , state = %b",$realtime, in_a, ready , ack , out_ready , out_data , uut.r_state);

	in_a = 128'h3D8CB29639A2877F40A9EB853EDCAC08;

	ready = 1;
	#2000
	ack = 1;
	ready =0 ;
	#(4*half_cc);
	in_a = 128'h3FAE147B440000003A6BEDFABFF33333;
	ready = 1;
end
endmodule
