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
	
/* module testbench;
	 reg x,y,z;
	 wire s,c;
	 FADDER fl(s,c,x,y,z);
	 initial
	 $monitor(,$time,"x=%b,y=%b,z=%b,s=%b,c=%b",x,y,z,s,c);
	 initial begin
		 #0 x=1'b0;y=1'b0;z=1'b0;
		 #4 x=1'b1;y=1'b0;z=1'b0;
		 #4 x=1'b0;y=1'b1;z=1'b0;
		 #4 x=1'b1;y=1'b1;z=1'b0;
		 #4 x=1'b0;y=1'b0;z=1'b1;
		 #4 x=1'b1;y=1'b0;z=1'b1;
		 #4 x=1'b0;y=1'b1;z=1'b1;
		 #4 x=1'b1;y=1'b1;z=1'b1;
	 end
endmodule */

module add8(input [7:0] x, input [7:0] y, output [7:0] sum, output [7:0] carry);
	FADDER fadd0(sum[0],carry[0],x[0],y[0],0);
	FADDER fadd1(sum[1],carry[1],x[1],y[1],carry[0]);
	FADDER fadd2(sum[2],carry[2],x[2],y[2],carry[1]);
	FADDER fadd3(sum[3],carry[3],x[3],y[3],carry[2]);
	FADDER fadd4(sum[4],carry[4],x[4],y[4],carry[3]);
	FADDER fadd5(sum[5],carry[5],x[5],y[5],carry[4]);
	FADDER fadd6(sum[6],carry[6],x[6],y[6],carry[5]);
	FADDER fadd7(sum[7],carry[7],x[7],y[7],carry[6]);
endmodule

module add32(input [31:0] x, input [31:0] y, output [31:0] sum, output [31:0] carry);
	add8 a32_0(x[7:0],y[7:0],sum[7:0],carry[7:0]);
	add8 a32_1(x[15:8],y[15:8],sum[15:8],carry[15:8]);
	add8 a32_2(x[23:16],y[23:16],sum[23:16],carry[23:16]);
	add8 a32_3(x[31:24],y[31:24],sum[31:24],carry[31:24]);
endmodule

module testbench;
	 reg[7:0] x,y;
	 wire[7:0] s,c;
	 add8 fl(x,y,s,c);
	 initial
	 $monitor(,$time,"x=%b,y=%b,s=%b,c=%b",x,y,s,c);
	 initial begin
		 #0 x=8'h00;y=8'h00;
		 #4 x=8'h5F;y=8'hA2;
		 #4 x=8'hAA;y=8'hBB;
	 end
endmodule