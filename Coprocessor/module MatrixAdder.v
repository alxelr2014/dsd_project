module MatrixAdder
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

    reg calc_done = 1'b0;

    reg res1_ack = 1'b0;
    wire res1_ready;
    
    reg res2_ack = 1'b0;
    wire res2_ready;
    
    reg res3_ack = 1'b0;
    wire res3_ready;
    
    reg res4_ack = 1'b0;
    wire res4_ready;
    
    reg res1_done = 1'b0;
    reg res2_done = 1'b0;
    reg res3_done = 1'b0;
    reg res4_done = 1'b0;
    
    adder Adder1(
        .clk(clock),
        .reset(reset),
        .load(1'b1),
        .Number1(matrix_one_00),
        .Number2(matrix_two_00),
        .result_ack(res1_ack),
        .Result(result_00),
        .result_ready(res1_ready));
        
    adder Adder2(
        .clk(clock),
        .reset(reset),
        .load(1'b1),
        .Number1(matrix_one_01),
        .Number2(matrix_two_01),
        .result_ack(res2_ack),
        .Result(result_01),
        .result_ready(res2_ready));
        
    adder Adder3(
        .clk(clock),
        .reset(reset),
        .load(1'b1),
        .Number1(matrix_one_10),
        .Number2(matrix_two_10),
        .result_ack(res3_ack),
        .Result(result_10),
        .result_ready(res3_ready));
        
    adder Adder4(
        .clk(clock),
        .reset(reset),
        .load(1'b1),
        .Number1(matrix_one_11),
        .Number2(matrix_two_11),
        .result_ack(res4_ack),
        .Result(result_11),
        .result_ready(res4_ready));
        
    always @(res1_ready) begin
        if(res1_ready == 1'b1) begin
            res1_ack = 1'b0;
            res1_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(res2_ready) begin
        if(res2_ready == 1'b1) begin
            res2_ack = 1'b0;
            res2_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(res3_ready) begin
        if(res3_ready == 1'b1) begin
            res3_ack = 1'b0;
            res3_done = 1'b1;
        end
        else begin
            // nothing to do
        end
    end
    
    always @(res4_ready) begin
        if(res4_ready == 1'b1) begin
            res4_ack = 1'b0;
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

