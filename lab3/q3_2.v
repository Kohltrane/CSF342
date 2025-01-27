module serial_adder(
    input clk,           // Clock input
    input rst,           // Reset input (active high)
    input start,         // Start signal to begin addition
    input [3:0] A,       // 4-bit input operand A
    input [3:0] B,       // 4-bit input operand B
    output reg [3:0] sum, // 4-bit sum output
    output reg done      // Done signal when addition is complete
);
    reg [3:0] A_reg, B_reg;  // Shift registers for operands
    reg carry;               // Carry bit
    reg [1:0] count;         // Counter to track the number of bits added
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 4'b0;
            B_reg <= 4'b0;
            sum <= 4'b0;
            carry <= 0;
            count <= 0;
            done <= 0;
        end
        else if (start) begin
            if (count < 4) begin
                // Add the current bits from A_reg and B_reg along with carry
                {carry, sum[count]} <= A_reg[0] + B_reg[0] + carry;

                // Shift A and B operands to the right
                A_reg <= {1'b0, A_reg[3:1]};
                B_reg <= {1'b0, B_reg[3:1]};

                // Increment the counter
                count <= count + 1;
                done <= 0;  // Not done yet
            end else begin
                done <= 1;  // Done after 4 bits are added
            end
        end
    end
endmodule

module serial_adder_tb;
    reg clk;
    reg rst;
    reg start;
    reg [3:0] A, B;
    wire [3:0] sum;
    wire done;
    
    // Instantiate the serial adder module
    serial_adder uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .sum(sum),
        .done(done)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;  // Clock period of 10 time units
    end
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        rst = 0;
        start = 0;
        A = 4'b1101;  // Operand A = 13
        B = 4'b1011;  // Operand B = 11
        
        // Apply reset
        rst = 1;
        #10 rst = 0;
        
        // Start the addition
        start = 1;
        #10 start = 0;  // Pulse the start signal
        
        // Monitor the sum and done signals
        $monitor("time=%0d, A=%b, B=%b, sum=%b, done=%b", $time, A, B, sum, done);
        
        // Wait for the addition to complete
        #100;  // Give enough time for the serial adder to complete
        
        // Stop simulation
        $finish;
    end
endmodule
