
module processor #(parameter rowsA , parameter colsA, parameter rowsB , parameter colsB, parameter num_bits)
	(input [0:num_bits - 1] matrixA [0: rowsA - 1] [0 : colsA - 1], input [0: num_bits - 1] matrixB [0:rowsB - 1][0: colsB - 1], input clk, input reset
	, output [0:num_bits_1] matrixC [0:rowsA - 1][0 :colsB - 1], output  data_error, output data_valid)


endmodule