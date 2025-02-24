`timescale 1ns/1ps
/*Main controller for MIPS multicycle implementation. 
The controller has 10 states. The controller has 16 outputs + 4 next state signals. It has a total of 10 inputs (6 opcode bits + 4 present state bits).
Write a test bench to check the controller for LW instruction*/
module controller(
input [5:0] op,
input [3:0] S,
output [3:0] NS,
output PCWrite,
output PCWriteCond,
output IorD,
output MemRead,
output MemWrite,
output IRWrite,
output MemtoReg,
output [1:0] PCsource,
output [1:0] ALUOp,
output [1:0] ALUsrcB,
output ALUsrcA,
output RegWrite,
output RegDst);

assign PCWrite = (~S[3]&~S[2]&~S[1]&~S[0]) | (S[3]&~S[2]&~S[1]&S[0]);
assign PCWriteCond = S[3]&~S[2]&~S[1]&~S[0];
assign IorD = (~S[3]&~S[2]&S[1]&S[0]) | (~S[3]&S[2]&~S[0]&S[0]);
assign MemRead = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&S[1]&S[0]);
assign MemWrite = (~S[3]&S[2]&~S[0]&S[0]);
assign IRWrite = (~S[3]&~S[2]&~S[1]&~S[0]);
assign MemtoReg = ~S[3]&~S[2]&~S[1]&~S[0];
assign PCsource[1] = S[3]&~S[2]&~S[1]&S[0];
assign PCsource[0] = S[3]&~S[2]&~S[1]&~S[0];
assign ALUOp[1] = ~S[3]&S[2]&S[1]&~S[0];
assign ALUOp[0] = S[3]&~S[2]&~S[1]&~S[0];
assign ALUsrcB[1] = (~S[3]&~S[2]&S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]);
assign ALUsrcB[0] = (~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&~S[2]&~S[1]&~S[0]);
assign ALUsrcA = (~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&S[2]&S[1]&~S[0]) |(S[3]&~S[2]&~S[1]&~S[0]);
assign RegWrite = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&S[2]&S[1]&S[0]);
assign RegDst = ~S[3]&S[2]&S[1]&S[0];
assign NS[3] = (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0]) | (~op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0]&~S[3]&~S[2]&~S[1]&S[0]);
assign NS[2] = (~S[3]&~S[2]&S[1]&S[0]) | (~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0]&~S[3]&~S[2]&~S[1]&S[0]) | (op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0]&~S[3]&~S[2]&S[1]&~S[0]);
assign NS[1] = (~S[3]&S[2]&S[1]&~S[0]) | (~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0]&~S[3]&~S[2]&~S[1]&S[0])  | (op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0]&~S[3]&~S[2]&~S[1]&S[0]) | (op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0]&~S[3]&~S[2]&~S[1]&S[0]) | (op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0]&~S[3]&~S[2]&S[1]&~S[0]) ;  
assign NS[0] = (~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&S[2]&S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]&~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0]) | (op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0]&~S[3]&~S[2]&S[1]&~S[0]) | (op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0]&~S[3]&~S[2]&S[1]&~S[0]); 
endmodule


module tb();
    reg [5:0] op;
    reg [3:0] S;
    wire [3:0] NS;
    wire PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, MemtoReg;
    wire [1:0] PCsource, ALUOp, ALUsrcB;
    wire ALUsrcA, RegWrite, RegDst;

    controller dut (
        .op(op),
        .S(S),
        .NS(NS),
        .PCWrite(PCWrite),
        .PCWriteCond(PCWriteCond),
        .IorD(IorD),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .IRWrite(IRWrite),
        .MemtoReg(MemtoReg),
        .PCsource(PCsource),
        .ALUOp(ALUOp),
        .ALUsrcB(ALUsrcB),
        .ALUsrcA(ALUsrcA),
        .RegWrite(RegWrite),
        .RegDst(RegDst)
    );

    initial begin
        // Initialize inputs
        op = 6'b100011; // LW opcode
        S = 4'b0000;   // Initial state

        // Monitor outputs
        $monitor("Time=%0t, S=%b, NS=%b, PCWrite=%b, PCWriteCond=%b, IorD=%b, MemRead=%b, MemWrite=%b, IRWrite=%b, MemtoReg=%b, PCsource=%b, ALUOp=%b, ALUsrcB=%b, ALUsrcA=%b, RegWrite=%b, RegDst=%b",
                 $time, S, NS, PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCsource, ALUOp, ALUsrcB, ALUsrcA, RegWrite, RegDst);

        // Simulate LW instruction states
        #10; S = NS; // State 1
        #10; S = NS; // State 2
        #10; S = NS; // State 3
        #10; S = NS; // State 4
        #10; S = NS; // State 5

        // Finish simulation
        #10; $finish;
    end
endmodule