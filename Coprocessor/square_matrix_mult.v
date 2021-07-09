
module square_matrix_mult #(parameter size_square , parameter size , parameter width)(
input in_ready ,
input [width-1:0] in_matrix_a [size_square - 1: 0 ],
input [width - 1: 0] in_matrix_b [size_square - 1: 0 ],
input in_clk,
input in_reset,
output reg [width - 1: 0] out_matrix_c [size_square - 1: 0 ],
output reg out_ready);

localparam s_IDLE = 2'b00 , s_MULT = 2'b01, s_OUT = 2'b10;

reg [width - 1: 0] r_matrix_a [size_square - 1: 0 ];
reg [width - 1: 0] r_matrix_b [size_square - 1: 0 ];
//reg [width - 1: 0] r_matrix_c [size_square - 1: 0 ]:
reg [31:0] r_counter_level1;
reg [31:0] r_counter_level2;
reg [31:0] r_counter_level3;
reg [1:0] r_states;

reg [width - 1: 0] r_adder_in_a;
reg [width - 1: 0] r_adder_in_b;
reg r_adder_load. r_adder_reset, r_adder_res_ack;
wire n_adder_out_z_ready;
wire [width - 1: 0] n_adder_out_z;

reg [width - 1: 0] r_mult_in_a;
reg [width - 1: 0 ] r_mult_in_b;
reg r_mult_in_a_stb, r_mult_in_b_stb , r_mult_out_z_ack , r_mult_reset;
wire n_mult_in_a_ack , n_mult_in_b_ack , n_mult_out_z_stb;
wire [width - 1: 0] n_mult_out_z;

adder fp_adder(
	.clk(in_clk),
        .load(r_adder_load),
        .reset(r_adder_reset),
        .Number1(r_adder_in_a),
        .Number2(r_adder_in_b),
        .result_ack(r_adder_res_ack),      
        .Result(n_adder_out_z),
        .result_ready(n_adder_out_z_ready),
        );

multiplier fp_multiplier(
        .input_a(r_mult_in_a),
        .input_b(r_mult_in_b),
        .input_a_stb(r_mult_in_a_stb),
        .input_b_stb(r_mult_in_b_stb),
        .output_z_ack(r_mult_out_z_ack),
        .clk(in_clk),
        .rst(r_mult_reset),
        .output_z(n_mult_out_z),
        .output_z_stb(n_mult_out_z_stb),
	.input_a_ack(n_mult_in_a_ack),
	.input_b_ack(n_mult_in_b_ack));

always @(negedge in_reset) begin
for (idx = 0 ; idx < size_square ; idx = idx + 1) begin
r_matrix_a <= 0;
r_matrix_b <= 0;
r_matrix_c <= 0;
end

r_counter_level1 <= 0;
r_counter_level2 <= 0;
r_counter_level3 <= 0;
r_states <= s_IDLE;

r_adder_load <= 0;
r_adder_reset <= 0;
r_adder_in_a <= 0;
r_adder_in_b <= 0;
r_adder_res_ack <= 0;

r_mult_in_a <= 0;
r_mult_in_b <= 0;
r_mult_in_a_stb <= 0;
r_mult_in_b_stb <=0 ;
r_mult_out_z_ack <= 0;
r_mult_reset <= 0;
end

