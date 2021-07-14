
module column_processor #(parameter size = 4, parameter cell_width = 32 ,parameter width = cell_width * size )
       (input in_ready ,
        input [width-1:0] in_row_a,
        input [width - 1: 0] in_col_b,
	input out_ack,
        input in_clk,
        input in_reset,
        output reg [width - 1: 0] out_cell_c,
        output reg out_ready );

        localparam s_IDLE = 3'b000 , s_WORK = 3'b001 , s_MULT = 3'b010, s_ADD = 3'b011 , s_DONE = 3'b100;


        
        reg [2:0] r_states;

        reg [width - 1: 0] r_adder_in;
        reg r_adder_in_ready, r_adder_reset, r_adder_ack;
        wire n_adder_out_ready;
        wire [cell_width - 1: 0] n_adder_out_z;

	column_adder  #(.size(size)  , .cell_width (cell_width), .width(width)) col_adder_unit (
	.in_col (r_adder_in),
	.in_clk (in_clk),
	.in_reset (r_adder_reset),
	.in_ready (r_adder_in_ready),
	.out_ack (r_adder_ack),
	.out_ready (n_adder_out_ready),
	.out_cell (n_adder_out_z) );


        reg [width - 1: 0] r_mult_in_a;
        reg [width - 1: 0 ] r_mult_in_b;
        reg r_mult_in_ready, r_mult_ack , r_mult_reset;
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
/*
        always @(negedge in_reset) begin
        out_cell_c <= 0;
        out_ready <= 0;

        r_adder_in <= 0;
        r_adder_in_ready <= 0;
 	r_adder_reset <= 0;
 	r_adder_ack <= 0;

	r_mult_in_a <= 0;
        r_mult_in_b <= 0;
        r_mult_in_ready <=0;
	r_mult_ack <=0 ;
	r_mult_reset<= 0;
	
	r_states <= s_IDLE;
        end
	*/
	
	always @(posedge in_clk, negedge in_reset) begin 
	if (~in_reset)begin
	        out_cell_c <= 0;
        out_ready <= 0;

        r_adder_in <= 0;
        r_adder_in_ready <= 0;
 	r_adder_reset <= 0;
 	r_adder_ack <= 0;

	r_mult_in_a <= 0;
        r_mult_in_b <= 0;
        r_mult_in_ready <=0;
	r_mult_ack <=0 ;
	r_mult_reset<= 0;
	
	r_states <= s_IDLE;
	end
	else begin

	case (r_states)
	s_IDLE: begin 
	        out_cell_c <= 0;
        	out_ready <= 0;

        	r_adder_in <= 0;
        	r_adder_in_ready <= 0;
 		r_adder_reset <= 0;
 		r_adder_ack <= 0;

		r_mult_in_a <= 0;
        	r_mult_in_b <= 0;
        	r_mult_in_ready <=0;
		r_mult_ack <=0 ;
		r_mult_reset<= 0;
		r_states <= s_IDLE;
		if (in_ready)
			r_states <= s_WORK;
		end
	s_WORK: begin
		out_cell_c <= 0;
        	out_ready <= 0;

        	r_adder_in <= 0;
        	r_adder_in_ready <= 0;
 		r_adder_reset <= 1;
 		r_adder_ack <= 0;

		r_mult_in_a <= in_row_a;
		r_mult_in_b <= in_col_b;
        	r_mult_in_ready <=1;
		r_mult_ack <=0 ;
		r_mult_reset<= 1;
		r_states <= s_MULT;
		end
	s_MULT: begin
		out_cell_c <= 0;
        	out_ready <= 0;

		r_mult_in_a <= 0;
		r_mult_in_b <= 0;
        				
		if (n_mult_out_ready) begin
			r_mult_in_ready <= 0;
			r_mult_ack <=1 ;
			r_mult_reset<= 1;
			r_adder_in <= n_mult_out_z;
        		r_adder_in_ready <= 1;
 			r_adder_reset <= 1;
 			r_adder_ack <= 0;
			r_states <= s_ADD;
		end
		else begin
			r_mult_in_ready <= 0;
			r_mult_ack <=0 ;
			r_mult_reset<= 1;
			r_adder_in <= 0;
        		r_adder_in_ready <= 0;
 			r_adder_reset <= 1;
 			r_adder_ack <= 0;
			r_states <= s_MULT;
		end
		end
	s_ADD: begin

        	r_adder_in <= 0;
        	r_adder_in_ready <= 0;
 		r_adder_reset <= 1;
 		

		r_mult_in_a <= 0;
		r_mult_in_b <= 0;
        	r_mult_in_ready <=0;
		r_mult_ack <=0 ;
		r_mult_reset<= 1;

		if (n_adder_out_ready) begin
			out_cell_c[cell_width - 1:0] <= n_adder_out_z;
			out_ready <= 1;	
 			r_adder_ack <= 1;
			r_states <= s_DONE;
		end
		else begin
			out_cell_c <= 0;
        		out_ready <= 0;
			r_adder_ack <= 1;
			r_states <= s_ADD;
		end
		
		end
	s_DONE: begin
		r_adder_ack <= 0;
		out_cell_c <= out_cell_c;
		out_ready <= 1;
		if (out_ack)
			r_states <= s_IDLE;
		end
	endcase
	end
	end
endmodule
