module CU #(parameter k = 2, parameter index_width = 8, parameter memory_size = 1024, parameter memory_size_log = 10) (
    input wire[index_width-1:0] i_Row_Index, // i in C_ij block
    input wire[index_width-1:0] i_Column_Index, // j in C_ij block
    input i_Clock,
    input i_Indexes_Ready, // main CU send this signal to show indexes are ready
    input i_Grant, // show that arbiter grants CU 
    input i_Partial_Output_Ready, // PU send to show A_ix * B_xj is ready
    output o_RF_Address, // Write Address for A or B or Read Address for C
    output o_Memory_Write_Enable,
    output wire[memory_size_log-1:0] o_Memory_Address,// Write Address or Read Address in Memory
    output o_Indexes_Received, // send to Main CU for Acknowledge.
    output o_Grant_Request, // send to arbiter for request and hold it
    output o_RF_Read_Enable, // read C 
    output o_AorB, // send to RF; read A or B
    output o_RF_Write_Enable,
    output o_RF_Start, // send to RF, RF start working
    output o_Result_Ready // send to Main CU and back to idle state
);

reg[] r_x;
reg[] r_Clock_Count;
reg[] r_State;

localparam  s_Idle;
localparam  s_Request_Read_Grant;
localparam  s_Receive_A;
localparam  s_Receive_B;
localparam  s_Wait_For_PU = ;
localparam  s_Request_Write_Grant =;
localparam  s_Wait_For_Write = ;

endmodule