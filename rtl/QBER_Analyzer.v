module QBER_Analyzer (
    input wire clk,
    input wire rst,
    input wire alice_data,
    input wire bob_data,
    input wire key_valid,
    output reg [15:0] total_bits,
    output reg [15:0] error_bits,
    output wire intrusion_detected
);

    // QBER Threshold ~ 12.5% (1/8)
    // If error_bits > total_bits / 8, then intrusion detected
    assign intrusion_detected = (total_bits > 16'd16) ? ((error_bits * 8) > total_bits) : 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            total_bits <= 16'd0;
            error_bits <= 16'd0;
        end else if (key_valid) begin
            total_bits <= total_bits + 1'b1;
            if (alice_data != bob_data) begin
                error_bits <= error_bits + 1'b1;
            end
        end
    end

endmodule
