//`timescale 1us/1ns

module JKff(clk,J,K,en,Q);
	input clk,J,K,en;
	output Q;
	reg Q=1'b0;
	always@(posedge clk) begin
		if (en) begin
			Q<=(J&(~Q)) | (~K)&(Q);
		end
	end
endmodule

module counter(input clk,en,
				output [3:0] q);
	wire Qc,Qd;
	assign Qc=q[0]&q[1];
	assign Qd=q[2]&q[0]&q[1];
	JKff ff0(clk,1'b1,1'b1,en,q[0]);
	JKff ff1(clk,q[0],q[0],en,q[1]);
	JKff ff2(clk,Qc,Qc,en,q[2]);
	JKff ff3(clk,Qd,Qd,en,q[3]);

endmodule

module countertest();
	reg clk,en;
	wire[3:0] Q;
	
	counter S(clk,en,Q);
	initial en=1;
	always
		#4 clk=~clk;
	initial begin
		$monitor("time=%d EN=%b Q=%b\n",$time,en,Q);
		#0 clk=0;
		#100 $finish;
	end
endmodule

/*module JKtest;
	reg clk,J,K,en;
	wire q;
	JKff ff(clk,J,K,en,q);
	always #4 clk=~clk;
	initial begin
		$monitor("time=%d EN=%b Q=%b\n",$time,en,q);
		#0 clk=0;en=0;
		#4 en=1;J=1;K=1;
		#100 $finish;
	end
endmodule*/