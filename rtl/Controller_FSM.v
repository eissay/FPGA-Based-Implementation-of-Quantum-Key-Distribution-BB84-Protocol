module Controller_FSM (
    input wire clk,
    input wire rst,
    input wire start,
    output reg enable_alice,
    output reg enable_bob,
    output reg session_active,
    output reg done
);

    parameter IDLE = 2'b00;
    parameter RUNNING = 2'b01;
    parameter DONE = 2'b10;

    reg [1:0] state;
    reg [15:0] bit_counter;

    // Run for 1000 clock cycles
    parameter MAX_BITS = 16'd1000;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            enable_alice <= 1'b0;
            enable_bob <= 1'b0;
            session_active <= 1'b0;
            done <= 1'b0;
            bit_counter <= 16'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= RUNNING;
                        session_active <= 1'b1;
                        enable_alice <= 1'b1;
                        enable_bob <= 1'b1;
                        bit_counter <= 16'd0;
                    end
                end
                RUNNING: begin
                    if (bit_counter < MAX_BITS) begin
                        bit_counter <= bit_counter + 1'b1;
                    end else begin
                        state <= DONE;
                        enable_alice <= 1'b0;
                        enable_bob <= 1'b0;
                        session_active <= 1'b0;
                        done <= 1'b1;
                    end
                end
                DONE: begin
                    if (!start) begin
                        state <= IDLE; // Wait for start to be deasserted
                        done <= 1'b0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
