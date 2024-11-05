`timescale 1ns / 1ps

module tb_rx_hash();

    // Parameters
    localparam DATA_WIDTH = 256;
    localparam KEEP_WIDTH = (DATA_WIDTH / 8);

    // Testbench signals
    reg clk = 0;
    reg rst = 0;
    reg [DATA_WIDTH-1:0] s_axis_tdata = 0;
    reg [KEEP_WIDTH-1:0] s_axis_tkeep = {KEEP_WIDTH{1'b1}};
    reg s_axis_tvalid = 0;
    reg s_axis_tlast = 0;
    reg [40*8-1:0] hash_key = 320'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
    wire [31:0] m_axis_hash;
    wire [3:0] m_axis_hash_type;
    wire m_axis_hash_valid;
    wire [31:0] m_axis_dest_ip;
    wire [15:0] m_axis_dest_port;
    wire [DATA_WIDTH-1:0] data_out;
    wire [KEEP_WIDTH-1:0] data_keep;
    wire data_valid;
    wire data_last;
    wire clk_out;
    wire rst_out;

    // Instantiate the rx_hash module
    rx_hash #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_WIDTH(KEEP_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tkeep(s_axis_tkeep),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .hash_key(hash_key),
        .m_axis_hash(m_axis_hash),
        .m_axis_hash_type(m_axis_hash_type),
        .m_axis_hash_valid(m_axis_hash_valid),
        .m_axis_dest_ip(m_axis_dest_ip),
        .m_axis_dest_port(m_axis_dest_port),
        .data_out(data_out),
        .clk_out(clk_out),
        .rst_out(rst_out),
        .data_keep(data_keep),
        .data_valid(data_valid),
        .data_last(data_last)
    );

    
    always #5 clk = ~clk; 

    initial begin
        clk = 0;
        rst = 1;
        s_axis_tdata = 0;
        s_axis_tkeep = 8'b0000000;
        s_axis_tvalid = 0;
        s_axis_tlast = 0;

        // Apply reset
        #20 rst = 0;
        
        // Start sending data
        s_axis_tvalid = 1;
        s_axis_tkeep = 8'b11111111;

        // Cycle 1
        s_axis_tdata = 256'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
        s_axis_tlast = 0;
        #10;

        // Cycle 2
        s_axis_tdata = 256'haaaa0016bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb89504E470D0A1A0Abbbb;
        s_axis_tlast = 0;
        #10;

        // Cycle 3
        s_axis_tdata = 256'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
        s_axis_tlast = 0;
        #10;
        
        s_axis_tlast=1;
        #10;
        
        // Cycle 4
        s_axis_tdata=256'hbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
        //data = 256'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
        s_axis_tlast = 0;
        #10;

        // Cycle 5
        s_axis_tdata = 256'hbbbb0015bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb89504E470D0A1A0Abbbb;
        //data = 256'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB;
        s_axis_tlast = 0;
        #10;
        
        // Cycle 6
        s_axis_tdata = 256'hbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
        s_axis_tlast = 0;
        #10;
        s_axis_tlast=1;
        #10;
       
        // Cycle 7
        s_axis_tdata = 256'hDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD;
        s_axis_tlast = 0;
        #10;
        

        // Cycle 8
        s_axis_tdata = 256'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
        s_axis_tlast = 0;
        #10;
        

        // Cycle 9
        s_axis_tdata = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        s_axis_tlast = 0;
        #10;
        s_axis_tlast=1;
        #10;
        #10;
        #10;
        #10;        
        $finish;
    end

endmodule
