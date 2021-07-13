module moduleName #(parameter NUMBER_OF_PROCESSORS = 4, parameter MEMORY_SIZE = 1024, parameter BLOCK_SIZE = 3,)(
    input clk,
    input reset
);

parameter LOG_MEMORY_SIZE = $clog2(MEMORY_SIZE);
parameter MEMORY_WIDTH = BLOCK_SIZE * 32;
parameter INDEX_WIDTH = 32/4;

wire[LOG_MEMORY_SIZE-1 : 0] Memory_Address;
wire[MEMORY_WIDTH-1 : 0] Memory_Write_Data;
wire[MEMORY_WIDTH-1 : 0] Memory_Read_Data;
wire Memory_Read_Enable;
wire Memory_Write_Enable;
wire [NUMBER_OF_PROCESSORS : 0] Requests;
wire [NUMBER_OF_PROCESSORS : 0] Grants;
wire [NUMBER_OF_PROCESSORS - 1 : 0]
wire [INDEX_WIDTH-1 : 0] Row_Index;
wire [INDEX_WIDTH-1 : 0] Col_Index;

//BLOCK_SIZE?
genvar i;
generate
    for (i = 0; i < NUMBER_OF_PROCESSORS ; i = i + 1) begin

        processor #(.size(BLOCK_SIZE) , .cell_width(32) , .index_width(INDEX_WIDTH) , .memory_size(MEMORY_SIZE) , .memory_size_log(LOG_MEMORY_SIZE)) 
        PU
    (input .in_clk(clk)
    input .in_reset(reset)
    input .in_grant(Grants[i+1])
    input [index_width - 1: 0] in_row_index,
    input [index_width - 1: 0] in_col_index,
    input in_index_ready,
    input [index_width - 1 : 0] in_mu,
    input [width - 1: 0] in_mem_data,
    input [cell_width - 1:0] in_Config,
    output out_index_ack,
    output out_result_ready,
    output out_request,
    output out_mem_write_en,
    output out_mem_read_en,
    output [memory_size_log -1 : 0] out_mem_address,
    output [width - 1: 0] out_mem_data);
    
    end
endgenerate

memory #(.size(MEMORY_SIZE), .blocks(BLOCK_SIZE), .log_size(LOG_MEMORY_SIZE))
Memory
(.in_address(Memory_Address),
 .in_data(Memory_Output_Data),
 .in_read_en(Memory_Read_Enable) ,
 .in_write_en(Memory_Write_Enable), 
 .in_clk(clk),
 .in_reset(reset)
 .out_data(Memory_Read_Data));

round_robin #(parameter width) 
Aribert
(.in_clk(clk),
 .in_reset(reset),input [width - 1:0] in_request, output reg [width - 1:0] out_grant); //?




Memory, Arbiter, Main CU , #p processor 
    
endmodule