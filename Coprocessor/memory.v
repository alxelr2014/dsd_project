
module memory #(parameter size = 1024, parameter blocks = 4 , parameter log_size = 10, parameter cell_width = 32 , parameter width = blocks * cell_width)
(input [log_size - 1: 0] in_address ,
 input [width - 1: 0] in_data,
 input [cell_width - 1 : 0] in_status,
 input in_write_status_en,
 input in_read_en ,
 input in_write_en, 
 input in_clk,
 input in_reset,
 output reg [width -1 :0] out_data,
 output [cell_width - 1 :0] out_status,
 output [cell_width - 1 :0] out_config
 );

integer idx;
reg [cell_width - 1:0] memory [size -1 : 0];

assign out_status = memory[1];
assign out_config = memory[0];
/*
always @(negedge in_reset) begin
for (idx = 0 ; idx < size ; idx = idx + 1) begin
	memory[idx] <= 32'b0;
end
end
*/
always @(posedge in_clk, negedge in_reset) begin
	if (~in_reset)begin
	for (idx = 0 ; idx < size ; idx = idx + 1) begin
	memory[idx] <= 32'b0;
	end
	end
	else begin

	if (in_read_en) begin
		for (idx = 0 ; idx < blocks ; idx = idx + 1)
			out_data[(idx * cell_width)  +: cell_width] <= memory [idx + in_address];
	end
	else 
		out_data <= 'bz;

	if (in_write_en) begin //creates latch
		for (idx = 0 ; idx < blocks ; idx = idx + 1)
			memory[idx + in_address]  <= in_data[(idx * cell_width)  +: cell_width];
	end
	if (in_write_status_en) memory[1] <= in_status;
end
end
endmodule
