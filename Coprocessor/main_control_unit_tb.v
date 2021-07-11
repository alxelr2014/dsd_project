`timescale 1ns/1ps
`include "main_control_unit.v"

module main_control_unit_tb;
    //half clock period
    parameter half_cc = 1;

    //clock
    reg clk;
    
    //mocking inputs
    reg m_Grant;
    reg m_Data_Ready;
    reg m_Indexes_Received;
    reg m_Result_Ready;
    reg[31:0] m_Config_Data;

    //testing outputs
    wire t_o_Grant_Request;
    wire[31:0] t_o_Config;
    wire[9:0] t_o_Memory_Address;
    wire t_o_Write_Enable;
    wire[p-1] t_o_Indexes_Ready;
    wire[7:0] t_o_Row_Index;
    wire[7:0] t_o_Column_Index;

    //testing Unit
    main_CU main_control_unit (
        //inputs
        .i_Clock(clk),
        .i_Data_Ready(m_Data_Ready),
        .i_Grant(m_Grant),
        .i_Indexes_Received(m_Indexes_Received),
        .i_Result_Ready(m_Result_Ready),
        //outputs
        .o_Grant_Request(t_o_Grant_Request),
        .o_Config(t_o_Config),
        .o_Memory_Address(t_o_Memory_Address),
        .o_Write_Enable(t_o_Write_Enable),
        .o_Indexes_Ready(t_o_Indexes_Ready),
        .o_Row_Index(t_o_Row_Index),
        .o_Column_Index(t_o_Column_Index)
    );




    //generate clock
    initial begin
	    clk = 1'b0;
	    forever #(half_cc) clk = ~clk;
    end

    initial begin
        
    end
    
endmodule