module main_CU #(
	parameter p = 4,
	parameter index_width = 8,
	parameter greek_size = 8,
	parameter memory_size = 1024,
	parameter memory_size_log = 10)
	(
    input i_Data_Ready, // status in memory 
    input i_Grant, // show to having grant
    input i_Clock,
    inout[31:0] io_Memory_Data,
    input i_Indexes_Received,
    input i_Result_Ready,

    output[31:0] o_Config,
    output o_Grant_Request,
    output[memory_size_log-1:0] o_Memory_Address,
    output reg[index_width-1:0] o_Row_Index,
    output reg[index_width-1:0] o_Column_Index,
    output reg[p-1:0] o_Indexes_Ready,
	output o_Write_Enable;
);

reg[$clog2(p):0] r_Processor_Counter; // 0 to p
reg[2*greek_size:0] r_Scatter_Counter; // 0 to \theta
reg r_Data_Out_Counter;

reg[greek_size-1:0] r_Theta;
reg[greek_size-1:0] r_Gamma;
reg[greek_size-1:0] r_Lambda;
reg[greek_size-1:0] r_mu;
// Other Random Greek Letters
reg[2:0] r_State;

reg[index_width-1:0] r_row;
reg[index_width-1:0] r_column;


//------------------------
reg[31:0] r_Data_In;	// r_Memory_Type = 0
reg[31:0] r_Data_Out;	// r_Memory_Type = 1
reg r_Memory_Type;

assign io_Memory_Data = (r_Memory_Type == 0) ? r_Data_In : r_Data_Out;

localparam s_Idle = 3'b000 ;
localparam s_Request_Config_Grant = 3'b001;
localparam s_Read_Config = 3'b010;
localparam s_Scatter = 3'b011; // پخش کردن بلوک‌ها بین پردازنده‌ها
localparam s_Wait_For_Ready = 3'b100;
localparam s_Request_Status_Grant = 3'b101;
localparam s_Change_Status = 3'b110;

always @(posedge i_Clock)
	begin

	case(r_State)
		s_Idle:
			begin
            if(i_Data_Ready == 1'b1)
			    begin
			    	//more?
			    	r_State <= s_Request_Config_Grant;
			    end
			    else
			    r_State <= s_Idle;

			end

		s_Request_Config_Grant:
			begin
				if (i_Grant == 1) begin
					r_State <= s_Read_Config;		
				end else begin
					o_Grant_Request <= 1'b1;
					r_State <= s_Request_Config_Grant;
				end
			end

		s_Read_Config:
			begin
				//set memory address of config register
				o_Memory_Address <= 0;
				r_Memory_Type <= 0;
				//data has read in r_confgi
				//split config
				r_Lambda <= r_Data_In[greek_size-1:0];
				r_Gamma <= r_Data_In[2*greek_size-1:greek_size];
				r_mu <= r_Data_In[3*greek_size-1:2*greek_size];
				r_theta <= 0; //TODO
				//turn-off grant request
				o_Grant_Request <= 0'b1;
				r_State <= s_Scatter;
				//set registers for scattering
				o_Indexes_Ready <= 1;
				r_row <= 0;
				r_column <= 0;
			end

		s_Scatter:
			begin
				//TODO what if we don't have enough blocks?
				if (r_Processor_Counter < p) begin
					//generate rwo and column number for proccessors
					/*
					 * increase row index till it goes beyound matrix width,
					 * then increase column index and make row index zero
					 */
					//check if proccessor received this signals
					if (i_Indexes_Received == 1) begin
						o_Index_Ready <= o_Indexes_Ready << 1;
						r_Processor_Counter <= r_Processor_Counter + 1;
						r_row <= r_row + 1;
						if (r_row >= r_Gamma) begin
							r_row <= 0;
							r_column <= r_column + 1;
						end
					end
					r_State <= s_Scatter;
				end else begin
					r_Processor_Counter <= 0;
					o_Indexes_Ready <= 1;
					r_State <= s_Wait_For_Ready;
				end			
			end

		s_Wait_For_Ready:
			begin
				if (i_Result_Ready == 1) begin
					if (r_Scatter_Counter < r_theta - 1) begin
						r_State <= s_Scatter;
					end else if (r_Scatter_Counter == r_theta - 1) begin
						r_Processor_Counter <= r_theta * p - r_Gamma * r_Lambda;//TODO is this synthesizable?
						r_State <= s_Scatter;
					end
					else begin
						r_State <= s_Request_Status_Grant;
						r_Scatter_Counter <= 0;
					end
				end else begin
					r_State <= s_Wait_For_Ready;
				end
			end

		s_Request_Status_Grant:
			begin
				if (i_Grant == 1) begin
					r_State <= s_Change_Status;
					r_Data_Out_Counter <= 0;	
				end else begin
					o_Grant_Request <= 1'b1;
					r_State <= s_Request_Status_Grant;
				end
			end

		s_Change_Status:
			begin
				if (r_Data_Out_Counter == 0) begin
					o_Memory_Address <= 1;
					r_Memory_Type <= 1;
					//data goes to r_Data_In
					r_State <= s_Change_Status;
					r_Data_Out_Counter <= 1;
				end else begin
					r_Data_Out <= {r_Data_In[31:1], 1};
					r_Memory_Type <= 1;
					o_Memory_Address <= 1;
					o_Write_Enable <= 1;

					r_State <= s_Idle;
				end
			end
		default: r_State <= s_Idle;
    endcase

    end
endmodule