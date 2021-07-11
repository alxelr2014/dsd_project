`timescale 1ns/1ps
`include "main_control_unit.v"

module main_control_unit_tb;
    //half clock period
    parameter half_cc = 1;

    //clock and reset signals
    reg clk;
    reg reset = 1;

    //mocking inputs
    reg         m_Grant;
    reg         m_Data_Ready;
    reg         m_Indexes_Received;
    reg         m_Result_Ready;
    reg [31:0]  m_Config_Data;

    //testing outputs
    wire        t_o_Grant_Request;
    wire [31:0] t_o_Config;
    wire [9:0]  t_o_Memory_Address;
    wire [31:0] t_o_Status_Data;
    wire        t_o_Write_Enable;
    wire [3:0]  t_o_Indexes_Ready;
    wire [7:0]  t_o_Row_Index;
    wire [7:0]  t_o_Column_Index;

    //handle in-out port
    reg r_Write_Port = 0;
    wire [31:0] t_io_Memory_Data;
    assign t_io_Memory_Data = (r_Write_Port) ? m_Config_Data:'bz;
    assign t_o_Status_Data = t_io_Memory_Data;

    //our testing Unit
    main_CU main_control_unit (
        //inputs
        .i_Clock(clk),
        .i_Reset(reset),
        .i_Data_Ready(m_Data_Ready),
        .i_Grant(m_Grant),
        .i_Indexes_Received(m_Indexes_Received),
        .i_Result_Ready(m_Result_Ready),
        //in-out port
        .io_Memory_Data(t_io_Memory_Data),
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

    //monitoring states
    initial begin
        $monitor("time = %d | state = %b\n\t- Grant_Request:%b \n\t- Config_Data=%b \n\t- Memory_Addres=%b \n\t- Write_Enable=%b \n\t- IO_Memory_Data=%b \n\t- Indexes_Ready=%b \n\t- RowIndex=%d \n\t- ColumnIndex=%d",
        $realtime, main_control_unit.r_State, 
        t_o_Grant_Request,
        t_o_Config,
        t_o_Memory_Address,
        t_o_Write_Enable,
        t_io_Memory_Data,
        t_o_Indexes_Ready,
        t_o_Row_Index,
        t_o_Column_Index
        );
    end

    //testing main_control_unit
    initial begin
        #(0.1*half_cc)
        reset <= 0;
        #(0.8*half_cc)
        reset <= 1;
        #(0.1*half_cc)
        //time = 1

        #(0.1*half_cc)
        m_Data_Ready <= 1;

        #(1.9*half_cc)
        //time = 3

        #(2.5*half_cc)
        m_Grant <= 1;

        #(1.5*half_cc)
        //time = 7

        #(0.1*half_cc)
        r_Write_Port <= 1;
        #(0.1*half_cc)
        m_Config_Data <= 32'b00000011000000110000001100000011;
        #(0.8*half_cc)

        #(half_cc)
        //we have config data - time = 9

        #(2*half_cc)
        
        repeat (4) begin
            #(0.1*half_cc)
            m_Indexes_Received <= 1;
            #(2*half_cc)
            m_Indexes_Received <= 0;
            #(1.9*half_cc);
        end

        //time = 27
        #(0.1*half_cc)
        m_Result_Ready <= 1;
            
        #(1.9*half_cc)
        repeat (4) begin
            #(0.1*half_cc)
            m_Indexes_Received <= 1;
            #(2*half_cc)
            m_Indexes_Received <= 0;
            #(1.9*half_cc);
            m_Result_Ready <= 0;
        end
        //time = 45
        // m_Result_Ready <= 0;
        #(0.1*half_cc)
        m_Result_Ready <= 1;
            
        #(1.9*half_cc)
        //time = 47

        #(0.1*half_cc)
        m_Indexes_Received <= 1;
        #(2*half_cc)
        m_Indexes_Received <= 0;
        #(1.9*half_cc);
        //time = 51
        #(2*half_cc)
        m_Config_Data <= 32'b10000000000000000000000000000000;

        m_Data_Ready <= 0;
        r_Write_Port <= 1;
        #10


        $finish;
    end
    
endmodule