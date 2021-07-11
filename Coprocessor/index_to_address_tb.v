`timescale 1ns/1ns
`include "index_to_address.v"

module index_to_address_tb;
	reg	[31:0]  r_config;
	reg	[7:0]   row_index;
	reg	[7:0]	column_index;
	reg	[2:0] 	type;
	wire[9:0]	address;

	index_to_address idxToAddr (.i_Config(r_config), .i_Row_Index(row_index), .i_Column_Index(column_index), .i_Type(type), .o_Address(address));

	initial begin
		$monitor("i:%d,\tj:%d,\t type:%b ----> address: %b-%d", row_index, column_index, type, address, address);
	end

	initial begin
		//#proccessor = 4, theta = 16, mu = 4, gamma = 8, lambda = 8
		r_config <= 32'b00001000000001000000100000001000;
		
		row_index <= 0;
		column_index <= 5;
		type <= 3'b000;

		#2
		row_index <= 2;
		column_index <= 6;
		type <= 3'b010;

		#2
		row_index <= 3;
		column_index <= 7;
		type <= 3'b100;
	end
	
endmodule