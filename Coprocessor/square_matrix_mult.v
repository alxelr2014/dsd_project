
module square_matrix_mult #(parameter size , parameter cell_width , parameter address_width ,parameter width = cell_width * size )
       (input in_ready ,
        input [width-1:0] in_row_a,
        input [width - 1: 0] in_col_b,
	input in_a_ready,
	input in_b_ready,
	input out_ack,
        input in_clk,
        input in_reset,
	output reg [address_width - 1: 0] out_reg_address,
	output reg [1:0] out_type,
	output reg [1:0] out_matrix,
	output reg out_read_en,
	output reg out_wirte_en,
        output reg [width - 1: 0] out_cell_c,
        output reg out_ready );

        localparam s_IDLE = 3'b000 , s_TAKEA = 3'b001 , s_TAKEB = 3'b010 , s_MULT = 3'b011, s_ADD = 3'b100 , s_DONE = 3'b101;


        reg [cell_width - 1:0] r_counter_level1;
        reg [cell_width - 1:0] r_counter_level2;
        
        reg [2:0] r_states;

        reg [width - 1: 0] r_adder_in;
        reg r_adder_in_ready, r_adder_reset, r_adder_ack;
        wire n_adder_out_ready;
        wire [width - 1: 0] n_adder_out_z;

	column_adder  #(.size(size)  , .cell_width (cell_width), .width(width)) col_adder_unit (
	.in_col (r_adder_in),
	.in_clk (in_clk),
	.in_reset (r_adder_in),
	.in_ready (r_adder_in_ready),
	.out_ack (r_adder_ack),
	.out_ready (n_adder_out_ready),
	.out_cell (n_adder_out_z) );


        reg [width - 1: 0] r_mult_in_a;
        reg [width - 1: 0 ] r_mult_in_b;
        reg r_mult_ready, r_mult_ack , r_mult_reset;
        wire n_mult_out_ready;
        wire [width - 1: 0] n_mult_out_z;

	column_multiplier #(.size(size)  , .cell_width (cell_width), .width(width)) col_mult_unit(
	.in_a(r_mult_in_a),
	.in_b(r_mult_in_b),
	.in_clk (in_clk),
	.in_reset (r_mult_reset),
	.in_ready(r_mult_in_ready),
	.out_ack (r_mult_ack),
	.out_ready (n_mult_out_ready),
	.out_c (n_mult_out_z) );

        always @(negedge in_reset) begin
	out_reg_address <= 0;
	out_type <= 0;
	out_matrix <= 0;
	out_read_en <= 0;
	out_wirte_en <= 0;
        out_cell_c <= 0;
        out_ready <= 0;

	r_counter_level1 <= 0;
        r_counter_level2 <= 0;
   
        r_adder_in <= 0;
        r_adder_in_ready <= 0;
 	r_adder_reset <= 1;
 	r_adder_ack <= 0;

	r_mult_in_a <= 0;
        r_mult_in_b <= 0;
        r_mult_ready <=0;
	r_mult_ack <=0 ;
	r_mult_reset<= 1;
	
	r_states <= s_IDLE;
        end
	
	always @(posedge in_clk) begin 
	out_reg_address <= 0;
	out_type <= 0;
	out_matrix <= 0;
	out_read_en <= 0;
	out_wirte_en <= 0;
        out_cell_c <= 0;
        out_ready <= 0;

	r_counter_level1 <= 0;
        r_counter_level2 <= 0;
   
        r_adder_in <= 0;
        r_adder_in_ready <= 0;
 	r_adder_reset <= 1;
 	r_adder_ack <= 0;

	r_mult_in_a <= 0;
        r_mult_in_b <= 0;
        r_mult_ready <=0;
	r_mult_ack <=0 ;
	r_mult_reset<= 1;
		
	r_states <= s_IDLE;

	case (r_states)
	s_IDLE: begin 
		r_adder_reset <=0;
		r_mult_reset <= 0;
		if (in_ready)
			r_states <= s_TAKEA;
		end
	s_TAKEA: begin
		if (r_counter_level1 < size) begin
		if (!in_a_ready) begin
			out_reg_address <= r_counter_level1 * size;
			out_type <= 2'b01; //row
			out_matrix <= 2'b00; //matrix A
			out_read_en <= 1;
			out_wirte_en <= 0;
			r_counter_level1 <= r_counter_level1;
			r_states <= s_TAKEA;
		end
		else begin
			r_mult_in_a <= in_row_a;
			r_counter_level1 <= r_counter_level1;
			r_states <= s_TAKEB;
		end
		end
		else begin //when it is done
			r_counter_level1 <= 0;
			out_ready <= 1;
			r_states <= s_DONE;
		end 
		end
	s_TAKEB: begin
		if (r_counter_level2 < size) begin
		if (!in_b_ready) begin
			out_reg_address <= r_counter_level2;
			out_type <= 2'b10; //col
			out_matrix <= 2'b01; //matrix B
			out_read_en <= 1;
			out_wirte_en <= 0;
			r_mult_in_a <= r_mult_in_a;
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			r_states <= s_TAKEB;
		end
		else begin
			r_mult_in_a <= r_mult_in_a;
			r_mult_in_b <= in_col_b;
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			r_mult_ready <=1;
			r_mult_ack <=0 ;
			r_mult_reset<= 1;
			r_states <= s_MULT;
		end
		end
		else begin //when it is done with a row
			r_counter_level2 <= 0;
			r_mult_in_a <= 0;
			r_counter_level1 <= r_counter_level1 + 1;
			r_states = s_TAKEA;
		end 
		end
	s_MULT: begin
		if (n_mult_out_ready) begin
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			r_mult_in_a <= r_mult_in_a;
			r_mult_ready <= 0;
			r_mult_ack <=1 ;
			r_mult_reset<= 0;
			r_adder_in <= n_mult_out_z;
        		r_adder_in_ready <= 1;
 			r_adder_reset <= 1;
 			r_adder_ack <= 0;
			r_states <= s_ADD;
		end
		else begin
			r_mult_in_a <= r_mult_in_a;
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			r_states <= s_MULT;
		end
		
		end
	s_ADD: begin
		if (n_adder_out_ready) begin
			out_reg_address <= r_counter_level1 * size + r_counter_level2;
			out_type <= 2'b00; //cell
			out_matrix <= 2'b10; //matrix C
			out_read_en <= 0;
			out_wirte_en <= 1;
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2 + 1;
			r_mult_in_a <= r_mult_in_a;
			out_cell_c <= n_adder_out_z;
        		r_adder_in_ready <= 0;
 			r_adder_reset <= 0;
 			r_adder_ack <= 1;
			r_states <= s_TAKEB;
		end
		else begin
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			r_mult_in_a <= r_mult_in_a;
			r_states <= s_ADD;
		end
		
		end
	s_DONE: begin
		out_ready <= 1;
		if (out_ack)
			r_states <= s_IDLE;
		end
	endcase
	end
endmodule
