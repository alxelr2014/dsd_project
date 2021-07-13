`timescale 1ns/1ps
`include "main_control_unit.v"

module main_control_unit_tb;
    //half clock period
    parameter half_cc = 1;

    //clock and reset signals
    reg clk;
    reg reset = 1;

    //mocking inputs
    reg [31:0]  m_Config;
    reg [31:0]  m_Status;
    reg         m_Indexes_Received;
    reg         m_Result_Ready;

    //testing outputs
    wire [31:0] t_o_Status;
    wire        t_o_Write_Status_Enable;
    wire [3:0]  t_o_Indexes_Ready;
    wire [7:0]  t_o_Row_Index;
    wire [7:0]  t_o_Column_Index;

    //our testing Unit
    main_CU main_control_unit (
        //inputs
        .i_Clock(clk),
        .i_Reset(reset),
        .i_Config(m_Config),
        .i_Status(m_Status),
        .i_Indexes_Received(m_Indexes_Received),
        .i_Result_Ready(m_Result_Ready),
        //outputs
        .o_Status(t_o_Status),
        .o_Write_Status_Enable(t_o_Write_Status_Enable),
        .o_Indexes_Ready(t_o_Indexes_Ready),
        .o_Row_Index(t_o_Row_Index),
        .o_Column_Index(t_o_Column_Index)
    );

    //generate clock
    initial begin
	    clk = 1'b0;
	    forever #(half_cc) clk = ~clk;
    end

    //monitoring states
    initial begin
        $monitor("time = %d | state = %b\n\t- Config_Data=%b \n\t- Status_Data=%b \n\t- Write_Status_Enable=%b \n\t- Indexes_Ready=%b \n\t- RowIndex=%d \n\t- ColumnIndex=%d",
        $realtime, main_control_unit.r_State, 
        m_Config,
        t_o_Status,
        t_o_Write_Status_Enable,
        t_o_Indexes_Ready,
        t_o_Row_Index,
        t_o_Column_Index
        );
    end

    //testing main_control_unit
    initial begin
        m_Config <= 32'b00000011000000110000001100000011;
        #(0.1*half_cc)
        reset <= 0;
        #(0.8*half_cc)
        reset <= 1;
        #(0.1*half_cc)
        //time = 1

        #(0.1*half_cc)
        m_Status <= 32'b10000000000000000000000000000000;
        #(1.9*half_cc)
        //time = 3

        #(2*half_cc)
        //time = 5

        repeat (4) begin
            #(0.1*half_cc)
            m_Indexes_Received <= 0;
            #(2*half_cc)
            m_Indexes_Received <= 1;
            #(1.9*half_cc);
        end
        #(2*half_cc)
        //time = 23

        #(0.1*half_cc)
        m_Result_Ready <= 1;
        #(1.9*half_cc)

        repeat (4) begin
            #(0.1*half_cc)
            m_Indexes_Received <= 0;
            #(2*half_cc)
            m_Indexes_Received <= 1;
            #(1.9*half_cc);
        end
        m_Result_Ready <= 0;
        #(2*half_cc)

        #(0.1*half_cc)
        m_Result_Ready <= 1;
        #(1.9*half_cc)

        #(0.1*half_cc)
        m_Indexes_Received <= 0;
        #(2*half_cc)
        m_Indexes_Received <= 1;
        #(1.9*half_cc);
        //the end of scattering

        m_Result_Ready <= 0;
        #(2.1*half_cc)
        m_Result_Ready <= 1;
        #(1.9*half_cc)

        #(4*half_cc)
        $display("time= %d", $realtime);
        $finish;
    end
    
endmodule