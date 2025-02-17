`timescale 1us/1ns

module decoder2_4(register,reg_no);    
    output reg[3:0] register;
    input[1:0] reg_no;
    always@(reg_no) begin
        case (reg_no)
            2'b00: register=4'b0001;
            2'b01: register=4'b0010;
            2'b10: register=4'b0100;
            2'b11: register=4'b1000; 
            default: register=4'b0000;
        endcase
    end
endmodule

module mux4_1(regData,q1,q2,q3,q4,reg_no);
    output reg[31:0] regData;
    input[31:0] q1,q2,q3,q4;
    input[1:0] reg_no;

    always@(*) begin
        case (reg_no)
            2'b00: regData=q1;
            2'b01: regData=q2;
            2'b10: regData=q3;
            2'b11: regData=q4;
            default: regData=4'b0000;
        endcase
    end
endmodule

module mux32x1(regData,q,reg_no);
	output reg[31:0] regData;
	input [31:0] q [0:31];
	input [4:0] reg_no;
	
	always@ (*) begin
		regData=q[reg_no];
	end

endmodule

module tb();
	wire [31:0] out;
	reg [31:0] q[0:31];
	reg [4:0] reg_no;
	
	mux32x1 dut(out,q,reg_no);
	
	initial begin
		q[3]=32'd16;
		$display("reg_no=%d, out=%d", reg_no, out);
		#5 reg_no=5'd3;
		$finish;
	end
endmodule