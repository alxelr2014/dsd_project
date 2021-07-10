
module round_robin #(parameter width ,parameter time_quantum) (input in_clk,input in_reset,input [width - 1:0] in_request, output reg [width - 1:0] out_grant);

localparam s_IDLE = 2'b00 , s_GRANT = 2'b01 , s_WORK = 2'b10;
reg [1:0] r_state;
reg [width-1:0] r_base;

wire [2*width-1:0] n_double_request = {in_request,in_request};
wire [2*width-1:0] n_double_grant;
assign n_double_grant = n_double_request & ~(n_double_request - {{(width){1'b0}}, r_base});

reg [time_quantum - 1: 0] r_cycles;

always @(negedge in_reset) begin
	r_state <= s_IDLE;
	r_base <= 1;
	out_grant <= 0;
	r_cycles <= 1;
end

always @(posedge in_clk) begin
	case (r_state)
	s_IDLE:	begin 
	r_base <= 1;
	out_grant <= 0;
	r_cycles <= 1;
	if (in_request != 0)
		r_state = s_GRANT;
	else
		r_state = s_IDLE;
	end 

	s_GRANT : begin 
	r_base <= r_base;
	out_grant <= n_double_grant[width-1:0] | n_double_grant[2*width-1:width];
	r_cycles <= 1;
	r_state = s_WORK;
	end

	s_WORK : begin
	if (((out_grant & in_request) == 0) || r_cycles == 0) begin
		r_base <= {out_grant[width -2:0] , out_grant[width-1]}; //cicular left shift
		out_grant <= 0;	
		r_cycles  <= 0;
		if (in_request != 0)
			r_state = s_GRANT;
		else
			r_state = s_IDLE;
		end
	else begin
		r_base <= r_base;
		out_grant <= out_grant;
		r_cycles <= r_cycles << 1;
		r_state <= s_WORK;
		end
	end
	
	default: begin
		r_base <= 1;
		out_grant <= 0;
		r_cycles <= 1;
		if (in_request != 0)
			r_state = s_GRANT;
		else
			r_state = s_IDLE;
	end
	endcase
end

endmodule

`timescale 1ns/1ns 
module round_robin_tb();
reg clk ,reset;
parameter half_cc = 32'd1;
parameter width = 32'd5;
parameter time_quantum = 32'd2;
reg [width - 1 : 0] request;
wire [width - 1 : 0] grant;
round_robin #(.width(width) , .time_quantum(time_quantum)) uut (.in_clk (clk),.in_reset(reset) , .in_request(request), .out_grant(grant));
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

end
endmodule