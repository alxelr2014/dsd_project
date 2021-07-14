`timescale 1ns/1ns
module main_CU #(
	parameter p = 4,				//number of processors
	parameter index_width = 8,		//width of i, j, lambda, gamma, mu
	parameter memory_size = 1024,	//:)
	parameter memory_size_log = 10	//:)
) (
    input [31:0] i_Config,	// config in memory
	input [31:0] i_Status, // Status in memory 
    input i_Clock,
    input i_Indexes_Received,
    input i_Result_Ready,
	input i_Reset,
    output wire[index_width-1:0] o_Row_Index,
    output wire[index_width-1:0] o_Column_Index,
    output reg[p-1:0] o_Indexes_Ready,
	output [31:0] o_Status,
	output reg o_Write_Status_Enable
);

//counters
reg[$clog2(p):0] r_Processor_Counter;	// 0 to p
reg[2*index_width:0] r_Scatter_Counter;	// 0 to \theta

//[scattering limit] and [matrix dimensions] paramter
reg[index_width-1:0] r_Theta;
reg[index_width-1:0] r_Gamma;
reg[index_width-1:0] r_Lambda;

//scattering registers
reg[index_width-1:0] r_row;
reg[index_width-1:0] r_column;

assign o_Row_Index = r_row;
assign o_Column_Index = r_column;

//to update status
reg [31:0] r_Status;
assign o_Status = r_Status;

//states
reg[2:0] r_State;

localparam s_Idle = 3'b000 ;
localparam s_Read_Config = 3'b01;
localparam s_Scatter = 3'b010; // پخش کردن بلوک‌ها بین پردازنده‌ها
localparam s_Wait_For_Ready = 3'b011;
localparam s_Change_Status = 3'b100;

always @(posedge i_Clock or negedge i_Reset) begin
	if (!i_Reset) begin
		r_State <= 0;
		r_row <= 0;
		r_column <= 0;
		r_Processor_Counter <= 0;
		r_Scatter_Counter <= 0;
		r_Theta <= 0;
		r_Gamma <= 0;
		r_Lambda <= 0;
		r_Status <= 0;
		o_Write_Status_Enable <= 0;
		o_Indexes_Ready <= 0;
	end else begin
		case(r_State)
			s_Idle: begin
				if(i_Status[31] == 1'b1) begin
					r_State <= s_Read_Config;
				end
				else r_State <= s_Idle;
			end

			s_Read_Config: begin
				r_Lambda <= i_Config[index_width-1:0];
				r_Gamma <= i_Config[2*index_width-1:index_width];
				r_Theta <= i_Config[4*index_width-1:3*index_width];

				r_State <= s_Scatter;
				//set registers for scattering
				o_Indexes_Ready <= 1;
				r_row <= 0;
				r_column <= 0;
			end

			s_Scatter: begin
				//TODO what if we don't have enough blocks?
				if (i_Indexes_Received == 1) begin
					/*
					 * generate rwo and column number for processors
					 * increase row index till it goes beyound matrix width,
					 * then increase column index and make row index zero
					 */
					if (r_column + 1 >= r_Gamma) begin
						r_column <= 0;
						r_row <= r_row + 1;
					end else begin
						r_column <= r_column + 1;
					end
					//check if we still have processor to assign
					if (r_Processor_Counter < p - 1) begin
						o_Indexes_Ready <= o_Indexes_Ready << 1;
						r_Processor_Counter <= r_Processor_Counter + 1;
					end else begin
						r_Processor_Counter <= 0;
						o_Indexes_Ready <= 0;
						r_State <= s_Wait_For_Ready;
						r_Scatter_Counter <= r_Scatter_Counter + 1;
					end
				end else begin
					r_State <= s_Scatter;
				end			
			end

			s_Wait_For_Ready: begin
				if (i_Result_Ready == 1) begin
					if (r_Scatter_Counter < (r_Theta - 1)) begin
						r_State <= s_Scatter;
						o_Indexes_Ready <= 1;
					end else if (r_Scatter_Counter == (r_Theta - 1)) begin
						r_Processor_Counter <= r_Theta * p - r_Gamma * r_Lambda;	//TODO is this synthesizable?
						r_State <= s_Scatter;
						o_Indexes_Ready <= 1;
					end else begin
						r_State <= s_Change_Status;
						r_Scatter_Counter <= 0;
						r_Status <= {i_Status[31:1], 1'b1};
						o_Write_Status_Enable <= 1;
					end
				end else begin
					r_State <= s_Wait_For_Ready;
				end
			end

			s_Change_Status: begin
				o_Write_Status_Enable <= 0;
				r_State <= s_Idle;
			end

			default: r_State <= s_Idle;
		endcase
	end
end
endmodule