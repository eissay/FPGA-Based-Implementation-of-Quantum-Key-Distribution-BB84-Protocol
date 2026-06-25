`timescale 1ns/1ns

module Tb_BB84_QKD;

    reg clk;
    reg rst;
    reg start;
    reg enable_attack;
    
    wire done;
    wire intrusion_detected;
    wire [15:0] total_bits;
    wire [15:0] error_bits;

    Top_Module uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .enable_attack(enable_attack),
        .done(done),
        .intrusion_detected(intrusion_detected),
        .total_bits(total_bits),
        .error_bits(error_bits)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        start = 0;
        enable_attack = 0;

        // Wait 100 ns for global reset to finish
        #100;
        rst = 0;
        
        $display("=== Starting Test 1: Normal Operation (No Eve) ===");
        #10;
        start = 1;
        #10;
        start = 0; // Deassert start after one clock

        // Wait for session to complete
        wait(done == 1);
        #20;
        
        $display("Test 1 Completed.");
        $display("Total Shared Bits: %d", total_bits);
        $display("Error Bits: %d", error_bits);
        $display("Intrusion Detected: %b", intrusion_detected);
        if (intrusion_detected == 0)
            $display("Result: PASS (Key Accepted)");
        else
            $display("Result: FAIL");

        $display("--------------------------------------------------");
        
        // Reset for next test
        rst = 1;
        #50;
        rst = 0;
        #50;

        $display("=== Starting Test 2: Attack Operation (Eve Enabled) ===");
        enable_attack = 1;
        #10;
        start = 1;
        #10;
        start = 0;

        // Wait for session to complete
        wait(done == 1);
        #20;

        $display("Test 2 Completed.");
        $display("Total Shared Bits: %d", total_bits);
        $display("Error Bits: %d", error_bits);
        $display("Intrusion Detected: %b", intrusion_detected);
        if (intrusion_detected == 1)
            $display("Result: PASS (Intrusion Detected, Key Rejected)");
        else
            $display("Result: FAIL (Intrusion NOT Detected)");
            
        $display("--------------------------------------------------");
        $finish;
    end

endmodule
