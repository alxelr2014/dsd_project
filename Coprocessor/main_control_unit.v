`timescale 1ns/1ns

module main_CU #(
	parameter p = 4,
	parameter index_width = 8,
	parameter greek_size = 8,
	parameter memory_size = 1024,
	parameter memory_size_log = 10
) (
    input i_Data_Ready,	// status in memory 
    input i_Grant,		// show to having grant
    input i_Clock,
    input i_Indexes_Received,
    input i_Result_Ready,
	input i_Reset,

    inout[31:0] io_Memory_Data,

    output reg[31:0] o_Config,
    output reg o_Grant_Request,
    output reg[memory_size_log-1:0] o_Memory_Address,
    output wire[index_width-1:0] o_Row_Index,
    output wire[index_width-1:0] o_Column_Index,
    output reg[p-1:0] o_Indexes_Ready,
	output reg o_Write_Enable
);

//counters
reg[$clog2(p):0] r_Processor_Counter;	// 0 to p
reg[2*greek_size:0] r_Scatter_Counter;	// 0 to \theta
reg r_Status_Counter;	// used to count to frist read status and then update it!
reg r_Read_Counter;		// useed to count one clock to read!

//[scattering limit] and [matrix dimensions] paramter
reg[greek_size-1:0] r_Theta;
reg[greek_size-1:0] r_Gamma;
reg[greek_size-1:0] r_Lambda;
reg[greek_size-1:0] r_mu;

//scattering registers
reg[index_width-1:0] r_row;
reg[index_width-1:0] r_column;

assign o_Row_Index = r_row;
assign o_Column_Index = r_column;

//bidirectional port
wire[31:0] r_Data_In;	// r_Memory_Write = 0
reg[31:0] r_Data_Out;	// r_Memory_Write = 1
reg r_Memory_Write;		// 1: write, 0: read

assign io_Memory_Data = (r_Memory_Write) ? r_Data_Out : 'bz;
assign r_Data_In = io_Memory_Data;

// reg [31:0] r_Config;
// assign o_Config = r_Config;

//states
reg[2:0] r_State;

localparam s_Idle = 3'b000 ;
localparam s_Request_Config_Grant = 3'b001;
localparam s_Read_Config = 3'b010;
localparam s_Scatter = 3'b011; // پخش کردن بلوک‌ها بین پردازنده‌ها
localparam s_Wait_For_Ready = 3'b100;
localparam s_Request_Status_Grant = 3'b101;
localparam s_Change_Status = 3'b110;

always @(posedge i_Clock or negedge i_Reset) begin
	if (!i_Reset) begin
		r_State <= 0;
		r_Data_Out <= 0;
		r_Memory_Write <= 0;
		// r_Config <= 0;
		o_Config <= 0;
		r_row <= 0;
		r_column <= 0;
		r_Processor_Counter <= 0;
		r_Scatter_Counter <= 0;
		r_Status_Counter <= 0;
		r_Read_Counter <= 0;
		r_Theta <= 0;
		r_Gamma <= 0;
		r_Lambda <= 0;
		r_mu <= 0;
		o_Grant_Request <= 0;
		o_Memory_Address <= 'bz;
		o_Write_Enable <= 'bz;
		o_Indexes_Ready <= 0;
	end else begin
		case(r_State)
			s_Idle: begin
					if(i_Data_Ready == 1'b1) begin
						r_State <= s_Request_Config_Grant;
						o_Grant_Request <= 1;
					end
					else r_State <= s_Idle;
				end

			s_Request_Config_Grant: begin
					if (i_Grant == 1) begin
						r_State <= s_Read_Config;
						//prepare address for reading
						o_Memory_Address <= 0;
						r_Memory_Write <= 0;
						r_Read_Counter <= 0;	
					end else begin
						o_Memory_Address <= 'bz;
						// o_Write_Enable <= Z; //TODO should we?
					end
				end

			s_Read_Config: begin
					//address has been set in previous state
					//split config
					o_Config <= r_Data_In;
					r_Lambda <= r_Data_In[greek_size-1:0];
					r_Gamma <= r_Data_In[2*greek_size-1:greek_size];
					r_mu <= r_Data_In[3*greek_size-1:2*greek_size];
					r_Theta <= r_Data_In[4*greek_size-1:3*greek_size]; //TODO

					//turn-off grant request
					o_Grant_Request <= 1'b0;
					o_Memory_Address <= 'bz;

					r_State <= s_Scatter;
					//set registers for scattering
					o_Indexes_Ready <= 1;
					r_row <= 0;
					r_column <= 0;
				end

			s_Scatter: begin
					//TODO what if we don't have enough blocks?
					if (i_Indexes_Received == 1) begin
						//generate rwo and column number for proccessors
						/*
						* increase row index till it goes beyound matrix width,
						* then increase column index and make row index zero
						*/
						//check if proccessor received this signals
						if (r_column + 1 >= r_Gamma) begin
							r_column <= 0;
							r_row <= r_row + 1;
						end else begin
							r_column <= r_column + 1;
						end
						if (r_Processor_Counter < p - 1) begin
							o_Indexes_Ready <= o_Indexes_Ready << 1;
							r_Processor_Counter <= r_Processor_Counter + 1;

							// if (r_column + 1 >= r_Gamma) begin
							// 	r_column <= 0;
							// 	r_row <= r_row + 1;
							// end else begin
							// 	r_column <= r_column + 1;
							// end
						end else begin
							r_Processor_Counter <= 0;
							o_Indexes_Ready <= 1;
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
						end else if (r_Scatter_Counter == (r_Theta - 1)) begin
							r_Processor_Counter <= r_Theta * p - r_Gamma * r_Lambda;	//TODO is this synthesizable?
							r_State <= s_Scatter;
						end else begin
							r_State <= s_Request_Status_Grant;
							o_Grant_Request <= 1;
							r_Scatter_Counter <= 0;
						end
					end else begin
						r_State <= s_Wait_For_Ready;
					end
				end

			s_Request_Status_Grant: begin
					if (i_Grant == 1) begin
						r_State <= s_Change_Status;
						r_Status_Counter <= 0;	
						o_Memory_Address <= 1;
						r_Memory_Write <= 0;
						r_Read_Counter <= 0;
					end else begin
						o_Memory_Address <= 'bz;
						r_State <= s_Request_Status_Grant;
						// o_Write_Enable <= Z; //TODO should we?
					end
				end

			s_Change_Status: begin
					if (r_Status_Counter == 0) begin
						r_State <= s_Change_Status;
						r_Status_Counter <= 1;
						r_Data_Out <= r_Data_In + 1;
						r_Memory_Write <= 1;
						o_Write_Enable <= 1;
						r_Read_Counter <= 0;
						// if (r_Read_Counter == 0) begin
						// 	r_State <= s_Change_Status;
						// 	r_Read_Counter <= 1;
						// end else begin
						// 	r_State <= s_Change_Status;
						// 	r_Status_Counter <= 1;
						// 	r_Data_Out <= {r_Data_In[31:1], 1'b1};
						// 	r_Memory_Write <= 1;
						// 	o_Write_Enable <= 1;
						// 	r_Read_Counter <= 0;
						// end
					end else begin					
						o_Grant_Request <= 0;
						o_Memory_Address <= 'bz;
						r_Read_Counter <= 0;
						o_Write_Enable <= 'bz;
						r_row <= 0;
						r_column <= 0;
						r_State <= s_Idle;
					end
				end

			default: r_State <= s_Idle;
		endcase
	end
end
endmodule