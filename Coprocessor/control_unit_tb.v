`timescale 1ns/1ps
`include "control_unit.v"
module control_unit_tb;
    
    parameter half_cc = 1;

    reg clk;
    reg grant;
    reg [7:0] Row_Index;
    reg [7:0] Column_Index;
    reg Indexes_Ready;
    reg [7:0] mu;
    reg Partial_Output_Ready;
    reg reset;
    reg [31:0] Config;

    wire AorB;
    wire Grant_Request;
    wire [1:0] RF_address;
    wire RF_Write_Enable;
    wire RF_Read_Enable;
    wire Indexes_Received;
    wire Result_Ready;
    wire PU_Start;
    wire Memory_Write_Enable;
    wire Memory_Read_Enable;
    wire [9:0] Memory_Address;

    CU control_unit(.i_Config(Config), .i_Reset(reset) ,.i_Clock(clk), .i_Grant(grant), .o_Grant_Request(Grant_Request),
    .o_RF_Address(RF_address), .o_RF_Write_Enable(RF_Write_Enable), .o_RF_Read_Enable(RF_Read_Enable),
    .o_AorB(AorB), .i_Row_Index(Row_Index), .i_Column_Index(Column_Index), .i_Indexes_Ready(Indexes_Ready),
    .i_mu(mu), .o_Indexes_Received(Indexes_Received), .o_Result_Ready(Result_Ready), .i_Partial_Output_Ready(Partial_Output_Ready),
    .o_PU_Start(PU_Start), .o_Memory_Write_Enable(Memory_Write_Enable), .o_Memory_Read_Enable(Memory_Read_Enable), .o_Memory_Address(Memory_Address)
    );

    initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
    end

    wire[7:0] sendTo;
    assign sendTo = (AorB)?"B":"A";

    initial begin
        $monitor(" time = %d | state = %b | grantRequest=%b | x=%d | resultReady=%b | Address=%d | send_to = %s | RF_Write_En = %b",
        $realtime, control_unit.r_State, Grant_Request, control_unit.r_x, Result_Ready, control_unit.r_Clock_Count, sendTo, RF_Write_Enable);
        reset = 1'b1;
	    #(half_cc) reset = 1'b0;
    	#(half_cc) reset = 1'b1;
        #(2*half_cc);
        Row_Index <= 5;
        Column_Index <= 6;
        mu <= 3;
        Indexes_Ready <= 1;

        #(10*half_cc);
        grant <= 1;

        #(50*half_cc);
        Partial_Output_Ready <= 1;

        #46
        $finish;
    end
    
endmodule