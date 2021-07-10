module index_to_address #(parameter Log_Memory_Size = 10)(
    input[31:0] i_Config,
    input[] i_Row_Index,
    input[] i_Column_Index,
    input[2:0] i_Type,
    output[Log_Memory_Size-1:0] o_Address
);
    
endmodule