`timescale  1ns/1ns
module processor_tb();
parameter size = 4;
parameter cell_width = 32;
parameter index_width = 8;
parameter width = cell_width *size;
parameter register_address_width = $clog2(size *size);
parameter half_cc = 1;
parameter memory_size = 256;
parameter memory_size_log = 8;


reg clk , reset, grant;
reg [index_width - 1: 0] row_index ;
reg [index_width - 1: 0] col_index;
reg index_ready;
reg [index_width - 1: 0] in_mu;
wire index_ack , result_ready, request;

wire [width - 1: 0] memory_in_data;
wire [width - 1: 0] memory_out_data;
wire mem_write_en, mem_read_en;
wire[memory_size_log -1 : 0 ] memory_address;

processor #(.size(size) , .cell_width (cell_width), .register_address_width(register_address_width), .index_width(index_width) 
,.memory_size(memory_size) ,.memory_size_log(memory_size_log) , .width(width)) uut
( .in_clk(clk),
 .in_reset(reset),
.in_grant (grant),
 .in_row_index (row_index),
 .in_col_index (col_index),
 .in_index_ready (index_ready),
 .in_mu (in_mu),
 .in_mem_data (memory_out_data),
 .out_index_ack (index_ack),
 .out_result_ready(result_ready),
 .out_request(request),
 .out_mem_write_en (mem_write_en),
 .out_mem_read_en (mem_read_en),
 .out_mem_address (memory_address),
 .out_mem_data (memory_in_data));


reg [memory_size_log - 1: 0] address;
reg [width - 1: 0] in_data;
reg read_en, write_en;

wire [width - 1: 0] out_data;

memory #(.size(memory_size) , .blocks(size) , .log_size(memory_size_log) , .cell_width(cell_width) , .width(width)) memory (.in_address(address) , 
.in_data(in_data), .in_read_en(read_en) , .in_write_en(write_en),.in_clk(clk) , .in_reset(reset), .out_data(out_data));

initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
end

integer  i,j;
integer file;
reg [cell_width - 1:0] my_reg;
reg init_done;
reg [cell_width - 1: 0 ] r_config;
reg [index_width - 1: 0] gamma;
reg [index_width - 1: 0] mu;
reg [index_width - 1: 0] lambda;

initial begin
	reset = 1'b1;
	#(half_cc) reset = 1'b0;
	#(half_cc) reset = 1'b1;
    init_done = 1'b0;
	$monitor("@ time = %d, address = %h , in_data = %h , read_en = %b , write_en = %b , out_data = %h",$realtime, address, 
    in_data, read_en , write_en, out_data);
	file = $fopen("C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/memory_tb_init.txt", "r");
  	for(i = 0; i < 10; i = i + 1) begin
	for (j = 0 ; j < size; j = j + 1) begin
  	$fscanf(file, "%x\n", my_reg);
  	in_data[  (j * cell_width) +: cell_width ] <= my_reg;
	end
	address <= i * size;
	write_en <= 1'b1;
	read_en <= 1'b0;
	#(2*half_cc) ;
 	end  
	$fclose(file); 
	in_data <= 0;
	for (i = 0 ; i < 10 ; i = i + 1) begin
	address <= i * size;
	write_en <= 1'b0;
	read_en <= 1'b1;
	#(2*half_cc);
      
end
   /* init_done = 1'b1;
    address <= 0;
    read_en <= 1'b1;
    #(2*half_cc);
    r_config = out_data[cell_width -1 : 0];
    grant = 1'b1;
    mu = r_config [23:16];*/

end
endmodule