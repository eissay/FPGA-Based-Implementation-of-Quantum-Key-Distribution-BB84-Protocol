module Eve (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire enable_attack,
    input wire [1:0] photon_in,
    input wire valid_in,
    output reg [1:0] photon_out,
    output reg valid_out
);

    wire rand_basis;
    wire rand_measure;

    // PRNG for Eve's Basis Selection
    PRNG_LFSR #(
        .SEED(8'h55)
    ) lfsr_basis (
        .clk(clk),
        .rst(rst),
        .enable(enable && enable_attack),
        .rand_bit(rand_basis)
    );

    // PRNG for simulating random measurement when bases mismatch
    PRNG_LFSR #(
        .SEED(8'hAA)
    ) lfsr_measure (
        .clk(clk),
        .rst(rst),
        .enable(enable && enable_attack),
        .rand_bit(rand_measure)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            photon_out <= 2'b00;
            valid_out <= 1'b0;
        end else if (enable && valid_in) begin
            if (enable_attack) begin
                valid_out <= 1'b1;
                // Eve measures
                if (rand_basis == photon_in[1]) begin
                    // Basis match, Eve measures correct data
                    photon_out <= {rand_basis, photon_in[0]};
                end else begin
                    // Basis mismatch, Eve measures random data
                    photon_out <= {rand_basis, rand_measure};
                end
            end else begin
                // Transparent mode (no attack)
                photon_out <= photon_in;
                valid_out <= 1'b1;
            end
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
