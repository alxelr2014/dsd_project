`timescale 1ns/1ns 
`include "round_robin.v"

module round_robin_tb();
reg clk ,reset;
parameter half_cc = 32'd1;
parameter width = 32'd5;
parameter time_quantum = 32'd2;
reg [width - 1 : 0] request;
wire [width - 1 : 0] grant;
round_robin #(.width(width)) uut (.in_clk (clk),.in_reset(reset) , .in_request(request), .out_grant(grant));
initial begin
	clk = 1'b0;
	forever #(half_cc) clk = ~clk;
end

initial begin
	reset = 1'b1;
	#(half_cc) reset = 1'b0;
	#(half_cc) reset = 1'b1;
end 

initial begin
$monitor ("@ time = %d, reset = %b, requests = %b, grant = %b",$realtime,reset, request, grant);
request <= 5'b00100;
#(4*half_cc) 
#(half_cc) request <= 5'b01100;
#(5*half_cc) request <= 5'b00010;
#(2*half_cc) request <= 5'b11010;
end
endmodule