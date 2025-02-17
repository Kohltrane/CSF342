`timescale 1ns/1ps
`include "reg32.v"


module PC(pc_out, pc_in, clk);
	output reg[4:0] pc_out;
	input [4:0] pc_in;
	input clk;
	
	always @(negedge clk) begin
		pc_out<=pc_in;
	end
endmodule

module instr_mem(instr,pc);
	output reg[31:0] instr;
	input [4:0] pc;
	
	reg [31:0] data[0:31];
	integer i;
	always @(*) begin
		initial begin
			for (i=0;i<32;i=i+1) data[i] = i;
		end
		instr=data[pc]
	end
endmodule

module data_mem(read_data, address, write_data, read, write);
	input [4:0] address;
	input [31:0] write_data;
	input read,write;
	output [31:0] read_data;
	
	reg [31:0] data [0:31];
	initial begin 
endmodule