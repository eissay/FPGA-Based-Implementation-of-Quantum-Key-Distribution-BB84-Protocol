module Sifting_Logic (
    input wire clk,
    input wire rst,
    input wire alice_basis,
    input wire alice_data,
    input wire bob_basis,
    input wire bob_data,
    input wire valid_in,
    output reg sifted_alice_data,
    output reg sifted_bob_data,
    output reg key_valid
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sifted_alice_data <= 1'b0;
            sifted_bob_data <= 1'b0;
            key_valid <= 1'b0;
        end else if (valid_in) begin
            if (alice_basis == bob_basis) begin
                // Bases match, keep the data
                sifted_alice_data <= alice_data;
                sifted_bob_data <= bob_data;
                key_valid <= 1'b1;
            end else begin
                // Bases mismatch, discard
                key_valid <= 1'b0;
            end
        end else begin
            key_valid <= 1'b0;
        end
    end

endmodule
