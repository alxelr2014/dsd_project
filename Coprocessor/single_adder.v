module adder(
	input_a,
	input_a_stb,
        input_a_ack,
	input_b,
	input_b_stb,
        input_b_ack,
	clk,
	rst,
	output_z,
	output_z_stb,
        output_z_ack);

  input     [31:0] input_a;
  input     input_a_stb;
  input     [31:0] input_b;
  input     input_b_stb;
  input     output_z_ack;

  input     clk;
  input     rst;

  output    reg [31:0] output_z;
  output    reg input_a_ack;
  output    reg input_b_ack;
  output    reg output_z_stb;

  reg       [31:0] a, b ,z;
  reg       [24:0] a_m, b_m, z_m;
  reg       [8:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;

  reg	special_cases=0;

  reg       [3:0] state  = 0 ; 

  parameter unpack       = 4'b0000;
  parameter spec_case    = 4'b0001;
  parameter align        = 4'b0010;
  parameter same_sign    = 4'b0011;
  parameter un_same_sign = 4'b0100;
  parameter normalize_same_sign    = 4'b0101;
  parameter normalize_unsame_sign  = 4'b0110;
  parameter correct_twos_comp      = 4'b0111;
  parameter done         = 4'b1000;

  always @(posedge clk)
  begin

    case(state)

    unpack:
    begin   
      if(input_a_stb)
      begin
        input_a_ack <= 1;
      end   
      if(input_b_stb)
      begin
        input_b_ack <= 1;
      end

      if(input_a_stb && input_b_stb)
      begin
        a_m <= input_a[22 : 0];
        b_m <= input_b[22 : 0];
        a_e <= input_a[30 : 23];
        b_e <= input_b[30 : 23];
        a_s <= input_a[31];
        b_s <= input_b[31];

        b_m [24:23] <= 2'b01;			//number =(s)^-1 (1+m) * 2^e
        a_m [24:23] <= 2'b01;			//number =(s)^-1 (1+m) * 2^e

	special_cases <= 0;
        
        state <= spec_case;
      end else
      begin
        state <= unpack;
      end
    end

    spec_case:
    begin
	input_a_ack <= 0;
	input_b_ack <= 0;
      //if a or b is zero
      if(a_e == 0 && a_m == 0)
      begin
        z_e <= b_e;
        z_m <= b_m;
        z_s <= b_s;
	special_cases <= 1;
      end else if(b_e == 0 && b_m == 0)
      begin
        z_e <= a_e;
        z_m <= a_m;
        z_s <= a_s;
	special_cases <= 1;
      end else

      //if a is infinity
      if(a_e == 8'b11111111 && a_m == 0)
      begin
        if(b_e == 8'b11111111 && b_m == 0)
        begin
	  if (a_s != b_s)
	  begin
            z_e <= 8'b11111111;
	    z_s <= 0;				// this number is not a number
	    z_m <= 23'b00000010000100010101010;
	    special_cases <= 1;
	  end else 
	  begin
	    z_e <= a_e;
            z_m <= a_m;
            z_s <= a_s; 
	    special_cases <= 1;
	  end
        end else
        begin
          z_e <= a_e;
          z_m <= a_m;
          z_s <= a_s;
	  special_cases <= 1;
        end
      // if b is infinity
      end else if(b_e == 8'b11111111 && b_m == 0)
      begin
        z_e <= b_e;
        z_m <= b_m;
        z_s <= b_s;
	special_cases <= 1;
      end else

      //if a or b is denormalaized
      if(a_e == 0 && a_m != 0)
      begin
        if(b_e == 0 && b_m !=0)
        begin
	   b_m [23] <= 0;			//number =(s)^-1 (0+m) * 2^e
   	   a_m [23] <= 0;			//number =(s)^-1 (0+m) * 2^e
        end else
        begin
           z_e <= b_e;
           z_m <= b_m;
           z_s <= b_s;
	   special_cases <= 1;
        end
      end else if(b_e == 0 && b_m !=0)
      begin  
        z_e <= a_e;
        z_m <= a_m;
        z_s <= a_s; 
	special_cases <= 1;
      end else 

      //not a number
      if(a_e == 8'b11111111 && a_m !=0)
      begin
        z_e <= a_e;
        z_m <= a_m;
        z_s <= a_s;
	special_cases <= 1;
      end else if(b_e == 8'b11111111 && b_m !=0)
      begin
        z_e <= b_e;
        z_m <= b_m;
        z_s <= b_s; 
	special_cases <= 1;
      end
	state <= align;
    end

    align:
    begin
	if (special_cases)
	begin
	  state <= done;
	end else
	begin
      //normalize both mantis
      if(a_e > b_e)			
      begin  
        b_m <= b_m >> (a_e - b_e);
        b_e <= a_e;
	z_e <= a_e;
      end else 
      begin     
        a_m <= a_m >> (b_e - a_e);
        a_e <= b_e;
	z_e <= b_e;
      end
      if(a_s == b_s)
      begin
        state <= same_sign;
      end else
      begin
        state <= un_same_sign;
      end  
	end
    end

    same_sign:
    begin

      z_m <= a_m + b_m;
      z_e <= a_e;
      z_s <= a_s;
      state <= normalize_same_sign;

    end

    normalize_same_sign:
    begin
      if(z_m[24])
      begin
        z_e <= z_e + 1;
        if(z[8])
        begin      
          z_e <= 8'b11111111;
	  z_s <= 0;				// this number is not a number
	  z_m <= 23'b00000010000100010101010;
        end else
	begin
          z_m <= z_m >> 1 ;
	end
      end
	state <= done;
    end

    un_same_sign:
    begin
      
      if(a_s)
      begin
        z_m <= b_m - a_m;
      end else
      begin
        z_m <= a_m - b_m;
	
      end
      state <= correct_twos_comp;
   
    end

    correct_twos_comp:
    begin

    //correct the sign and two's complement if it need
      
      if(z_m[24])
      begin
        z_s <= 1'b1;
        z_m <= (1 << 25) - z_m;		//two's complement 
      end else
      begin
        z_s <= 1'b0;
      end
      
      state <= normalize_unsame_sign;

    end

    normalize_unsame_sign:
    begin
      if(z_m[23] != 1)
      begin
         z_m <= z_m << 1;
         z_e <= z_e - 1;
         state <= normalize_unsame_sign;
      end else
      begin
         state <= done;
      end
    end   

    done:
    begin  
      output_z[31]    <= z_s;
      output_z[30:23] <= z_e[7:0];
      output_z[22:0]  <= z_m[22:0];
      output_z_stb    <= 1;
      state <= done;
      if(output_z_ack)
      begin
        input_a_ack <= 0;
        input_b_ack <= 0;
        output_z_stb <= 0 ;
        state <= unpack;
      end
    end     

    endcase

    if(rst)
    begin
      input_a_ack <= 0;
      input_b_ack <= 0;
      output_z_stb <= 0 ;
      output_z <= 0;
      state <= unpack;
    end
  end
endmodule