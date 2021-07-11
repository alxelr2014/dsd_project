module index_to_address #(parameter index_width , parameter k , parameter Log_Memory_Size = 10, parameter output_start)(
    input[31:0] i_Config,
    input[index_width - 1 : 0] i_Row_Index,
    input[index_width - 1: 0] i_Column_Index,
    input[2:0] i_Type,
    output reg [Log_Memory_Size -1 : 0] o_Address);
    
wire [index_width - 1:0] mu = i_Config[23:16];
wire [index_width - 1:0] gamma = i_Config[15:8];
wire [index_width - 1:0] lambda = i_Config[7:0];
always @(*) begin
	case (i_Type) 
	3'b001:  o_Address = 2 + ((i_Row_Index * mu) + i_Column_Index) * k* k;
	3'b010:  o_Address = 2 + ((lambda * mu) + (i_Row_Index * gamma) + i_Column_Index ) * k* k;
	3'b100:  o_Address = output_start + ((i_Row_Index * gamma) + i_Column_Index) * k* k;
	default: o_Address = 0;
	endcase
end
endmodule