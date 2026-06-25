module PRNG_LFSR #(
    parameter SEED = 8'hA5
)(
    input wire clk,
    input wire rst,
    input wire enable,
    output wire rand_bit
);

    reg [7:0] lfsr_reg;
    wire feedback;

    // Polynomial for 8-bit LFSR: x^8 + x^6 + x^5 + x^4 + 1
    assign feedback = lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3];
    assign rand_bit = lfsr_reg[0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr_reg <= SEED;
        end else if (enable) begin
            lfsr_reg <= {lfsr_reg[6:0], feedback};
        end
    end

endmodule
