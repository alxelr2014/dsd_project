
module square_matrix_mult #(parameter size , parameter cell_width , parameter address_width ,parameter width = cell_width * size )
       (input in_ready ,
        input [width-1:0] in_data,
	input in_data_ready,
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

        localparam s_IDLE = 3'b000 , s_TAKEA = 3'b001 , s_TAKEB = 3'b010 , s_OP = 3'b011,s_DONE = 3'b100;


        reg [cell_width - 1:0] r_counter_level1;
        reg [cell_width - 1:0] r_counter_level2;
        
        reg [2:0] r_states;

        reg [width - 1: 0] r_proc_in_a;
	reg [width - 1: 0] r_proc_in_b;
        reg r_proc_in_ready, r_proc_reset, r_proc_ack;
        wire n_proc_out_ready;
        wire [width - 1: 0] n_proc_out_z;


column_processor #(.size(size)  , .cell_width (cell_width), .width(width)) col_proc
       (.in_ready (r_proc_in_ready) ,
        .in_row_a (r_proc_in_a),
        .in_col_b (r_proc_in_b),
	.out_ack (r_proc_ack),
        .in_clk (in_clk),
        .in_reset (r_proc_reset),
	.out_cell_c (n_proc_out_z),
        .out_ready (n_proc_out_ready) );

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
   
	r_proc_in_a <= 0;
	r_proc_in_b <= 0;
        r_proc_in_ready <= 0;
	r_proc_reset <= 0;
	r_proc_ack <= 0;
	r_states <= s_IDLE;
        end
	
	always @(posedge in_clk) begin 
	case (r_states)
	s_IDLE: begin 
		out_reg_address <= 0;
		out_type <= 0;
		out_matrix <= 0;
		out_read_en <= 0;
		out_wirte_en <= 0;
        	out_cell_c <= 0;
        	out_ready <= 0;

		r_counter_level1 <= 0;
        	r_counter_level2 <= 0;
   
		r_proc_in_a <= 0;
		r_proc_in_b <= 0;
        	r_proc_in_ready <= 0;
		r_proc_reset <= 1;
		r_proc_ack <= 0;
		r_states <= s_IDLE;
		if (in_ready)
			r_states <= s_TAKEA;
		end
	s_TAKEA: begin

        	out_cell_c <= 0;
        	out_ready <= 0;

        	r_counter_level2 <= 0;

		r_proc_in_b <= 0;
        	r_proc_in_ready <= 0;
		r_proc_reset <= 1;
		r_proc_ack <= 0;

		if (r_counter_level1 < size) begin
		if (!in_data_ready) begin
			out_reg_address <= r_counter_level1 * size;
			out_type <= 2'b01; //row
			out_matrix <= 2'b00; //matrix A
			out_read_en <= 1;
			out_wirte_en <= 0;
			r_proc_in_a <= 0;
			r_counter_level1 <= r_counter_level1;
			r_states <= s_TAKEA;
		end
		else begin
			out_reg_address <= 0;
			out_type <= 0;
			out_matrix <= 0;
			out_read_en <= 0;
			out_wirte_en <= 0;
			r_proc_in_a <= in_data;
			r_counter_level1 <= r_counter_level1;
			r_states <= s_TAKEB;
		end
		end
		else begin //when it is done
			out_reg_address <= 0;
			out_type <= 0;
			out_matrix <= 0;
			out_read_en <= 0;
			out_wirte_en <= 0;
			r_proc_in_a <= 0;
			r_counter_level1 <= 0;
			out_ready <= 1;
			r_states <= s_DONE;
		end 
		end
	s_TAKEB: begin
        	out_cell_c <= 0;
        	out_ready <= 0;
		
		r_proc_reset <= 1;
		r_proc_ack <= 0;
		if (r_counter_level2 < size) begin
		if (!in_data_ready) begin
			out_reg_address <= r_counter_level2;
			out_type <= 2'b10; //col
			out_matrix <= 2'b01; //matrix B
			out_read_en <= 1;
			out_wirte_en <= 0;
		
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;

			r_proc_in_a <= r_proc_in_a;
			r_proc_in_b <= 0;
        		r_proc_in_ready <= 0;
			r_states <= s_TAKEB;
		end
		else begin
			out_reg_address <= 0;
			out_type <= 0;
			out_matrix <= 0;
			out_read_en <= 0;
			out_wirte_en <= 0;

			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			
			r_proc_in_a <= r_proc_in_a;
			r_proc_in_b <= in_data;
        		r_proc_in_ready <= 1;
			r_states <= s_OP;
		end
		end
		else begin //when it is done with a row
			out_reg_address <= 0;
			out_type <= 0;
			out_matrix <= 0;
			out_read_en <= 0;
			out_wirte_en <= 0;

			r_counter_level1 <= r_counter_level1+ 1;
			r_counter_level2 <= 0;
			
			r_proc_in_a <= 0;
			r_proc_in_b <= 0;
        		r_proc_in_ready <= 0;

			r_states = s_TAKEA;
		end 
		end
	s_OP: begin

        	out_ready <= 0;

		r_proc_reset <= 1;
		if (n_proc_out_ready) begin
			
			out_reg_address <= r_counter_level1 * size + r_counter_level2;
			out_type <= 2'b00; //cell
			out_matrix <= 2'b10; //matrix C
			out_read_en <= 0;
			out_wirte_en <= 1'b1;
        		out_cell_c <= n_proc_out_z;
        		
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2 + 1;
			r_proc_in_a <= r_proc_in_a;
			r_proc_in_b <= 0;
        		r_proc_in_ready <= 0;
			r_proc_ack <= 1;
			r_states <= s_TAKEB;
		end
		else begin
			out_reg_address <=0;
			out_type <= 0; 
			out_matrix <= 0; 
			out_read_en <= 0;
			out_wirte_en <= 0;
        		out_cell_c <= 0;
        		
			r_counter_level1 <= r_counter_level1;
			r_counter_level2 <= r_counter_level2;
			r_proc_in_a <= r_proc_in_a;
			r_proc_in_b <= r_proc_in_b;
        		r_proc_in_ready <= 0;
			r_proc_ack <= 0;
			r_states <= s_OP;
		end
		
		end
	s_DONE: begin
		out_reg_address <= 0;
		out_type <= 0;
		out_matrix <= 0;
		out_read_en <= 0;
		out_wirte_en <= 0;
        	out_cell_c <= 0;
        	out_ready <= 1;

		r_counter_level1 <= 0;
        	r_counter_level2 <= 0;
   
		r_proc_in_a <= 0;
		r_proc_in_b <= 0;
        	r_proc_in_ready <= 0;
		r_proc_reset <= 0;
		r_proc_ack <= 0;

		if (out_ack)
			r_states <= s_IDLE;
		end
	endcase
	end
endmodule
