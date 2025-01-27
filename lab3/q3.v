module dff(d,clr,clk,q);
	input d,clr,en;
	output q;
	
	always@ (posedge clk, negedge clr) begin
		if (~clr) q=0;
		else begin
			if (en) begin
				q<=d;
			end
		end
	end
endmodule

module FA(a,b,c_in,sum,c_out);
	input a,b,c_in;
	output sum,c_out;
	
	reg sum,c_out;
	
	always@(*) begin
		sum=a^b^c_in;
		c_out=(a & b) | (b & cin)  | (cin & a) ;
	end
endmodule
module shiftreg(EN, in, CLK, Q);
	parameter n = 4;
	input EN;
	input in;
	input CLK;
	output [n-1:0] Q;
	reg [n-1:0] Q;
	initial
		Q=4'd0;
	always @(posedge CLK)
	begin
		if (EN)
			Q={in,Q[n-1:1]};
	end
endmodule

module seq_adder(input clk, input clr, input en, 
			input[3:0] a, input[3:0] b, input c_in, 
			output [3:0]sum, output c_out);
	reg[3:0] sum; 
	wire x,y,z,s;
	assign wire in={b,a};
	dff ff(c_out,clr,clk,z);
	shiftreg A(en,s,clk,x);
	shiftreg B(en,
	
endmodule
