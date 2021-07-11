`timescale 1ns/1ns
module square_matrix_mult_tb();
parameter size = 6;
parameter cell_width = 32;
parameter width = cell_width *size;
parameter address_width = $clog2(size *size);
parameter half_cc = 1;

reg clk, reset;
reg in_ready, out_ack;

wire proc_ready; //processor results is ready
wire [width - 1: 0 ] proc_in_bus;
wire [width - 1: 0] proc_out_bus;
wire [address_width - 1 : 0] proc_address;
wire [1:0] proc_type;
wire [1:0] proc_matrix;
wire proc_read_en , proc_write_en , out_ready;

reg [address_width - 1: 0] reg_address;
reg [width - 1: 0 ] reg_in_data;
reg [1:0] reg_in_type;
reg [1:0] reg_select_matrix;
reg reg_read_en, reg_write_en;
wire [width - 1: 0] reg_out_data;

square_matrix_mult #( .size(size) , .cell_width(cell_width) , .address_width(address_width) ) uut
       (.in_ready (in_ready) ,
        .in_row_a (proc_in_bus), 
        .in_col_b (proc_in_bus), //need to remove col_b
	.in_a_ready(proc_ready),
	.in_b_ready (proc_ready),	//need to remove b_ready
	.out_ack(out_ack),
        .in_clk (clk),
        .in_reset (reset),
	.out_reg_address (proc_address),
	.out_type (proc_type),
	.out_matrix (proc_matrix),
	.out_read_en (proc_read_en),
	.out_wirte_en (proc_write_en),
        .out_cell_c (proc_out_bus),
        .out_ready (out_ready) );

register_file #(.size(size), .address_width(address_width), .cell_width(cell_width)) r_file (.in_address(reg_address) , .in_data(reg_in_data), .in_type(reg_in_type), 
.in_select_matrix(reg_select_matrix), // A = 00 , B = 01 , C = 10
.in_clk (clk), .in_reset (reset), .in_read_en (reg_read_en), .in_write_en(reg_write_en) ,.out_data (reg_out_data));

initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
end

integer  i,j, k;
integer file;
reg [cell_width - 1:0] my_reg;

assign proc_in_bus = (proc_read_en) ? reg_out_data : 0;
initial begin
	reset = 1'b1;
	#(half_cc) reset = 1'b0;
	#(half_cc) reset = 1'b1; 
	$monitor("@ time = %d, address = %d , type = %d , select_matrix = %d , in_data = %h , read_en = %b , write_en = %b , out_data = %h",$realtime, reg_address, reg_in_type, reg_select_matrix,
			 reg_in_data, reg_read_en ,reg_write_en, reg_out_data);
	$monitor("@ time = %d, proc_bus = %h , proc_ready = %b , proc_address = %d , proc_type = %h , proc_matrix = %b , proc_read_en = %b , proc_write_en = %b , proc_out_bus = %h , out_ready = %b , state = %b",
		$realtime, proc_in_bus, proc_ready, proc_address,proc_type,proc_matrix,proc_read_en,proc_write_en, proc_out_bus, out_ready , uut.r_states);

	file = $fopen("C:/Users/emadz/Desktop/School/Books/Semester IV/Digital System Design/Project/Coprocessor/register_tb_init.txt", "r");
	for (k = 0 ; k < 3 ; k = k + 1) begin
  	for(i = 0; i < size; i = i + 1) begin
	for (j = 0 ; j < size; j = j + 1) begin
  	$fscanf(file, "%x\n", my_reg);
  	reg_in_data[ (j * cell_width) +: cell_width ] <= my_reg;
	end
	reg_address <= i * size;
	reg_in_type <= 2'b01;
	reg_select_matrix <= k;
	reg_write_en <= 1'b1;
	reg_read_en <= 1'b0;
	#(2*half_cc) ;
 	end  
	end
	#(10*half_cc);
	$fclose(file);
	in_ready = 1; 
	while (!out_ready) begin	
	if (proc_read_en) begin
		reg_address <= proc_address;
		reg_in_type <= proc_type;
		reg_select_matrix <= proc_matrix;
		reg_read_en <= 1'b1;
	end
	if (proc_write_en) begin
		reg_address <= proc_address;
		reg_in_data <= proc_out_bus;
		reg_in_type <= proc_type;
		reg_select_matrix <= proc_matrix;
	end
	#(2*half_cc);
	end
end


endmodule

