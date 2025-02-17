module reg5bit(input [4:0] inp,	input clk, output [4:0] outp);
always @(posedge clk)	
	outp = inp;	
endmodule

module im(pc, instr, clk, reset);
	input clk, reset;
	input [4:0] pc;
	output [31:0] instr;
	reg [31:0][31:0] instr_memory;
	initial begin
	pc = 5'b00000;
	instr_memory[0] = 32'h00622020;
	instr_memory[1] = 32'h8C450BB8;
	instr_memory[2] = 32'h1009000A;
	instr_memory[3] = 32'h01A00008;
	instr_memory[4] = 32'h12345678;
	instr_memory[5] = 32'h98765432;
	instr_memory[6] = 32'hABCDABCD;
end
	always @(posedge clk, pc) begin
		if (reset)	instr = 32'b0;
		else	instr = instr_memory[pc];
	end
endmodule

module dm(addr, wr_data, rd_data, clk, reset, memwrite, memread);
	input clk, reset, memread, memwrite;
	input [31:0] wr_data;
	input [4:0] addr;
	output [31:0] rd_data;
	reg [31:0][31:0] data_memory;
	genvar j;
	generate for (j=0; j<32; j=j+1)
		assign data_memory[j] = 32'b0;
	endgenerate
	always @(posedge clk) begin
		if (reset) rd_data = 32'b0;
		else begin
			if (memread)	rd_data = data_memory[addr];
			else if (memwrite) data_memory[addr] = wr_data;
		end
	end
endmodule
//dm dm1(pc, wr_data, rd_data, clk, reset, memwrite, memread);

module mainCU ( RegDest, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1, op );
	input [5:0] op;
	output RegDest, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1;
	wire rformat, lw, sw, beq;

	assign rformat = ~(op[0] | op[1] | op[2] | op[3] | op[4] | op[5]);
	assign lw = (op[0] & op[1] & (~op[2]) & (~op[3]) & (~op[4]) & op[5]);
	assign sw = (op[0] & op[1] & (~op[2]) & op[3] & (~op[4]) & op[5]);
	assign beq = ((~op[0]) & (~op[1]) & op[2] & (~op[3]) & (~op[4]) & (~op[5]));
	assign RegDest = rformat;
	assign ALUSrc = lw | sw;
	assign MemToReg = lw;
	assign RegWrite = rformat | lw;
	assign MemRead = lw;
	assign MemWrite = sw;
	assign Branch = beq;
	assign ALUOp0 = rformat;
	assign ALUOp1 = beq;
endmodule
//mainCU mcu1(RegDest, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp0, ALUOp1, op);

module decoder_2to4(output reg [3:0] register, input [1:0] regNo);
always @(regNo) begin
    case (regNo)
    2'b00 : register = 4'b0001;
    2'b01 : register = 4'b0010;
    2'b10 : register = 4'b0100;
    2'b11 : register = 4'b1000;
    endcase
end
endmodule

module mux_4to1( output [31:0] regData, input [31:0] q0,input [31:0] q1,input [31:0] q2,input [31:0] q3,
        input [1:0] regNo);
reg regData;
always @(regNo) begin
    case (regNo)
    2'b00:  regData = q0;
    2'b01:  regData = q1;
    2'b10:  regData = q2;
    2'b11:  regData = q3;
    endcase
end
endmodule

module dff(q,d,clk,reset);
	input clk,d,reset;
	output reg q;
	always @(posedge clk or negedge reset)
	begin
		if (!reset) q <= 1'b0;
		else q <= d;
	end
endmodule

module reg32(q,d,clk,reset);
	input [31:0] d;
	input clk, reset;
	output [31:0] q;
	genvar j;
	generate for (j=0; j<32; j=j+1)
	begin: dff_loop
		dff d1(q[j],d[j],clk,reset);
	end
endgenerate
endmodule

module regFile(input clk,input reset,input [1:0] readReg1,input [1:0] readReg2,input [31:0] writeData, 
	input regWrite, input  [1:0] writeReg, output [31:0] readData1, output [31:0] readData2);
	genvar j;
	wire [3:0][31:0] regOut;
	reg [31:0] regIn;
	wire [3:0] decoderOut;
	wire [3:0] regClk;
	assign regClk[0] = (clk & regWrite & decoderOut[0]);
	assign regClk[1] = (clk & regWrite & decoderOut[1]);
	assign regClk[2] = (clk & regWrite & decoderOut[2]);
	assign regClk[3] = (clk & regWrite & decoderOut[3]);
	reg32 r0( regOut[0], regIn, regClk[0], reset );
	reg32 r1( regOut[1], regIn, regClk[1], reset );
	reg32 r2( regOut[2], regIn, regClk[2], reset );
	reg32 r3( regOut[3], regIn, regClk[3], reset );
	mux_4to1 m1( readData1, regOut[0] , regOut[1] , regOut[2], regOut[3], readReg1 );
	mux_4to1 m2( readData2, regOut[0] , regOut[1] , regOut[2] , regOut[3], readReg2 );
	decoder_2to4 dec1( decoderOut, writeReg );        
endmodule
//regfile rf1(clk, reset, readReg1, readReg2, writeData, regWrite, writeReg, readData1, readData2);

module alu32_cu(ff,aluop,oper);
	input [3:0] ff;
	input [1:0] aluop;
	output [2:0] oper;
    assign oper[0] = (ff[0] | ff[3]) & aluop[1];
    assign oper[1] = ((~aluop[1]) | (~ff[2]));
    assign oper[2] = (aluop[0] | ( aluop[1] & ff[1] ));
endmodule

module mux2to1(out,sel,in1,in2);
	input in1,in2;
	input sel;
	output out;
	assign out = sel ? in2 : in1;
endmodule

module bit8_2to1mux(out,sel,in1,in2);
	input [7:0] in1,in2;
	output [7:0] out;
	input sel;
	mux2to1 m0(out[0],sel,in1[0],in2[0]);
	mux2to1 m1(out[1],sel,in1[1],in2[1]);
	mux2to1 m2(out[2],sel,in1[2],in2[2]);
	mux2to1 m3(out[3],sel,in1[3],in2[3]);
	mux2to1 m4(out[4],sel,in1[4],in2[4]);
	mux2to1 m5(out[5],sel,in1[5],in2[5]);
	mux2to1 m6(out[6],sel,in1[6],in2[6]);
	mux2to1 m7(out[7],sel,in1[7],in2[7]);
endmodule 

module bit32_2to1mux(out,sel,in1,in2);
	input [31:0] in1,in2;
	output [31:0] out;
	input sel;
	bit8_2to1mux m80(out[7:0],sel,in1[7:0],in2[7:0]);
	bit8_2to1mux m81(out[15:8],sel,in1[15:8],in2[15:8]);
	bit8_2to1mux m82(out[23:16],sel,in1[23:16],in2[23:16]);
	bit8_2to1mux m83(out[31:24],sel,in1[31:24],in2[31:24]);
endmodule

module mux3to1(out,sel,in1,in2,in3);
	input in1,in2,in3;
	input [1:0] sel;
	output out;
	assign out = sel[1] ? (sel[0] ? 1'bz : in3) : (sel[0] ? in2 : in1);
endmodule

module bit8_3to1mux(out,sel,in1,in2,in3);
	input [7:0] in1,in2,in3;
	output [7:0] out;
	input [1:0] sel;
	mux3to1 m0(out[0],sel,in1[0],in2[0],in3[0]);
	mux3to1 m1(out[1],sel,in1[1],in2[1],in3[1]);
	mux3to1 m2(out[2],sel,in1[2],in2[2],in3[2]);
	mux3to1 m3(out[3],sel,in1[3],in2[3],in3[3]);
	mux3to1 m4(out[4],sel,in1[4],in2[4],in3[4]);
	mux3to1 m5(out[5],sel,in1[5],in2[5],in3[5]);
	mux3to1 m6(out[6],sel,in1[6],in2[6],in3[6]);
	mux3to1 m7(out[7],sel,in1[7],in2[7],in3[7]);
endmodule 

module bit32_3to1mux(out,sel,in1,in2,in3);
	input [31:0] in1,in2,in3;
	output [31:0] out;
	input [1:0] sel;
	bit8_3to1mux m80(out[7:0],sel,in1[7:0],in2[7:0],in3[7:0]);
	bit8_3to1mux m81(out[15:8],sel,in1[15:8],in2[15:8],in3[15:8]);
	bit8_3to1mux m82(out[23:16],sel,in1[23:16],in2[23:16],in3[23:16]);
	bit8_3to1mux m83(out[31:24],sel,in1[31:24],in2[31:24],in3[31:24]);
endmodule

module bit32and (out,in1,in2);
	input [31:0] in1,in2;
	output [31:0] out;
	assign {out}=in1 &in2;
endmodule

module bit32or (out,in1,in2);
	input [31:0] in1,in2;
	output [31:0] out;
	assign {out}=in1 | in2;
endmodule

module FA_32 (Cout, Sum,In1,In2,Cin);
 input [31:0] In1,In2;
 input Cin;
 output Cout;
 output [31:0] Sum;
 assign {Cout,Sum}=In1+In2+Cin;
endmodule

module alu32(a,b,cin,binv,oper,result,cout);
input [31:0] a,b;
input cin,binv;
input [1:0] oper;
output [31:0] result;
output cout; 
wire [31:0] bbar, b_sel_bbar, a_and_b, a_or_b, a_addsub_b; 
    assign bbar = ~b;
    bit32_2to1mux mux2to1_op(b_sel_bbar, binv, b, bbar );
    bit32and and_op( a_and_b, a, b_sel_bbar );
    bit32or or_op( a_or_b, a, b_sel_bbar );
    FA_32 fa_outp(cout, a_addsub_b, a, b_sel_bbar, cin );
    bit32_3to1mux mux3to1_op( result, oper , a_and_b, a_or_b, a_addsub_b);
endmodule
//alu32_cu alucu1(instr[3:0],[ALUOp1,ALUOp0],oper);
//alu32 alu1(readData1,readData2,oper[2],oper[1:0],result,cout);

module SCDatapath(input reset);
	reg clk;
	reg [4:0] pcOut;
	reg5bit pc( 5'b0, clk, pcOut );
	im instrMem( pc, reset , instr );
endmodule

module signExt(input [15:0] inp,output [31:0] seOutp);	
assign seOutp = {{16{inp[15]}},inp[15:0]};	
endmodule

module shifter(input [31:0] inp,output [31:0] outp);
assign outp = {inp[29:0],2'b00};
endmodule


module tb_scdatapath;
reg reset;
SCDatapath scd1(reset);
initial begin 
$dumpfile("tb_scdatapath.vcd");
$dumpvars;
end
initial $monitor ($time," reset=%b, clk=%b, pcOut=%b, instr=%b", reset, scd1.clk, scd1.pcOut, scd1.instr);
initial begin
	reset = 1;
	#10 reset = 0;
	#100 $finish;
end
endmodule