module hard_png_with_buffer (
    input wire rstn,
    input wire clk,
    input wire load,         // Signal to load data into the buffer
    input wire shift,        // Signal to shift data out of the buffer
    input wire istart,
    input wire [551:0] data_in,  // 336-bit input packet from NIC
    output wire [2:0] colortype,
    output wire [13:0] width,
    output wire [31:0] height,
    output wire [7:0] opixelr, opixelg, opixelb, opixela,
    output wire ovalid
);

    wire [7:0] ibyte;        // 8-bit data output from the buffer, connected to PNG decoder input
    wire iready, ivalid; // Control signals for the PNG decoder
    
    // Instantiate the buffer module
    buffer buffer_inst (
        .clk(clk),
        .rst(~rstn),          // Active-high reset in buffer, but active-low in PNG
        .load(load),          // Load signal for the buffer
        .shift(shift),        // Shift signal to shift out 8 bits
        .data_in(data_in),    // 336-bit data input from NIC
        .data_out(ibyte)      // 8-bit output to PNG decoder
    );

    // Instantiate the original PNG decoder
    hard_png hard_png_i (
        .rstn      (rstn),     // Reset
        .clk       (clk),      // Clock
        .istart    (istart),   // Start signal
        .ivalid    (ivalid),   // Input valid
        .iready    (iready),   // Ready for new data
        .ibyte     (ibyte),    // 8-bit data from the buffer
        // Image size outputs
        .ostart    (ostart),   // PNG decoder output start
        .colortype (colortype),
        .width     (width),
        .height    (height),
        // Decoded pixel data
        .ovalid    (ovalid),
        .opixelr   (opixelr),
        .opixelg   (opixelg),
        .opixelb   (opixelb),
        .opixela   (opixela)
    );

endmodule

