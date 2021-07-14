
module column_multiplier #(parameter size  , parameter cell_width, parameter width = cell_width * size) (
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

always @(negedge in_reset) begin
out_c <= 0;
r_state = s_IDLE;
r_counter <= 0;
r_mult_in_a <= 0;
r_mult_in_b <= 0;
r_mult_reset <= 1;
r_mult_a_stb <= 0;
r_mult_b_stb <= 0;
r_mult_z_ack <= 0;
out_ready <= 0;
end

always @(posedge in_clk) begin
	case (r_state) 
	s_IDLE: begin
	out_c <= 0;
	r_state = s_IDLE;
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
			r_state = s_DONE;
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
			r_state = s_MULT;
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
			r_state = s_WORK;
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
			r_state = s_MULT;
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
			r_state = s_IDLE;
		end
	endcase
end
endmodule
