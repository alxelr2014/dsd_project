
module column_adder #(parameter size = 4 , parameter cell_width = 32, parameter width = cell_width * size) (
	input [width - 1 : 0] in_col,
	input in_clk,
	input in_reset,
	input in_ready,
	input out_ack,
	output reg out_ready,
	output reg [cell_width - 1:0] out_cell);

reg [width - 1: 0 ] r_matrix_a;


parameter s_IDLE = 2'b00, s_WORK = 2'b01, s_ADD = 2'b10 , s_DONE = 2'b11;
reg [1:0] r_state;
reg [size - 1:0 ] r_counter;

reg [cell_width - 1: 0] r_add_in_a;
reg [cell_width - 1: 0] r_add_in_b;
reg r_add_a_stb ,r_add_b_stb, r_add_z_ack, r_add_reset;

wire [cell_width - 1: 0] n_add_out_z;
wire n_add_z_stb ,n_add_a_ack, n_add_b_ack;

adder adder_unit(
        .input_a (r_add_in_a),
        .input_b (r_add_in_b),
        .input_a_stb (r_add_a_stb),
        .input_b_stb (r_add_b_stb),
        .output_z_ack (r_add_z_ack),
        .clk(in_clk),
        .rst (r_add_reset),
        .output_z(n_add_out_z),
        .output_z_stb(n_add_z_stb) ,
        .input_a_ack (n_add_a_ack),
        .input_b_ack (n_add_b_ack));
/*
always @(negedge in_reset) begin
out_cell <= 0;
r_state <= s_IDLE;
r_counter <= 0;
r_add_in_a <= 0;
r_add_in_b <= 0;
r_add_reset <= 1;
r_add_a_stb <= 0;
r_add_b_stb <= 0;
r_add_z_ack <= 0;
out_ready <= 0;
end
*/

always @(posedge in_clk, negedge in_reset) begin
	if (~in_reset)begin
	out_cell <= 0;
	r_state <= s_IDLE;
	r_counter <= 0;
	r_add_in_a <= 0;
	r_add_in_b <= 0;
	r_add_reset <= 1;
	r_add_a_stb <= 0;
	r_add_b_stb <= 0;
	r_add_z_ack <= 0;
	out_ready <= 0;
	end
	else begin
	
	case (r_state) 
	s_IDLE: begin
	out_cell <= 0;
	r_state <= s_IDLE;
	r_counter <= 0;
	r_add_in_a <= 0;
	r_add_in_b <= 0;
	r_add_reset <= 1;
	r_add_a_stb <= 0;
	r_add_b_stb <= 0;
	r_add_z_ack <= 0;
	out_ready <= 0 ;
	if (in_ready) begin
		r_state <= s_WORK;
		r_matrix_a <= in_col;
		end
	end
	s_WORK: begin
		if (r_counter == size) begin
			out_cell <= out_cell;
			r_add_in_a <= 0;
			r_add_in_b <= 0;
			r_add_reset <= 0;
			r_add_a_stb <= 0;
			r_add_b_stb <= 0;
			r_add_z_ack <= 0;
			out_ready <= 1 ;
			r_counter <= 0;
			r_state <= s_DONE;
			
		end
		else begin
			out_cell <= out_cell;
			r_add_in_a <= r_matrix_a [r_counter * cell_width +: cell_width];
			r_add_in_b <= out_cell;
			r_add_reset <= 0;
			r_add_a_stb <= 1;
			r_add_b_stb <= 1;
			r_add_z_ack <= 0;
			out_ready <= 0 ;
			r_counter <= r_counter;
			r_state <= s_ADD;
			
		end
	end
	s_ADD: begin 
		if (n_add_z_stb) begin
			out_cell  <= n_add_out_z;
			r_add_in_a <= 0;
			r_add_in_b <= 0;
			r_add_reset <= 0;
			r_add_a_stb <= 0;
			r_add_b_stb <= 0;
			r_add_z_ack <= 1;
			out_ready <= 0 ;
			r_counter <= r_counter + 1;
			r_state <= s_WORK;

		end
		else begin
			out_cell <= out_cell;
			r_add_in_a <= r_matrix_a [r_counter * cell_width +: cell_width];
			r_add_in_b <= out_cell;
			r_add_reset <= 0;
			r_add_a_stb <= 1;
			r_add_b_stb <= 1;
			r_add_z_ack <= 0;
			out_ready <= 0 ;
			r_counter <= r_counter;
			r_state <= s_ADD;
		
		end
	end
	s_DONE: begin

		out_cell <= out_cell;
		r_add_in_a <= 0;
		r_add_in_b <=0;
		r_add_reset <= 1;
		r_add_a_stb <= 0;
		r_add_b_stb <= 0;
		r_add_z_ack <= 0;
		out_ready <= 1;
		r_counter <= 0;
		r_state <= s_DONE;
		if (out_ack)
			r_state <= s_IDLE;
		end
	endcase
end
end
endmodule

`timescale 1ns/1ns
/*
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
*/