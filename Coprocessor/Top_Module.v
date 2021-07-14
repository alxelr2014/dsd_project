`timescale 1ns/1ns
module Top_Module #(parameter WORD_SIZE = 32,
  parameter NUMBER_OF_PROCESSORS = 4,
  parameter MEMORY_SIZE = 1024,
  parameter BLOCK_SIZE = 3) 
  (
    input clk,
    input reset,
    output resault_ready
);

parameter LOG_MEMORY_SIZE = $clog2(MEMORY_SIZE);
parameter MEMORY_WIDTH = BLOCK_SIZE * WORD_SIZE;
parameter INDEX_WIDTH = WORD_SIZE/4;

//Memory Wires
wire[LOG_MEMORY_SIZE-1 : 0] Memory_Address;
wire[MEMORY_WIDTH-1 : 0] Memory_Write_Data;
wire[MEMORY_WIDTH-1 : 0] Memory_Read_Data;
wire[WORD_SIZE - 1 : 0] Memory_Write_Status;
wire[WORD_SIZE - 1 : 0] Memory_Config;
wire[WORD_SIZE - 1 : 0] Memory_Read_Status;

wire Memory_Read_Enable;
wire Memory_Write_Enable;
wire Memory_Write_Status_Enable;

wire [NUMBER_OF_PROCESSORS - 1 : 0] Processor_Get_Indexes_Acknowledge;
wire [NUMBER_OF_PROCESSORS - 1 : 0] Processor_Resault_Ready;

wire [NUMBER_OF_PROCESSORS - 1 : 0] Requests;
wire [NUMBER_OF_PROCESSORS - 1 : 0] Grants;
wire [NUMBER_OF_PROCESSORS - 1 : 0] Indexes_Ready;
wire [INDEX_WIDTH-1 : 0] Row_Index;
wire [INDEX_WIDTH-1 : 0] Col_Index;

wire Main_CU_Indexes_Received;
wire Main_CU_Resault_Ready;

assign resault_ready = Memory_Read_Status[0];

assign Main_CU_Indexes_Received = |Processor_Get_Indexes_Acknowledge;
assign Main_CU_Resault_Ready = &Processor_Resault_Ready;

genvar i;
generate
    for (i = 0; i < NUMBER_OF_PROCESSORS ; i = i + 1) begin: processor
    processor #(.size(BLOCK_SIZE) , .cell_width(WORD_SIZE) , .index_width(INDEX_WIDTH) , .memory_size(MEMORY_SIZE) , .memory_size_log(LOG_MEMORY_SIZE)) 
    PU
    (.in_clk(clk),
    .in_reset(reset),
    .in_grant(Grants[i]),
    .in_row_index(Row_Index),
    .in_col_index(Col_Index),
    .in_index_ready(Indexes_Ready[i]),
    .in_mu(Memory_Config[23:16]),
    .in_mem_data(Memory_Read_Data), // Memory Output Data?
    .in_Config(Memory_Config),
    .out_index_ack(Processor_Get_Indexes_Acknowledge[i]),
    .out_result_ready(Processor_Resault_Ready[i]),
    .out_request(Requests[i]),
    .out_mem_write_en(Memory_Write_Enable),
    .out_mem_read_en(Memory_Read_Enable),
    .out_mem_address(Memory_Address),
    .out_mem_data(Memory_Write_Data)); // Memory Input Data? 
    end
endgenerate

memory #(.size(MEMORY_SIZE), .blocks(BLOCK_SIZE), .log_size(LOG_MEMORY_SIZE), .cell_width(WORD_SIZE))
Memory
(.in_address(Memory_Address),
 .in_data(Memory_Write_Data),
 .in_read_en(Memory_Read_Enable),
 .in_write_en(Memory_Write_Enable), 
 .in_write_status_en(Memory_Write_Status_Enable),
 .out_config(Memory_Config),
 .out_status(Memory_Read_Status),
 .in_status(Memory_Write_Status),
 .in_clk(clk),
 .in_reset(reset),
 .out_data(Memory_Read_Data));

round_robin #(.width(NUMBER_OF_PROCESSORS)) 
Arbiter
(.in_clk(clk),
 .in_reset(reset),
 .in_request(Requests),
 .out_grant(Grants)
 );

main_CU #(
	.p(NUMBER_OF_PROCESSORS),
	.index_width(INDEX_WIDTH),
	.memory_size(MEMORY_SIZE),
	.memory_size_log(LOG_MEMORY_SIZE)
)
Main_Controller (
    .i_Config(Memory_Config),	// config in memory
	.i_Status(Memory_Read_Status), // Status in memory 
    .i_Clock(clk),
    .i_Indexes_Received(Main_CU_Indexes_Received),
    .i_Result_Ready(Main_CU_Resault_Ready),
	.i_Reset(reset),
    .o_Row_Index(Row_Index),
    .o_Column_Index(Col_Index),
    .o_Indexes_Ready(Indexes_Ready),
	.o_Status(Memory_Write_Status),
    .o_Write_Status_Enable(Memory_Write_Status_Enable)
);

    
endmodule