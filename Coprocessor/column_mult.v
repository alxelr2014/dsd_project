
module column_multiplier #(parameter size = 4 , parameter cell_width = 32, parameter width = cell_width * size) (
	input [width - 1 : 0] in_a,
	input [width - 1: 0] in_b,
	input in_clk,
	input in_reset,
	input in_ready,
	input out_ack,
	output reg out_ready,
	output reg [width - 1: 0] out_c);
reg [width - 1: 0 ] r_matrix_a;
reg [width - 1: 0] r_matrix_b;

parameter s_IDLE = 2'b00, s_WORK = 2'b01, s_MULT = 2'b10 , s_DONE = 2'b11;
reg [1:0] r_state;
reg [size - 1:0 ] r_counter;

reg [cell_width - 1: 0] r_mult_in_a;
reg [cell_width - 1: 0] r_mult_in_b;
reg r_mult_a_stb ,r_mult_b_stb, r_mult_z_ack, r_mult_reset;

wire [cell_width - 1: 0] n_mult_out_z;
wire n_mult_z_stb ,n_mult_a_ack, n_mult_b_ack;

single_multiplier mutliplier(
        .input_a (r_mult_in_a),
        .input_b (r_mult_in_b),
        .input_a_stb (r_mult_a_stb),
        .input_b_stb (r_mult_b_stb),
        .output_z_ack (r_mult_z_ack),
        .clk(in_clk),
        .rst (r_mult_reset),
        .output_z(n_mult_out_z),
        .output_z_stb(n_mult_z_stb) ,
        .input_a_ack (n_mult_a_ack),
        .input_b_ack (n_mult_b_ack));
/*
always @(negedge in_reset) begin
out_c <= 0;
r_state <= s_IDLE;
r_counter <= 0;
r_mult_in_a <= 0;
r_mult_in_b <= 0;
r_mult_reset <= 1;
r_mult_a_stb <= 0;
r_mult_b_stb <= 0;
r_mult_z_ack <= 0;
out_ready <= 0;
end
*/
always @(posedge in_clk, negedge in_reset) begin
	if (~in_reset)begin
	out_c <= 0;
r_state <= s_IDLE;
r_counter <= 0;
r_mult_in_a <= 0;
r_mult_in_b <= 0;
r_mult_reset <= 1;
r_mult_a_stb <= 0;
r_mult_b_stb <= 0;
r_mult_z_ack <= 0;
out_ready <= 0;
	end

	case (r_state) 
	s_IDLE: begin
	out_c <= 0;
	r_state <= s_IDLE;
	r_counter <= 0;
	r_mult_in_a <= 0;
	r_mult_in_b <= 0;
	r_mult_reset <= 1;
	r_mult_a_stb <= 0;
	r_mult_b_stb <= 0;
	r_mult_z_ack <= 0;
	out_ready <= 0 ;
	if (in_ready) begin
		r_state <= s_WORK;
		r_matrix_a <= in_a;
		r_matrix_b <= in_b;
		end
	end
	s_WORK: begin
		if (r_counter == size) begin
			out_c <= out_c;
			r_mult_in_a <= 0;
			r_mult_in_b <= 0;
			r_mult_reset <= 0;
			r_mult_a_stb <= 0;
			r_mult_b_stb <= 0;
			r_mult_z_ack <= 0;
			r_counter <= 0;
			r_state <= s_DONE;
			out_ready <= 1 ;
		end
		else begin
			r_mult_in_a <= r_matrix_a [r_counter * cell_width +: cell_width];
			r_mult_in_b <= r_matrix_b[r_counter * cell_width +: cell_width];
			r_mult_reset <= 0;
			r_mult_a_stb <= 1;
			r_mult_b_stb <= 1;
			r_mult_z_ack <= 0;
			out_c <= out_c;
			r_counter <= r_counter;
			r_state <= s_MULT;
			out_ready <= 0 ;
		end
	end
	s_MULT: begin 
		if (n_mult_z_stb) begin
			out_c [r_counter *cell_width +: cell_width] <= n_mult_out_z;
			r_mult_in_a <= 0;
			r_mult_in_b <= 0;
			r_mult_reset <= 0;
			r_mult_a_stb <= 0;
			r_mult_b_stb <= 0;
			r_mult_z_ack <= 1;
			r_counter <= r_counter + 1;
			r_state <= s_WORK;
			out_ready <= 0 ;
		end
		else begin
			r_mult_in_a <= r_matrix_a [r_counter * cell_width +: cell_width];
			r_mult_in_b <= r_matrix_b[r_counter * cell_width +: cell_width];
			r_mult_reset <= 0;
			r_mult_a_stb <= 1;
			r_mult_b_stb <= 1;
			r_mult_z_ack <= 0;
			out_c <= out_c;
			r_counter <= r_counter;
			r_state <= s_MULT;
			out_ready <= 0 ;
		end
	end
	s_DONE: begin
		r_mult_in_a <= 0;
		r_mult_in_b <= 0;
		//r_mult_reset <= 1;
		r_mult_a_stb <= 0;
		r_mult_b_stb <= 0;
		r_mult_z_ack <= 0;
		r_counter <= 0;
		out_ready <= 1 ;
		out_c <= out_c;
		r_state <= s_DONE;
		if (out_ack)
			r_state <= s_IDLE;
		end
	endcase
end
endmodule

`timescale 1ns/1ns
/*
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
*/
