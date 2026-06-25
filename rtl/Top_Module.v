module Top_Module (
    input wire clk,
    input wire rst,
    input wire start,
    input wire enable_attack,
    output wire done,
    output wire intrusion_detected,
    output wire [15:0] total_bits,
    output wire [15:0] error_bits
);

    wire enable_alice;
    wire enable_bob;
    wire session_active;

    // Alice
    wire [1:0] alice_photon;
    wire alice_basis;
    wire alice_data;
    wire alice_valid;

    // Channel
    wire [1:0] channel_photon;
    wire channel_valid;

    // Eve
    wire [1:0] eve_photon;
    wire eve_valid;

    // Bob
    wire bob_basis;
    wire bob_data;
    wire bob_valid;

    // Sifting
    wire sifted_alice_data;
    wire sifted_bob_data;
    wire key_valid;

    // --- Module Instantiations ---

    Controller_FSM u_controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .enable_alice(enable_alice),
        .enable_bob(enable_bob),
        .session_active(session_active),
        .done(done)
    );

    Alice u_alice (
        .clk(clk),
        .rst(rst),
        .enable(enable_alice),
        .photon_state(alice_photon),
        .basis_out(alice_basis),
        .data_out(alice_data),
        .valid_out(alice_valid)
    );

    Quantum_Channel_Emulator u_channel (
        .clk(clk),
        .rst(rst),
        .photon_in(alice_photon),
        .valid_in(alice_valid),
        .photon_out(channel_photon),
        .valid_out(channel_valid)
    );

    Eve u_eve (
        .clk(clk),
        .rst(rst),
        .enable(enable_bob), // Eve works when system is active
        .enable_attack(enable_attack),
        .photon_in(channel_photon),
        .valid_in(channel_valid),
        .photon_out(eve_photon),
        .valid_out(eve_valid)
    );

    Bob u_bob (
        .clk(clk),
        .rst(rst),
        .enable(enable_bob),
        .photon_in(eve_photon),
        .valid_in(eve_valid),
        .basis_out(bob_basis),
        .data_out(bob_data),
        .valid_out(bob_valid)
    );

    // Wait, to perform sifting, we need Alice's basis and data.
    // However, Alice's basis and data are generated at cycle N.
    // They reach Sifting_Logic at cycle N+1 (since channel and Eve introduce delays? 
    // Actually, Alice outputs at N. Channel registers at N+1. Eve registers at N+2. Bob registers at N+3. 
    // The data arriving at Sifting_Logic from Bob is 3 cycles delayed relative to Alice's direct output.
    // We need to delay Alice's basis and data by 3 clock cycles to synchronize with Bob's output!
    // Let's create a shift register for synchronization.

    reg [2:0] alice_basis_delay;
    reg [2:0] alice_data_delay;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alice_basis_delay <= 3'b000;
            alice_data_delay <= 3'b000;
        end else begin
            alice_basis_delay <= {alice_basis_delay[1:0], alice_basis};
            alice_data_delay <= {alice_data_delay[1:0], alice_data};
        end
    end

    Sifting_Logic u_sifting (
        .clk(clk),
        .rst(rst),
        .alice_basis(alice_basis_delay[2]),
        .alice_data(alice_data_delay[2]),
        .bob_basis(bob_basis),
        .bob_data(bob_data),
        .valid_in(bob_valid),
        .sifted_alice_data(sifted_alice_data),
        .sifted_bob_data(sifted_bob_data),
        .key_valid(key_valid)
    );

    QBER_Analyzer u_qber (
        .clk(clk),
        .rst(rst),
        .alice_data(sifted_alice_data),
        .bob_data(sifted_bob_data),
        .key_valid(key_valid),
        .total_bits(total_bits),
        .error_bits(error_bits),
        .intrusion_detected(intrusion_detected)
    );

endmodule
