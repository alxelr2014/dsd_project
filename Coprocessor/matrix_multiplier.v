module matrix_multiplier #(parameter rowsA = 2,
	parameter colsA = 2,
	parameter rowsB = 2,
	parameter colsB = 2) (input_row, input_cell, input_row_ack, input_cell_ack, clk, rst, input_row_stb, input_cell_stb, output_row, output_row_stb, multiplication_done, multipliers_ready);

	input clk, rst, input_row_stb, input_cell_stb;
	input [31:0] input_cell;
	input [32*colsB - 1:0] input_row;
	output input_row_ack, input_cell_ack;
	output reg output_row_stb, multiplication_done, multipliers_ready;
	output reg [32*colsB - 1:0] output_row;

	wire [colsB-1:0] multiplier_out_stb;
	wire [colsB-1:0] multiplier_out_ack;
	wire [31:0] multiplier_out [colsB-1:0];
	wire [colsB-1:0] adder_out_stb;
	reg [colsB-1:0] adder_out_ack;
	wire [32*colsB - 1:0] adder_out;
	reg [colsB-1:0] pipeline;

	integer counter1=0, counter2=0;

	always @(posedge clk)
	begin
	  if (rst)
	  begin
	    counter1 <= 0;
	    counter2 <= 0;
	    output_row_stb <= 0;
	    multiplication_done <= 0;
	    output_row <= 0;
	    adder_out_ack <= 0;
	    multipliers_ready <= 0;
	    pipeline <= (2**colsB) - 1;
	  end else
	  begin
	    if (output_row_stb && counter1 == 0)
	    begin
	      if (counter2 == rowsA)
	      begin
	        multiplication_done <= 1;
	        counter2 <= 0;
	      end
	      output_row <= 0;
	      output_row_stb <= 0;
	    end else
	    begin
	      if (counter1 == rowsB && &adder_out_stb)
	      begin
	        output_row_stb <= 1;
	        counter1 <= 0;
	        counter2 <= counter2 + 1;
	        adder_out_ack <= ~adder_out_ack;
	      end else if (&adder_out_stb && (|adder_out_ack)==0)
	      begin
	        counter1 <= counter1 + 1;
	        output_row <= adder_out;
	        adder_out_ack <= ~adder_out_ack;
	      end
	    end
	    if (&adder_out_ack)
	    begin
	      adder_out_ack <= 0;
	    end
	    if ((&pipeline)==1)
	    begin
	      multipliers_ready <= 1;
	      pipeline <= 0;
	    end else
	    begin
	      multipliers_ready <= 0;
	      pipeline <= pipeline | multiplier_out_ack;
	    end
	  end
	end

	genvar i;
	generate
	  for(i = 0; i < colsB; i = i + 1)
	  begin: ALU
	    multiplier Multiplierr 
	    		(.input_a(input_cell), 
	    		.input_b(input_row[i*32 +: 32]), 
	    		.input_a_stb(input_cell_stb), 
	    		.input_b_stb(input_row_stb), .clk(clk), .rst(rst), 
	    		.output_z_ack(multiplier_out_ack[i]), 
	    		.output_z(multiplier_out[i]), 
	    		.output_z_stb(multiplier_out_stb[i]), 
	    		.input_a_ack(), 
	    		.input_b_ack());
	    adder Adderr (.input_a(multiplier_out[i]), 
	    .input_a_stb(multiplier_out_stb[i]), 
	    .input_a_ack(multiplier_out_ack[i]), 
	    .input_b(output_row[i*32 +: 32]), 
	    .input_b_stb(1'b1), 
	    .input_b_ack(), .clk(clk), .rst(rst), 
	    .output_z(adder_out[i*32 +: 32]), 
	    .output_z_stb(adder_out_stb[i]), 
	    .output_z_ack(adder_out_ack[i]));
	  end
	endgenerate

endmodule