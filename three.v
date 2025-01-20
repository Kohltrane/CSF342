module DECODER(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
	input x,y,z;
	output d0,d1,d2,d3,d4,d5,d6,d7;
	wire x0,y0,z0;
	not n1(x0,x);
	not n2(y0,y);
	not n3(z0,z);
	and a0(d0,x0,y0,z0);
	and a1(d1,x0,y0,z);
	and a2(d2,x0,y,z0);
	and a3(d3,x0,y,z);
	and a4(d4,x,y0,z0);
	and a5(d5,x,y0,z);
	and a6(d6,x,y,z0);
	and a7(d7,x,y,z);
endmodule

module FADDER(s,c,x,y,z);
	input x,y,z;
	wire d0,d1,d2,d3,d4,d5,d6,d7;
	output s,c;
	DECODER dec(d0,d1,d2,d3,d4,d5,d6,d7,x,y,z);
	assign s = d1 | d2 | d4 | d7,
	 c = d3 | d5 | d6 | d7;
endmodule

module ADDSUB(s,c,x,y,M,V);
	input [3:0] x,y;
	input M;
	output [3:0] s,c;
	output V;
	wire[3:0] xor_y;
	assign xor_y=y^{4{M}};

	FADDER f0(s[0],c[0],x[0],xor_y[0],M);
	FADDER f1(s[1],c[1],x[1],xor_y[1],c[0]);
	FADDER f2(s[2],c[2],x[2],xor_y[2],c[1]);
	FADDER f3(s[3],c[3],x[3],xor_y[3],c[2]);
	
	assign V=c[3]^c[2];
	
endmodule

module testbench();
	reg[3:0] x,y;
	reg M;
	wire[3:0] s,c;
	wire V;
	ADDSUB addsub(s,c,x,y,M,V);
	initial $monitor(,$time,"x=%b,y=%b,M=%b,s=%b,c=%b,V=%b",x,y,M,s,c,V);
	initial begin
		#0 x=4'h0;y=4'h0;M=1'b0;
		#4 x=4'h1;y=4'hA;M=1'b0;
		#4 x=4'h9;y=4'h3;M=1'b0;
		#4 x=4'h1;y=4'hA;M=1'b1;
		#4 x=4'hB;y=4'h5;M=1'b1;
	end
endmodule