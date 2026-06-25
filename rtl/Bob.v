module Bob (
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [1:0] photon_in,
    input wire valid_in,
    output reg basis_out,
    output reg data_out,
    output reg valid_out
);

    wire rand_basis;
    wire rand_measure;

    // PRNG for Bob's Basis Selection
    PRNG_LFSR #(
        .SEED(8'h81)
    ) lfsr_basis (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .rand_bit(rand_basis)
    );

    // PRNG for simulating random measurement when bases mismatch
    PRNG_LFSR #(
        .SEED(8'hD4)
    ) lfsr_measure (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .rand_bit(rand_measure)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            basis_out <= 1'b0;
            data_out <= 1'b0;
            valid_out <= 1'b0;
        end else if (enable && valid_in) begin
            basis_out <= rand_basis;
            valid_out <= 1'b1;

            // photon_in[1] is Alice's basis, photon_in[0] is Alice's data
            // In reality Bob doesn't know Alice's basis, he measures the photon 
            // according to his basis. If the basis matches, measurement is deterministic.
            // If the basis mismatches, measurement is random.
            if (rand_basis == photon_in[1]) begin
                data_out <= photon_in[0]; // Deterministic measurement
            end else begin
                data_out <= rand_measure; // Unpredictable measurement
            end
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
