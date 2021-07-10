
module register_file #(parameter size , parameter address_width ,parameter cell_width = 32, parameter width = cell_width * size) 
(input [address_width - 1 : 0] in_address , //address from 0 to k^2 - 1
 input [width - 1: 0 ] in_data, // k blocks of data
 input [1:0] in_type, // cell = 00 , row = 01, col = 10
 input [1:0] in_select_matrix, // A = 00 , B = 01 , C = 10
 input in_clk,
 input in_reset,
 input in_read_en,
 input in_write_en,
 output reg[width - 1: 0] out_data);

localparam size_square = size *size;
reg [cell_width - 1: 0 ] register_file [3*size_square - 1: 0];
integer idx;
wire correct_type;
assign correct_type = ~(in_select_matrix[0] & in_select_matrix[1]);

always @(negedge in_reset) begin
for (idx = 0 ; idx < 3*size_square ; idx = idx + 1)
	register_file[idx] <= 0;
end

always @(posedge in_clk) begin
	if (in_read_en && correct_type) begin
	case (in_type)
	2'b00: begin // cell 
		out_data[cell_width - 1: 0] <= register_file[in_address + in_select_matrix *size_square];
		for (idx = 1; idx < size ; idx = idx + 1)
			out_data[(idx)*cell_width +: cell_width] <= 0;
		end
	2'b01: begin //row 
		for (idx = 0 ; idx < size ; idx = idx + 1)
			out_data[(idx)*cell_width +: cell_width] <= register_file[in_address + (in_select_matrix * size_square) + idx];
		end
	2'b10: begin //column
		for (idx = 0 ; idx < size ; idx = idx + 1)
			out_data[(idx)*cell_width +: cell_width] <= register_file[in_address + (in_select_matrix * size_square) + idx * size];
		end
	default: 
		out_data <= 32'bz;
	endcase
	end
	else
		out_data <= 32'bz;
	if(in_write_en && correct_type) begin
	case (in_type)
	2'b00: begin // cell 
		register_file[in_address + (in_select_matrix *size_square)] <= in_data[cell_width - 1: 0 ];
		end
	2'b01: begin //row 
		for (idx = 0 ; idx < size ; idx = idx + 1)
			register_file[in_address + (in_select_matrix * size_square) + idx] <= in_data[(idx)*cell_width +: cell_width] ;
		end
	2'b10: begin //column
		for (idx = 0 ; idx < size ; idx = idx + 1)
			register_file[in_address + (in_select_matrix * size_square) + idx * size] <= in_data[(idx)*cell_width +: cell_width] ;
		end
	default: 
		out_data <= 32'bz;
	endcase
	end
end
endmodule

`timescale 1ns/1ns
module register_file_tb();
parameter size = 10;
parameter cell_width = 32;
parameter width = cell_width *size;
parameter address_width = $clog2(size *size);
parameter half_cc = 1;
reg clk, reset , read_en , write_en;
reg [address_width - 1 : 0] address;
reg [width - 1: 0 ] in_data;
reg [1:0] type;
reg [1:0] select_matrix;
wire [width - 1: 0] out_data;
register_file #(.size(size), .address_width(address_width), .cell_width(cell_width)) uut (.in_address(address) , .in_data(in_data), .in_type(type), .in_select_matrix(select_matrix), // A = 00 , B = 01 , C = 10
 .in_clk (clk), .in_reset (reset), .in_read_en (read_en), .in_write_en(write_en) ,.out_data (out_data));

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
	$monitor("@ time = %d, address = %h , type = %d , select_matrix = %d , in_data = %h , read_en = %b , write_en = %b , out_data = %h",$realtime, address, type, select_matrix,
				 in_data, read_en ,write_en, out_data);
	file = $fopen("C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/register_tb_init.txt", "r");
	for (k = 0 ; k < 3 ; k = k + 1) begin
  	for(i = 0; i < size; i = i + 1) begin
	for (j = 0 ; j < size; j = j + 1) begin
  	$fscanf(file, "%x\n", my_reg);
  	in_data[ (j * cell_width) +: cell_width ] <= my_reg;
	end
	address <= i * size;
	type <= 2'b01;
	select_matrix <= k;
	write_en <= 1'b1;
	read_en <= 1'b0;
	#(2*half_cc) ;
 	end  
	end
	$fclose(file); 
	in_data <= 0;
	

	address <= 3;
	type <= 2'b00;
	select_matrix <= 2'b00;
	write_en <= 1'b0;
	read_en <= 1'b1;
	#(2*half_cc);

	address <= 3 * size;
	type <= 2'b01;
	select_matrix <= 2'b01;
	write_en <= 1'b0;
	read_en <= 1'b1;
	#(2*half_cc);
	
	address <= 3;
	type <= 2'b10;
	select_matrix <= 2'b10;
	write_en <= 1'b0;
	read_en <= 1'b1;
	#(2*half_cc);


end

endmodule
