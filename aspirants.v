`timescale 1ns/1ps
module traffic_controller (
    input clk,
    input rst,
    input [1:0] traffic_NS,  // 00 = low, 01 = medium, 10 = high
    input [1:0] traffic_EW,
    
    output reg [2:0] NS, // {R, Y, G}
    output reg [2:0] EW
);

// States
parameter S_NS_GREEN  = 2'b00,
          S_NS_YELLOW = 2'b01,
          S_EW_GREEN  = 2'b10,
          S_EW_YELLOW = 2'b11;

reg [1:0] state, next_state;
reg [3:0] timer;

// Adaptive timing
reg [3:0] green_time_NS, green_time_EW;

// Traffic based timing
always @(*) begin
    case(traffic_NS)
        2'b00: green_time_NS = 4'd5;   // low
        2'b01: green_time_NS = 4'd8;   // medium
        2'b10: green_time_NS = 4'd12;  // high
        default: green_time_NS = 4'd5;
    endcase

    case(traffic_EW)
        2'b00: green_time_EW = 4'd5;
        2'b01: green_time_EW = 4'd8;
        2'b10: green_time_EW = 4'd12;
        default: green_time_EW = 4'd5;
    endcase
end

// State register
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_NS_GREEN;
        timer <= 0;
    end else begin
        state <= next_state;
        timer <= timer + 1;
    end
end

// Next state logic
always @(*) begin
    case(state)
        S_NS_GREEN:
            if (timer >= green_time_NS)
                next_state = S_NS_YELLOW;
            else
                next_state = S_NS_GREEN;

        S_NS_YELLOW:
            if (timer >= 3)
                next_state = S_EW_GREEN;
            else
                next_state = S_NS_YELLOW;

        S_EW_GREEN:
            if (timer >= green_time_EW)
                next_state = S_EW_YELLOW;
            else
                next_state = S_EW_GREEN;

        S_EW_YELLOW:
            if (timer >= 3)
                next_state = S_NS_GREEN;
            else
                next_state = S_EW_YELLOW;

        default: next_state = S_NS_GREEN;
    endcase
end

// Reset timer when state changes
always @(posedge clk or posedge rst) begin
    if (rst)
        timer <= 0;
    else if (state != next_state)
        timer <= 0;
end

// Output logic
always @(*) begin
    case(state)
        S_NS_GREEN: begin
            NS = 3'b001; // Green
            EW = 3'b100; // Red
        end

        S_NS_YELLOW: begin
            NS = 3'b010; // Yellow
            EW = 3'b100; // Red
        end

        S_EW_GREEN: begin
            NS = 3'b100; // Red
            EW = 3'b001; // Green
        end

        S_EW_YELLOW: begin
            NS = 3'b100; // Red
            EW = 3'b010; // Yellow
        end

        default: begin
            NS = 3'b100;
            EW = 3'b100;
        end
    endcase
end

endmodule
