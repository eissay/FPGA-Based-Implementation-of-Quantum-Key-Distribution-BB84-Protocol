module Quantum_Channel_Emulator (
    input wire clk,
    input wire rst,
    input wire [1:0] photon_in,
    input wire valid_in,
    output reg [1:0] photon_out,
    output reg valid_out
);

    // Simple 1-cycle delay to emulate transmission time over the channel
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            photon_out <= 2'b00;
            valid_out <= 1'b0;
        end else begin
            photon_out <= photon_in;
            valid_out <= valid_in;
        end
    end

endmodule
