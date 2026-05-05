`timescale 1ns/1ps

module tb_traffic;

reg clk;
reg rst;
reg [1:0] traffic_NS;
reg [1:0] traffic_EW;

wire [2:0] NS;
wire [2:0] EW;


traffic_controller uut (
    .clk(clk),
    .rst(rst),
    .traffic_NS(traffic_NS),
    .traffic_EW(traffic_EW),
    .NS(NS),
    .EW(EW)
);


always begin
    #5 clk = ~clk;
end


initial begin
    clk = 0;
    rst = 1;
    traffic_NS = 2'b00;
    traffic_EW = 2'b00;

    #10 rst = 0;

    // Low traffic
    #50;

    // Medium traffic NS
    traffic_NS = 2'b01;
    #100;

    // High traffic EW
    traffic_EW = 2'b10;
    #100;

    // Both high
    traffic_NS = 2'b10;
    traffic_EW = 2'b10;
    #100;

    $finish;
end


initial begin
    $monitor("Time=%0t | NS=%b | EW=%b | Traffic_NS=%b | Traffic_EW=%b",
              $time, NS, EW, traffic_NS, traffic_EW);
end

endmodule
