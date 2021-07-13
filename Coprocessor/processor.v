
module processor #(parameter size = 4 , parameter cell_width = 32, parameter register_address_width = $clog2(size*size) , parameter index_width = 8 ,parameter memory_size = 1024 ,parameter memory_size_log = 10 , parameter width = cell_width * size  ) 
( input in_clk,
 input in_reset,
 input in_grant,
 input [index_width - 1: 0] in_row_index,
 input [index_width - 1: 0] in_col_index,
 input in_index_ready,
 input [index_width - 1 : 0] in_mu,
 input [width - 1: 0] in_mem_data,
 input [cell_width - 1:0] in_Config,
 output out_index_ack,
 output out_result_ready,
 output out_request,
 output out_mem_write_en,
 output out_mem_read_en,
 output [memory_size_log -1 : 0] out_mem_address,
 output [width - 1: 0] out_mem_data);

wire n_sqm_in_ready, n_sqm_out_ready , n_sqm_out_ack;

wire [width - 1: 0 ] n_sqm_in_data;
wire [width - 1: 0 ] n_sqm_out_data;
wire [register_address_width - 1: 0] n_sqm_address;
wire [1:0] n_sqm_type;
wire [1:0] n_sqm_matrix;
wire n_sqm_read_en , n_sqm_write_en;
reg n_sqm_in_data_ready;



square_matrix_mult #(.size(size) , .cell_width(cell_width) , .address_width (register_address_width) ,.width(width)) sq_matrix_mult
       (.in_ready(n_sqm_in_ready),
        .in_data (n_sqm_in_data),
	.in_data_ready (n_sqm_in_data_ready),
	.out_ack (n_sqm_out_ack),
        .in_clk (in_clk),
        .in_reset (in_reset),
	.out_reg_address (n_sqm_address),
	.out_type (n_sqm_type),
	.out_matrix (n_sqm_matrix),
	.out_read_en (n_sqm_read_en),
	.out_write_en (n_sqm_write_en),
        .out_cell_c (n_sqm_out_data),
        .out_ready (n_sqm_out_ready) );


reg [register_address_width - 1: 0] reg_address;
reg [width - 1: 0 ] reg_in_data;
reg [1:0] reg_in_type;
reg [1:0] reg_select_matrix;
reg reg_read_en, reg_write_en;
reg register_reset;
wire [width - 1: 0] reg_out_data;

register_file #(.size(size), .address_width(register_address_width), .cell_width(cell_width)) r_file (.in_address(reg_address) , .in_data(reg_in_data), .in_type(reg_in_type), .in_select_matrix(reg_select_matrix),
.in_clk (in_clk), .in_reset (register_reset), .in_read_en (reg_read_en), .in_write_en(reg_write_en) ,.out_data (reg_out_data));


wire [register_address_width - 1: 0] n_cu_reg_address;
wire n_cu_read_en ,n_cu_write_en , n_cu_AorB;
wire [1:0] n_cu_matrix;
wire cu_mem_write , cu_mem_read;
wire [memory_size_log - 1: 0 ] cu_mem_address;
wire n_cu_type;
assign n_cu_matrix = (n_cu_read_en) ? 2'b10 : {1'b0, n_cu_AorB} ;

CU #(.k (size), .index_width(index_width), .memory_size(memory_size), .memory_size_log(memory_size_log) , .max_mu_log(index_width), .log_k_2(register_address_width)) control_unit (
    .i_Clock (in_clk),
    .i_Reset (in_reset),
    // Arbiter input output
    .i_Grant (in_grant), // show that arbiter grants CU 
    .o_Grant_Request(out_request), // send to arbiter for request and hold it

    // RF input output
    .o_RF_Address (n_cu_reg_address), // Write Address for A or B or Read Address for C
    .o_RF_Write_Enable (n_cu_write_en),// A or B write in RF, enable at receive state disable after that
    .o_RF_Read_Enable (n_cu_read_en), // read C, enable at write state disable after that, in write state determine address
    .o_AorB (n_cu_AorB), // send to RF; read A or B, in receive state determine address

    //Main Cu input output
    .i_Row_Index (in_row_index), // i in C_ij block
    .i_Column_Index (in_col_index), // j in C_ij block
    .i_Indexes_Ready (in_index_ready), // main CU send this signal to show indexes are ready
    .i_mu (in_mu),
	.i_Config(in_Config),
    .o_Indexes_Received (out_index_ack), // send to Main CU for Acknowledge.
    .o_Result_Ready (out_result_ready), // send to Main CU and back to idle state

    //PU input output
    .i_Partial_Output_Ready(n_sqm_out_ready), // PU send to show A_ix * B_xj is ready
    .o_P_Ready_Stable(n_sqm_out_ack),
    .o_PU_Start (n_sqm_in_ready), // send to PU, PU start working

    //Memory input output
    .o_Memory_Write_Enable (cu_mem_write), // enable at write state disable after that 
    .o_Memory_Read_Enable (cu_mem_read), // enable at receive state disable after that
    .o_Memory_Address (cu_mem_address) // Write Address or Read Address in Memory
);

assign out_mem_data = (in_grant) ? reg_out_data : 'bz;
assign out_mem_write_en = (in_grant) ? cu_mem_write : 1'bz;
assign out_mem_read_en = (in_grant) ? cu_mem_read : 1'bz;
assign out_mem_address = (in_grant) ? cu_mem_address : 'bz;

assign n_sqm_in_data = reg_out_data;
assign n_cu_type = 2'b01; //row

localparam s_CU_CONTROL = 1'b0, s_PU_CONTROL = 1'b1;
reg r_states;
reg reseted;

always @(negedge in_reset) begin
	register_reset <= 1;
	r_states = s_CU_CONTROL;
	reseted <= 1;
end
always @(posedge in_clk) begin
	register_reset <= 1;
	if (reseted) begin
		register_reset <= 0;
		reseted <= 0; 
	end
	case (r_states)
	s_CU_CONTROL: begin
	reg_address <= n_cu_reg_address;
	reg_in_data <= in_mem_data;
	reg_in_type <= n_cu_type;
	reg_select_matrix <= n_cu_matrix;
	reg_read_en <= n_cu_read_en;
	reg_write_en <= n_cu_write_en;
	r_states <= s_CU_CONTROL;
	n_sqm_in_data_ready <= 1'b0;
	if (n_sqm_in_ready)
		r_states <= s_PU_CONTROL;
	if (out_result_ready)
		register_reset <= 0;
		end
	s_PU_CONTROL: begin
	reg_address <= n_sqm_address;
	reg_in_data <= n_sqm_out_data;
	reg_in_type <= n_sqm_type;
	reg_select_matrix <= n_sqm_matrix;
	reg_read_en <= n_sqm_read_en;
	reg_write_en <= n_sqm_write_en;
	r_states <= s_PU_CONTROL;
	n_sqm_in_data_ready <= 1'b0;
	if (n_sqm_out_ready)
		r_states <= s_CU_CONTROL;
	if (reg_read_en && n_sqm_read_en && !n_sqm_in_data_ready)
		n_sqm_in_data_ready <= 1'b1;
		end
	endcase
end


endmodule