module main_CU #(parameter p = 4) (
    input i_Data_Ready, // status in memory 
    input i_Grant, // show to having grant
    inout io_Memory_Data,
    input i_Indexes_Received,
    input i_Result_Ready,
    output o_Grant_Request,
    output o_Memory_Address,
    output reg[] o_Row_Index,
    output reg[] o_Column_Index,
    output reg[0:p-1] o_Indexes_Ready
);
    
reg[] r_Processor_Counter; // o to p
reg[] r_Cycle_Counter; // 0 to \theta
reg[] r_Theta;
reg[] r_Gamma;
reg[] r_Lambda;
// Other Random Greek Letters
reg[] r_State;

localparam s_Idle = ;
localparam s_Request_Config_Grant = ;
localparam s_Read_Config = ;
localparam s_Scatter = ; // پخش کردن بلوک‌ها بین پردازنده‌ها
localparam s_Wait_For_Ready = ;
localparam s_Request_Status_Grant = ;
localparam s_Change_Status = ;

endmodule