`timescale 1ns/1ns
`include "index_to_address"

module CU #(parameter k = 2, parameter index_width = 8, parameter memory_size = 1024, parameter memory_size_log = 10, parameter max_mu_log = 8, parameter log_k_2 = 2) (
    input wire[index_width-1:0] i_Row_Index, // i in C_ij block
    input wire[index_width-1:0] i_Column_Index, // j in C_ij block
    input i_Clock,
    input i_Indexes_Ready, // main CU send this signal to show indexes are ready
    input i_Grant, // show that arbiter grants CU 
    input i_Partial_Output_Ready, // PU send to show A_ix * B_xj is ready
    
    output wire [log_k_2-1:0] o_RF_Address, // Write Address for A or B or Read Address for C
    output o_RF_Write_Enable,
    output o_RF_Read_Enable, // read C 
    output reg o_AorB, // send to RF; read A or B

    output o_Memory_Write_Enable,
    output reg o_Memory_Read_Enable,
    output wire [memory_size_log-1:0] o_Memory_Address,// Write Address or Read Address in Memory
    output reg o_Indexes_Received, // send to Main CU for Acknowledge.
    output reg o_Grant_Request, // send to arbiter for request and hold it
    output o_PU_Start, // send to PU, PU start working
    output o_Result_Ready // send to Main CU and back to idle state
);

reg[index_width-1:0] r_Row_Index;
reg[index_width-1:0] r_Column_Index;
reg[max_mu_log-1:0] r_x;
reg[log_k_2-1:0] r_Clock_Count;
reg[] r_State;

wire[index_width-1:0] w_Row_Index_To_Decod;

assign w_Row_Index_To_Decod = (o_AorB)
assign o_RF_Address = r_Clock_Count;

index_to_address()


localparam  s_Idle;
localparam  s_Request_Read_Grant;
localparam  s_Receive;
localparam  s_Receive_B;
localparam  s_Wait_For_PU = ;
localparam  s_Request_Write_Grant =;
localparam  s_Wait_For_Write = ;

always @(posedge i_Clock) begin
    case (r_State)
        s_Idle: begin
            if(i_Indexes_Ready) begin
                r_Row_Index <= i_Row_Index;
                r_Column_Index <= i_Column_Index;
                r_State <= s_Request_Write_Grant;
                r_x <= 0;
                o_AorB <= 0;
                o_Grant_Request <= 1;
                o_Indexes_Received <= 1; // send Acknwoledge
            end
        end 
        s_Request_Write_Grant: begin
            if(i_Grant) begin
                r_State <= s_Receive;
                r_Clock_Count <= 0;
                o_Memory_Read_Enable <= 1;
            end
        end
        s_Receive: begin
            o_RF_Write_Enable <= 1;
        end
        default: 
    endcase
end


endmodule