`include "index_to_address.v"
module CU #(parameter k = 2, parameter index_width = 8, parameter memory_size = 1024, parameter memory_size_log = 10, parameter max_mu_log = 8, parameter log_k_2 = 2) (
    input i_Clock,
    input i_Reset,
    // Arbiter input output
    input i_Grant, // show that arbiter grants CU 
    output reg o_Grant_Request, // send to arbiter for request and hold it

    // RF input output
    output wire [log_k_2-1:0] o_RF_Address, // Write Address for A or B or Read Address for C
    output reg o_RF_Write_Enable,// A or B write in RF, enable at receive state disable after that
    output reg o_RF_Read_Enable, // read C, enable at write state disable after that, in write state determine address
    output reg o_AorB, // send to RF; read A or B, in receive state determine address

    //Main Cu input output
    input wire[index_width-1:0] i_Row_Index, // i in C_ij block
    input wire[index_width-1:0] i_Column_Index, // j in C_ij block
    input i_Indexes_Ready, // main CU send this signal to show indexes are ready
    input [max_mu_log-1:0] i_mu,
    input [31:0] i_Config,
    output reg o_Indexes_Received, // send to Main CU for Acknowledge.
    output reg o_Result_Ready, // send to Main CU and back to idle state

    //PU input output
    input i_Partial_Output_Ready, // PU send to show A_ix * B_xj is ready
    output reg o_P_Ready_Stable,
    output reg o_PU_Start, // send to PU, PU start working

    //Memory input output
    output reg o_Memory_Write_Enable, // enable at write state disable after that 
    output reg o_Memory_Read_Enable, // enable at receive state disable after that
    output wire [memory_size_log-1:0] o_Memory_Address // Write Address or Read Address in Memory
);

reg[index_width-1:0] r_Row_Index; // save i
reg[index_width-1:0] r_Column_Index; // save j 
reg[max_mu_log-1:0] r_x; // x for A_ix and B_xi 
reg signed [k-1:0] r_Clock_Count;
reg[3:0] r_State;

wire[index_width-1:0] w_Row_Index_To_Decode;
wire[index_width-1:0] w_Column_Index_To_Decode;
wire[2:0] w_Select_Hot_bit;

assign w_Select_Hot_bit = (o_RF_Read_Enable)? 3'b100 : (o_AorB)? 3'b010 : 3'b001;
assign w_Row_Index_To_Decode = (o_RF_Read_Enable)? r_Row_Index : (o_AorB)? r_x : r_Row_Index;
assign w_Column_Index_To_Decode = (o_RF_Read_Enable)? r_Column_Index : (o_AorB)? r_Column_Index : r_x;


index_to_address #(.index_width(index_width) , .k(k) , .Log_Memory_Size(memory_size_log), .output_start(2*(memory_size-2)/3)) 
index_to_address_transform(
    .i_Config(i_Config),
    .i_Row_Index(w_Row_Index_To_Decode),
    .i_Column_Index(w_Column_Index_To_Decode),
    .i_Type(w_Select_Hot_bit),
    .position(r_Clock_Count),
    .o_Address(o_Memory_Address)
);


localparam  s_Idle = 3'b000;
localparam  s_Request_Read_Grant = 3'b001;
localparam  s_Receive = 3'b010;
localparam  s_Wait_For_PU = 3'b011;
localparam  s_Request_Write_Grant = 3'b100;
localparam  s_Wait_For_Write = 3'b101 ;
localparam  s_Middle = 3'b110;
assign o_RF_Address = (r_State == s_Receive) ? (r_Clock_Count - 1) * k : (r_Clock_Count) * k;

always @(posedge i_Clock, negedge i_Reset) begin
    if(~i_Reset) begin
        r_Row_Index <= 0;
        r_Column_Index <= 0;
        r_x <= 0;
        r_Clock_Count <= 0;
        r_State <= 0;
        o_Grant_Request <= 0;
        o_RF_Write_Enable <= 0;
        o_RF_Read_Enable <= 0;
        o_AorB <= 0;
        o_Indexes_Received <= 0;
        o_Result_Ready <= 0;
        o_PU_Start <= 0;
        o_Memory_Write_Enable <= 0;
        o_Memory_Read_Enable <= 0;
        o_P_Ready_Stable <= 0;
    end
    case (r_State)
        s_Idle: begin
            o_Result_Ready <= 0;
            if(i_Indexes_Ready) begin
                r_Row_Index <= i_Row_Index;
                r_Column_Index <= i_Column_Index;
                r_State <= s_Request_Read_Grant;
                r_x <= 0;
                o_AorB <= 0; // receive A
                o_Result_Ready <= 0;
                o_Grant_Request <= 1;
                o_Indexes_Received <= 1; // send Acknwoledge
                o_P_Ready_Stable <= 0;
            end
        end 
        s_Request_Read_Grant: begin
            o_Indexes_Received <= 0;
            if(i_Grant) begin
                r_State <= s_Receive;
                o_Memory_Read_Enable <= 1;
                r_Clock_Count <= 0;
                o_RF_Write_Enable <= 0;
            end
        end
        s_Receive: begin
            if(r_Clock_Count < k ) begin
                o_RF_Write_Enable <= 1;
                r_Clock_Count <= r_Clock_Count + 1;
            end else begin
                if (o_AorB == 0) begin
                    o_AorB <= 1;
                    r_Clock_Count <= 0;
                    o_RF_Write_Enable <= 0;
                end else begin
                    r_Clock_Count <= 0;
                    o_Grant_Request <= 0;
                    o_RF_Write_Enable <= 0;
                    o_Memory_Read_Enable <= 0;
                    r_State <= s_Wait_For_PU;
                    o_PU_Start <= 1;
                    o_P_Ready_Stable <= 0;
                end
            end
        end
        s_Wait_For_PU: begin
            o_PU_Start <= 0; // Important
            if (i_Partial_Output_Ready) begin
                o_P_Ready_Stable <= 1;
                if (r_x < (i_mu - 1)) begin
                    r_x <= r_x + 1;
                    o_AorB <= 0;
                    o_Grant_Request <= 1;
                    r_State <= s_Request_Read_Grant;
                end else begin
                    o_Grant_Request <= 1;
                    r_State <= s_Request_Write_Grant;
                end
            end
        end
        s_Request_Write_Grant: begin
            if(i_Grant) begin
                r_State <= s_Middle;
                o_Memory_Write_Enable <= 0;
                o_RF_Read_Enable <= 1;
                r_Clock_Count <=0 ;
            end     
        end
        s_Middle: begin
            r_State <= s_Wait_For_Write;
        end
        
        s_Wait_For_Write: begin
            if(r_Clock_Count < k) begin
                o_Memory_Write_Enable <= 1;
                r_Clock_Count <= r_Clock_Count + 1;
                r_State <= s_Middle;
            end
            else begin
                o_RF_Read_Enable <= 0;
                o_Memory_Write_Enable <= 0;
                o_Grant_Request <= 0;
                o_Result_Ready <= 1;
                r_State <= s_Idle;
            end
        end
        default: r_State <= s_Idle;
    endcase
end


endmodule