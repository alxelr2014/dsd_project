`timescale 1ns/1ns
`include "memory.v"

module memory_tb();
parameter half_cc = 1;
parameter size = 1024;
parameter blocks = 4;
parameter log_size = 10;
parameter cell_width = 32;
parameter width = cell_width * blocks;
reg [log_size - 1: 0] address;
reg [width - 1: 0] in_data;
reg read_en, write_en;
reg reset, clk;
reg [cell_width - 1:0 ] in_status;
reg in_write_status_en;
wire [cell_width - 1: 0] out_status;
wire [cell_width - 1: 0 ] out_config;
wire [width - 1: 0] out_data;
memory #(.size(size) , .blocks(blocks) , .log_size(log_size) , .cell_width(cell_width)) uut (.in_address(address) , .in_data(in_data), 
.in_read_en(read_en) , .in_write_en(write_en),.in_clk(clk) , .in_reset(reset), .out_data(out_data) , .in_status (in_status) ,.in_write_status_en (write_status_en) , .out_status (out_status) , .out_config (out_config));

initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
end

integer  i,j;
integer file;
reg [cell_width - 1:0] my_reg;


initial begin
	reset = 1'b1;
	#(half_cc) reset = 1'b0;
	#(half_cc) reset = 1'b1;
	$monitor("@ time = %d, address = %h , in_data = %h , read_en = %b , write_en = %b , out_data = %h , out_status = %h , out_config = %h",$realtime, address, in_data, read_en ,write_en, out_data , out_status, out_config);
	file = $fopen("C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/memory_tb_init.txt", "r");
  	for(i = 0; i < 10; i = i + 1) begin
	for (j = 0 ; j < blocks; j = j + 1) begin
  	$fscanf(file, "%x\n", my_reg);
  	in_data[  (j * cell_width) +: cell_width ] <= my_reg;
	end
	address <= i * blocks;
	write_en <= 1'b1;
	read_en <= 1'b0;
	#(2*half_cc) ;
 	end  
	$fclose(file); 
	in_data <= 0;
	for (i = 0 ; i < 10 ; i = i + 1) begin
	address <= i * blocks;
	write_en <= 1'b0;
	read_en <= 1'b1;
	#(2*half_cc);
end
end
endmodule
