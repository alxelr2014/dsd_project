module MatrixMultiplier
(
  input clock,
  input reset,
  input [31:0] matrix_one_00,
  input [31:0] matrix_one_01,
  input [31:0] matrix_one_10,
  input [31:0] matrix_one_11,
  
  input [31:0] matrix_two_00,
  input [31:0] matrix_two_01,
  input [31:0] matrix_two_10,
  input [31:0] matrix_two_11,
  
  output done,
  output [31:0] result_00,
  output [31:0] result_01,
  output [31:0] result_10,
  output [31:0] result_11
);

    wire [31:0] mul_res_00_00;
    wire [31:0] mul_res_00_01;
    
    wire [31:0] mul_res_01_10;
    wire [31:0] mul_res_01_11;
    
    wire [31:0] mul_res_10_00;
    wire [31:0] mul_res_10_01;
    
    wire [31:0] mul_res_11_10;
    wire [31:0] mul_res_11_11;
    
    wire a1_ack;
    wire a2_ack;
    wire a3_ack;
    wire a4_ack;
    wire b1_ack;
    wire b2_ack;
    wire b3_ack;
    wire b4_ack;
    
    wire res1_ready;
    reg res1_ack = 1'b0;
    
    wire res2_ready;
    reg res2_ack = 1'b0;
    
    wire res3_ready;
    reg res3_ack = 1'b0;
    
    wire res4_ready;
    reg res4_ack = 1'b0;
    
    wire res5_ready;
    reg res5_ack = 1'b0;
    
    wire res6_ready;
    reg res6_ack = 1'b0;
    
    wire res7_ready;
    reg res7_ack = 1'b0;
    
    wire res8_ready;
    reg res8_ack = 1'b0;
    
    single_multiplier Multiplier1(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_00),
        .input_a_stb(1'b1),
        .input_a_ack(a1_ack),
        .input_b(matrix_two_00),
        .input_b_stb(1'b1),
        .input_b_ack(b1_ack),
        .output_z(mul_res_00_00),
        .output_z_stb(res1_ready),
        .output_z_ack(res1_ack));
        
    single_multiplier Multiplier2(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_00),
        .input_a_stb(1'b1),
        .input_a_ack(a2_ack),
        .input_b(matrix_two_01),
        .input_b_stb(1'b1),
        .input_b_ack(b2_ack),
        .output_z(mul_res_00_01),
        .output_z_stb(res2_ready),
        .output_z_ack(res2_ack));
        
    single_multiplier Multiplier3(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_01),
        .input_a_stb(1'b1),
        .input_a_ack(a3_ack),
        .input_b(matrix_two_10),
        .input_b_stb(1'b1),
        .input_b_ack(b3_ack),
        .output_z(mul_res_01_10),
        .output_z_stb(res3_ready),
        .output_z_ack(res3_ack));
        
    single_multiplier Multiplier4(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_01),
        .input_a_stb(1'b1),
        .input_a_ack(a4_ack),
        .input_b(matrix_two_11),
        .input_b_stb(1'b1),
        .input_b_ack(b4_ack),
        .output_z(mul_res_01_11),
        .output_z_stb(res4_ready),
        .output_z_ack(res4_ack));
        
    single_multiplier Multiplier5(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_10),
        .input_a_stb(1'b1),
        .input_a_ack(a5_ack),
        .input_b(matrix_two_00),
        .input_b_stb(1'b1),
        .input_b_ack(b5_ack),
        .output_z(mul_res_10_00),
        .output_z_stb(res5_ready),
        .output_z_ack(res5_ack));
        
    single_multiplier Multiplier6(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_10),
        .input_a_stb(1'b1),
        .input_a_ack(a6_ack),
        .input_b(matrix_two_01),
        .input_b_stb(1'b1),
        .input_b_ack(b6_ack),
        .output_z(mul_res_10_01),
        .output_z_stb(res6_ready),
        .output_z_ack(res6_ack));
        
    single_multiplier Multiplier7(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_11),
        .input_a_stb(1'b1),
        .input_a_ack(a7_ack),
        .input_b(matrix_two_10),
        .input_b_stb(1'b1),
        .input_b_ack(b7_ack),
        .output_z(mul_res_11_10),
        .output_z_stb(res7_ready),
        .output_z_ack(res7_ack));
        
    single_multiplier Multiplier8(
        .clk(clock),
        .rst(reset),
        .input_a(matrix_one_11),
        .input_a_stb(1'b1),
        .input_a_ack(a8_ack),
        .input_b(matrix_two_11),
        .input_b_stb(1'b1),
        .input_b_ack(b8_ack),
        .output_z(mul_res_11_11),
        .output_z_stb(res8_ready),
        .output_z_ack(res8_ack));
        
      
      
    reg add_res1_ack = 1'b0;
    wire add_res1_ready;
    reg load1 = 1'b0;
    
    reg add_res2_ack = 1'b0;
    wire add_res2_ready;
    reg load2 = 1'b0;
    
    reg add_res3_ack = 1'b0;
    wire add_res3_ready;
    reg load3 = 1'b0;
    
    reg add_res4_ack = 1'b0;
    wire add_res4_ready;
    reg load4 = 1'b0;
    
    adder Adder1(
        .clk(clock),
        .reset(reset),
        .load(load1),
        .Number1(mul_res_00_00),
        .Number2(mul_res_01_10),
        .result_ack(add_res1_ack),
        .Result(result_00),
        .result_ready(add_res1_ready));
        
    adder Adder2(
        .clk(clock),
        .reset(reset),
        .load(load2),
        .Number1(mul_res_00_01),
        .Number2(mul_res_01_11),
        .result_ack(add_res2_ack),
        .Result(result_01),
        .result_ready(add_res2_ready));
        
    adder Adder3(
        .clk(clock),
        .reset(reset),
        .load(load3),
        .Number1(mul_res_10_00),
        .Number2(mul_res_11_10),
        .result_ack(add_res3_ack),
        .Result(result_10),
        .result_ready(add_res3_ready));
        
    adder Adder4(
        .clk(clock),
        .reset(reset),
        .load(load4),
        .Number1(mul_res_10_01),
        .Number2(mul_res_11_11),
        .result_ack(add_res4_ack),
        .Result(result_11),
        .result_ready(add_res4_ready));  
        
        
    always @(res1_ready or res3_ready) begin
        if((res1_ready == 1'b1)
            && (res3_ready == 1'b1)) begin
            load1 = 1'b1;
            res1_ack = 1'b0;
            res3_ack = 1'b0;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(res2_ready or res4_ready) begin
        if((res2_ready == 1'b1)
            && (res4_ready == 1'b1)) begin
            load2 = 1'b1;
            res2_ack = 1'b0;
            res4_ack = 1'b0;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(res5_ready or res7_ready) begin
        if((res5_ready == 1'b1)
            && (res7_ready == 1'b1)) begin
            load3 = 1'b1;
            res5_ack = 1'b0;
            res7_ack = 1'b0;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(res6_ready or res8_ready) begin
        if((res6_ready == 1'b1)
            && (res8_ready == 1'b1)) begin
            load4 = 1'b1;
            res6_ack = 1'b0;
            res8_ack = 1'b0;
        end
        else begin
            // nothing to do
        end
    end
    
    reg calc_done = 1'b0;
    
    reg res1_done = 1'b0;
    reg res2_done = 1'b0;
    reg res3_done = 1'b0;
    reg res4_done = 1'b0;
    
    
    always @(add_res1_ready) begin
        if(add_res1_ready == 1'b1) begin
            add_res1_ack = 1'b0;
            res1_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(add_res2_ready) begin
        if(add_res2_ready == 1'b1) begin
            add_res2_ack = 1'b0;
            res2_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(add_res3_ready) begin
        if(add_res3_ready == 1'b1) begin
            add_res3_ack = 1'b0;
            res3_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(add_res4_ready) begin
        if(add_res4_ready == 1'b1) begin
            add_res4_ack = 1'b0;
            res4_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(posedge clock) begin 
        if((res1_done == 1'b1)
          && (res2_done == 1'b1)
          &&(res3_done == 1'b1)
          &&(res4_done == 1'b1)) begin
            
            calc_done <= 1'b1;
          end
    end
    
    always @(negedge reset) begin
        if(reset == 1'b1) begin
            res1_ack <= 1'b0;
            res2_ack <= 1'b0;
            res3_ack <= 1'b0;
            res4_ack <= 1'b0;
            res5_ack <= 1'b0;
            res6_ack <= 1'b0;
            res7_ack <= 1'b0;
            res8_ack <= 1'b0;
            
            add_res1_ack <= 1'b0;
            add_res2_ack <= 1'b0;
            add_res3_ack <= 1'b0;
            add_res4_ack <= 1'b0;
            
            load1<= 1'b0;
            load2 <= 1'b0;
            load3 <= 1'b0;
            load4 <= 1'b0;
            
            res1_done <= 1'b0;
            res2_done <= 1'b0;
            res3_done <= 1'b0;
            res4_done <= 1'b0;
            calc_done <= 1'b0;
        end
        else begin
            // nothing to do
        end
    end
    
    assign done = calc_done;
    
endmodule