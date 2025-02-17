`timescale 1us/1ns

module d_ff(q,d,clk,reset,enable);
    input d,clk,reset;
    output q;
    reg q;

    always @(negedge clk, negedge reset) begin
        if (!reset) q<=0;
		else if (enable) q<=d;
        else q<=q;
    end
endmodule

module reg_32bit(q,d,clk,reset,enable);
    output reg[31:0] q;
    input[31:0] d;
    input clk,reset,enable;

    genvar i;
    generate
        for (i=0;i<32;i=i+1) d_ff DFF(.q(q[i]),
                                .d(d[i]),
                                .clk(clk),
                                .reset(reset).
								.enable(enable);
    endgenerate 
endmodule

/* module tb32reg;
    reg [31:0] d;
    reg clk,reset;
    wire [31:0] q;
    reg_32bit R(q,d,clk,reset);
    
    always @(clk)
        #5 clk<=~clk;
    
    initial begin
        clk= 1'b1;
        reset=1'b0;//reset the register
        #20 reset=1'b1;
        #20 d=32'hAFAFAFAF;
        #200 $finish;
    end
endmodule
 */