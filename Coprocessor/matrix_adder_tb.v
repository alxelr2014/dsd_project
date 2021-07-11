`timescale 1ns / 1ns

module test();

    reg clock;
    reg reset;
    reg [31:0] matrix_one_00;
    reg [31:0] matrix_one_01;
    reg [31:0] matrix_one_10;
    reg [31:0] matrix_one_11;
    
    reg [31:0] matrix_two_00;
    reg [31:0] matrix_two_01;
    reg [31:0] matrix_two_10;
    reg [31:0] matrix_two_11;
    
    wire done;
    wire [31:0] result_00;
    wire [31:0] result_01;
    wire [31:0] result_10;
    wire [31:0] result_11;



    localparam period = 200;
    localparam clock_period = 50;  

    MatrixAdder UUT (
        .matrix_one_00(matrix_one_00),
        .matrix_one_01(matrix_one_01),
        .matrix_one_10(matrix_one_10),
        .matrix_one_11(matrix_one_11),

        .matrix_two_00(matrix_two_00),
        .matrix_two_01(matrix_two_01),
        .matrix_two_10(matrix_two_10),
        .matrix_two_11(matrix_two_11),


        .result_00(result_00),
        .result_01(result_01),
        .result_10(result_10),
        .result_11(result_11),

        .clock(clock), 
        .reset(reset), 
        .done(done)
    );


initial 
begin
    clock = 1;
    forever #(clock_period/2) clock = ~ clock;
end


initial // initial block executes only once
	begin
	  
		
		//   |3.56 1|
		//   |1 1|
		matrix_one_00[31:0] = 32'b01000000011000111101011100001010; // = 3.56
		matrix_one_01[31:0] = 32'b00111111100000000000000000000000; // = 1
        	matrix_one_10[31:0] = 32'b00111111100000000000000000000000;
        	matrix_one_11[31:0] = 32'b00111111100000000000000000000000;

		//   |2 2|
		//   |2 2|
		matrix_two_00[31:0] = 32'b01000000000011011010000111001010; // = 2
        matrix_two_01[31:0] = 32'b01000000000011011010000111001010; 
        matrix_two_11[31:0] = 32'b01000000000011011010000111001010;
        matrix_two_11[31:0] = 32'b01000000000011011010000111001010; 

		//#(clock_period/2);
		//#(100*clock_period);
		//$finish;
	end
always @(posedge done) begin
		$display("Output is ready, time is %0t ps",$time);
		$display("out[1][1] = %b",result_00);
		$display("out[1][2] = %b",result_01);
		$display("out[2][1] = %b",result_10);
		$display("out[2][2] = %b",result_11);
		
end
	
endmodule
