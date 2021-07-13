module top_module_tb;
    
    parameter half_cc = 1;
    parameter WORD_SIZE = 32;
    parameter NUMBER_OF_PROCESSORS = 4;
    parameter MEMORY_SIZE = 1024;
    parameter BLOCK_SIZE = 3;

    reg clk , reset;
    reg [64:0] clk_count = 0;

    //Generate Clock
    initial begin
	    clk = 1'b0;
	    forever begin
           #(half_cc) clk = ~clk; 
           if (clk) begin
               clk_count = clk_count + 1;
           end
        end 
    end

    //Generate Reset
    initial begin
       	reset = 1'b1;
    	#(half_cc) reset = 1'b0;
	    #(half_cc) reset = 1'b1;
    end

    //instantiate
    Top_Module #(.WORD_SIZE(WORD_SIZE),
      .NUMBER_OF_PROCESSORS(NUMBER_OF_PROCESSORS),
      .MEMORY_SIZE(MEMORY_SIZE),
      .BLOCK_SIZE(BLOCK_SIZE)) 
    matrix_multiplier(
        .clk(clk),
        .reset(reset)
    );
    
    //Initial Memory
    initial begin
        $readmemh("init/memory_tb_init.txt", matrix_multiplier.Memory.memory);
    end

    //Monitoring
    initial begin
        $monitor("@#clk = %d\n, Memory_Address = %h, Memory_Write_Data = %h, Memory_Read_Data = %h\n Memory_Read_Enable = %b, Memory_Write_Enable = %b \n Requests = %b, Grants = %b \n Main_CU_Status = %b"
        , clk_count
        , matrix_multiplier.Memory_Address
        , matrix_multiplier.Memory_Write_Data
        , matrix_multiplier.Memory_Read_Data
        , matrix_multiplier.Memory_Read_Enable
        , matrix_multiplier.Memory_Write_Enable
        , matrix_multiplier.Requests,
        , matrix_multiplier.Grants
        , matrix_multiplier.Main_Controller.r_State);
    end

endmodule