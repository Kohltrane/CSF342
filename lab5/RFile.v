`include "reg32.v"
`include "flow.v"

module RegFile(input clk,reset,
               input[1:0] ReadReg1,ReadReg2,WriteReg,
               input[31:0] WriteData,
               input RegWrite,
               output [31:0] ReadData1,ReadData2);

    wire [3:0] reg_sel;
    //decoder2_4 D1(.register(reg_sel), .reg_no(ReadReg1));
    //decoder2_4 D2(.register(reg_sel), .reg_no(ReadReg2));
    decoder2_4 D(.register(reg_sel), .reg_no(WriteReg)); //for writing

    wire [31:0] data1,data2,data3,data4;
    wire [3:0] gated_clk;
    and (gated_clk[0],clk,RegWrite,reg_sel[0]);
    and (gated_clk[1],clk,RegWrite,reg_sel[1]);
    and (gated_clk[2],clk,RegWrite,reg_sel[2]);
    and (gated_clk[3],clk,RegWrite,reg_sel[3]);

    reg_32bit R1(.q(data1),.d(WriteData),.clk(gated_clk[0]),.reset(reset));
    reg_32bit R2(.q(data2),.d(WriteData),.clk(gated_clk[1]),.reset(reset));
    reg_32bit R3(.q(data3),.d(WriteData),.clk(gated_clk[2]),.reset(reset));
    reg_32bit R4(.q(data4),.d(WriteData),.clk(gated_clk[3]),.reset(reset));

    mux4_1 M1(.regData(ReadData1),.q1(data1),.q2(data2),.q3(data3),.q4(data4),.reg_no(ReadReg1)); //for reading
    mux4_1 M2(.regData(ReadData2),.q1(data1),.q2(data2),.q3(data3),.q4(data4),.reg_no(ReadReg2));
endmodule

module tb_rfile();
    reg clk,reset,RegWrite;
    reg[1:0] ReadReg1,ReadReg2,WriteReg;
    reg[31:0] WriteData;
    wire[31:0] ReadData1,ReadData2;

    always #5 clk=~clk;
    initial begin
        $monitor("time=%t, ReadReg1=%d, ReadReg2=%d, WriteReg=%d, RegWrite=%b, WriteData=%h, ReadData1=%h, ReadData2=%h",$time,ReadReg1,ReadReg2,WriteReg,RegWrite,WriteData,ReadData1,ReadData2);
        reset=0;
        clk=1; 
        #10 RegWrite=1'b1; ReadReg1=2'b00; ReadReg2=2'b01; WriteReg=2'b11; WriteData=32'h1000abcd;
        #10 RegWrite=1'b1; ReadReg1=2'b00; ReadReg2=2'b11; WriteReg=2'b01; WriteData=32'h1001abcd;
        #10 RegWrite=1'b1; ReadReg1=2'b11; ReadReg2=2'b01; WriteReg=2'b00; WriteData=32'h1011abcd;
        #10 RegWrite=1'b0; ReadReg1=2'b00; ReadReg2=2'b01;
        $finish;
    end
endmodule