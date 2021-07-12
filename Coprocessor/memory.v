
module memory #(parameter size, parameter blocks , parameter log_size , parameter cell_width = 32 , parameter width = blocks * cell_width)
(input [log_size - 1: 0] in_address ,
 input [width - 1: 0] in_data,
 input in_read_en ,
 input in_write_en, 
 input in_clk,
 input in_reset,
 output reg [width -1 :0] out_data );

integer idx;
reg [cell_width - 1:0] memory [size -1 : 0];

always @(negedge in_reset) begin
for (idx = 0 ; idx < size ; idx = idx + 1) begin
	memory[idx] <= 32'b0;
end
end

always @(posedge in_clk) begin
	if (in_read_en) begin
		for (idx = 0 ; idx < blocks ; idx = idx + 1)
			out_data[(idx * cell_width)  +: cell_width] <= memory [idx + in_address];
	end
	else 
		out_data <= 32'bz;

	if (in_write_en) begin //creates latch
		for (idx = 0 ; idx < blocks ; idx = idx + 1)
			memory[idx + in_address]  = in_data[(idx * cell_width)  +: cell_width];
	end
end
endmodule

`timescale 1ns/1ns
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
wire [width - 1: 0] out_data;
memory #(.size(size) , .blocks(blocks) , .log_size(log_size) , .cell_width(cell_width)) uut (.in_address(address) , .in_data(in_data), 
.in_read_en(read_en) , .in_write_en(write_en),.in_clk(clk) , .in_reset(reset), .out_data(out_data));

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
	$monitor("@ time = %d, address = %h , in_data = %h , read_en = %b , write_en = %b , out_data = %h",$realtime, address, in_data, read_en ,write_en, out_data);
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
