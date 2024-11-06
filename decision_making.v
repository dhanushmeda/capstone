`resetall
`timescale 1ns / 1ps
`default_nettype none

module decision_making #
(
    parameter DATA_WIDTH = 256,
    parameter KEEP_WIDTH = (DATA_WIDTH/8)
)
(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [DATA_WIDTH-1:0]  data,
    input  wire [KEEP_WIDTH-1:0]  data_keep,
    input  wire                   data_valid,
    input  wire                   data_last,
    input wire load,
    output wire load_out,   
    output reg  [DATA_WIDTH*3-433:0] data_out,
    output reg  [31:0]            dest_ip,
    output reg  [15:0]            dest_port,
    output reg                    decision
);

    reg [DATA_WIDTH*3-1:0] packet_reg;
    reg [1:0]              cycle_count;
    

    localparam [63:0] PNG_SIGNATURE = 64'h89504E470D0A1A0A;

    always @(posedge clk) begin
        if (rst) begin
            packet_reg <= 0;
            data_out <= 0;
            dest_ip <= 0;
            dest_port <= 0;
            decision <= 0;
            cycle_count <= 0;
        end else if (data_valid) begin
            data_out<=0;
            case (cycle_count)
                2'd0: packet_reg[DATA_WIDTH*3-1:DATA_WIDTH*2] <= data;
                2'd1: packet_reg[DATA_WIDTH*2-1:DATA_WIDTH] <= data;
                2'd2: packet_reg[DATA_WIDTH-1:0] <= data;
                
            endcase
            //$display("PAcket at cycle %d is %h",cycle_count, packet_reg);
            

            //cycle_count <= cycle_count + 1;
            //$display("Time: %0t | Cycle count: %d",$time,cycle_count);
            if (cycle_count == 3'd3 && data_last) begin
                //packet_reg[DATA_WIDTH-1:0] <= data;
                //$display("Time: %0t | packet_reg = %h", $time, packet_reg);
                dest_ip <= packet_reg[655:624];
                dest_port <= packet_reg[495:480];
                data_out <= packet_reg[335:0];
                decision <= packet_reg[335:272] == PNG_SIGNATURE;
                cycle_count <= 0;
                packet_reg<=0;
            end
            else 
                cycle_count <= cycle_count + 1;
        end
    end
    
    
    assign load_out = load;
    buffer buffer_inst (
        .clk(clk),
        .rst(rst),
        .load(load_out),
        .data_in(decision ? data_out : 'bz),  
        .ip(decision ? dest_ip : 'bz),     
        .port(16'd21)                      
    );

    host host_inst (
        .clk(clk),
        .rst(rst),
        .data(!decision ? data_out : 'bz), 
        .ip(!decision ? dest_ip : 'bz),    
        .port(!decision ? dest_port : 'bz) 
    );

endmodule

