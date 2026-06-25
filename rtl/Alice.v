module Alice (
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [1:0] photon_state,
    output reg basis_out,
    output reg data_out,
    output reg valid_out
);

    wire rand_basis;
    wire rand_data;

    // PRNG for Basis Selection
    PRNG_LFSR #(
        .SEED(8'hA5)
    ) lfsr_basis (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .rand_bit(rand_basis)
    );

    // PRNG for Data Generation
    PRNG_LFSR #(
        .SEED(8'h3C)
    ) lfsr_data (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .rand_bit(rand_data)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            photon_state <= 2'b00;
            basis_out <= 1'b0;
            data_out <= 1'b0;
            valid_out <= 1'b0;
        end else if (enable) begin
            basis_out <= rand_basis;
            data_out <= rand_data;
            // photon_state encoding:
            // 00 -> Horizontal
            // 01 -> Vertical
            // 10 -> Diagonal
            // 11 -> Anti-Diagonal
            photon_state <= {rand_basis, rand_data};
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
