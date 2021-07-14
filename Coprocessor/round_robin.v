
module round_robin #(parameter width=4) (input in_clk,input in_reset,input [width - 1:0] in_request, output reg [width - 1:0] out_grant);

localparam s_IDLE = 2'b00 , s_GRANT = 2'b01 , s_WORK = 2'b10;
reg [1:0] r_state;
reg [width-1:0] r_base;

wire [2*width-1:0] n_double_request = {in_request,in_request};
wire [2*width-1:0] n_double_grant;
assign n_double_grant = n_double_request & ~(n_double_request - {{(width){1'b0}}, r_base});

always @(posedge in_clk, negedge in_reset) begin
	if (~in_reset)begin
		r_state <= s_IDLE;
		r_base <= 1;
		out_grant <= 0;
	end
	else begin
	case (r_state)
	s_IDLE:	begin 
	r_base <= 1;
	out_grant <= 0;
	if (in_request != 0)
		r_state <= s_GRANT;
	else
		r_state <= s_IDLE;
	end 

	s_GRANT : begin 
	r_base <= r_base;
	out_grant <= n_double_grant[width-1:0] | n_double_grant[2*width-1:width];
	r_state <= s_WORK;
	end

	s_WORK : begin
	if ((out_grant & in_request) == 0) begin
		r_base <= {out_grant[width -2:0] , out_grant[width-1]}; //cicular left shift
		out_grant <= 0;	
		if (in_request != 0)
			r_state <= s_GRANT;
		else
			r_state <= s_IDLE;
		end
	else begin
		r_base <= r_base;
		out_grant <= out_grant;
		r_state <= s_WORK;
		end
	end
	
	default: begin
		r_base <= 1;
		out_grant <= 0;
		if (in_request != 0)
			r_state <= s_GRANT;
		else
			r_state <= s_IDLE;
	end
	endcase
end
end

endmodule
