`timescale 1ns / 1ps

module host 
(
    input wire clk,
    input wire rst,
    input wire [335:0] data,
    input wire [31:0] ip,
    input wire [15:0] port,
    output reg [335:0] data_out
);

always @(posedge clk) begin

    $display("Packet is %h", data);
    $display("IP is %h", ip);
    
end

endmodule
