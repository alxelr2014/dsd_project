module main_CU #(parameter p = 4) (
    input i_Data_Ready, // status in memory 
    input i_Grant, // show to having grant
    input i_Clock,
    inout io_Memory_Data,
    input i_Indexes_Received,
    input i_Result_Ready,
    output[31:0] o_Config,
    output o_Grant_Request,
    output o_Memory_Address,
    output reg[] o_Row_Index,
    output reg[] o_Column_Index,
    output reg[p-1:0] o_Indexes_Ready
);

reg[] r_Processor_Counter; // o to p
reg[] r_Cycle_Counter; // 0 to \theta
reg[] r_Theta;
reg[] r_Gamma;
reg[] r_Lambda;
reg[] r_mu;
// Other Random Greek Letters
reg[2:0] r_State;

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

			end

		s_Request_Config_Grant:
			begin

			end

		s_Read_Config:
			begin

			end

		s_Scatter:
			begin

			end

		s_Wait_For_Ready:
			begin

			end

		s_Request_Status_Grant:
			begin

			end

		s_Change_Status:
			begin

			end

endmodule