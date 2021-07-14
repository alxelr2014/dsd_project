
module register_file #(parameter size = 4 , parameter address_width = 4 ,parameter cell_width = 32, parameter width = cell_width * size) 
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
/*
always @(negedge in_reset) begin
for (idx = 0 ; idx < 3*size_square ; idx = idx + 1)
	register_file[idx] <= 0;
end
*/
always @(posedge in_clk, negedge in_reset) begin
	if(~in_reset)begin
	for (idx = 0 ; idx < 3*size_square ; idx = idx + 1)
	register_file[idx] <= 0;
	end
	else begin

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
		out_data <= 'bz;
	endcase
	end
	else
	
		out_data <= 'bz;
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
		out_data <= 'bz;
	endcase
	end
end
end
endmodule
