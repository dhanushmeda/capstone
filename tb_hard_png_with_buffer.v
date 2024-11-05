/*`timescale 1ps/1ps

module tb_hard_png_with_buffer();

// Clock and Reset
reg clk;
reg rstn;
always #5 clk = ~clk;  // 100MHz clock (10ns period)

initial begin
    clk = 0;
    rstn = 0;
    #20 rstn = 1;  // Reset deasserted after 20ns
end

// Buffer Control Signals
reg load;
reg shift;
reg [551:0] data_in;   // 336-bit input data (simulating a NIC packet)
reg istart;

// Output signals from PNG decoder
wire [2:0] colortype;
wire [13:0] width;
wire [31:0] height;
wire [7:0] opixelr, opixelg, opixelb, opixela;
wire ovalid;

// Instantiate the PNG decoder with buffer
hard_png_with_buffer uut (
    .rstn(rstn),
    .clk(clk),
    .load(load),
    .shift(shift),
    .istart(istart),
    .data_in(data_in),
    .colortype(colortype),
    .width(width),
    .height(height),
    .opixelr(opixelr),
    .opixelg(opixelg),
    .opixelb(opixelb),
    .opixela(opixela),
    .ovalid(ovalid)
);

// Test procedure
initial begin
    // Initialize signals
    load = 0;
    shift = 0;
    data_in = 552'h0;  // Clear the data_in
    
    // Apply reset
    #20;
    
    
    
    // Simulate a packet being received from NIC (336-bit data)
    data_in = 552'h89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000C4944415408D763F8CFC000000301010018DD8DB00000000049454E44AE426082;
;
    istart <= 1'b1;
    @ (posedge clk);
    istart <= 1'b0;

    // Load data into buffer
    load = 1;
    #10;
    load = 0;

    // Start shifting data from the buffer to the PNG decoder
    repeat(42) begin  // 336 bits / 8 bits = 42 shifts
        shift = 1;
        #10;
        shift = 0;
        //#10;
        $display("Time: %t, ibyte shifted to PNG decoder: %h", $time, uut.buffer_inst.data_out);  // Display the 8-bit output from the buffer
    end

    // Wait for PNG decoder output
    wait (ovalid);
    $display("PNG decode result: Colortype = %d, Width = %d, Height = %d", colortype, width, height);
    $display("Pixel Data: R = %h, G = %h, B = %h, A = %h", opixelr, opixelg, opixelb, opixela);
    
    #100;
    $finish;
end

// Dump waveform
initial begin
    $dumpfile("tb_hard_png_with_buffer.vcd");
    $dumpvars(0, tb_hard_png_with_buffer);
end

endmodule
*/

`timescale 1ps/1ps

module tb_hard_png_with_buffer();

    // Clock and Reset
    reg clk;
    reg rstn;
    always #5 clk = ~clk;  // 100MHz clock (10ns period)

    initial begin
        clk = 0;
        rstn = 0;
        #20 rstn = 1;  // Reset deasserted after 20ns
    end

    // Test Inputs for Buffer and PNG Decoder
    reg load;                  // Load signal for buffer
    reg shift;                 // Shift signal for buffer
    reg [551:0] data_in;       // 552-bit input data (simulating a NIC packet, padded to align)
    reg istart;                // Start signal for PNG decoder

    // Outputs from PNG Decoder
 
    wire [2:0] colortype;      // PNG color type
    wire [13:0] width;         // PNG width
    wire [31:0] height;        // PNG height
    wire [7:0] opixelr, opixelg, opixelb, opixela; // Decoded pixel data
    wire ovalid;               // Valid output data
    wire iready;               // PNG decoder ready signal
    wire [7:0] ibyte;          // Data shifted from buffer to PNG decoder

    // Instantiate the hard_png_with_buffer module
    hard_png_with_buffer uut (
        .rstn(rstn),
        .clk(clk),
        .load(load),
        .shift(shift),
        .istart(istart),
        .data_in(data_in),
        .colortype(colortype),
        .width(width),
        .height(height),
        .opixelr(opixelr),
        .opixelg(opixelg),
        .opixelb(opixelb),
        .opixela(opixela),
        .ovalid(ovalid),
        .iready(iready)
    );

    // Test Sequence
    initial begin
        // Initialize signals
        load = 0;
        shift = 0;
        data_in = 552'h0;   // Clear the input data
        istart = 0;

        // Apply reset
        #20;

        // Load a valid PNG header and data chunk to simulate a packet from NIC
        data_in = 552'h89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000C4944415408D763F8CFC000000301010018DD8DB00000000049454E44AE426082;

        // Step 1: Load data into buffer
        load = 1;
        #10;
        load = 0;

        // Step 2: Trigger start of PNG decoding process
        istart = 1;
        #10;
        istart = 0;

        // Step 3: Shift data from buffer to PNG decoder in sync with `iready`
        repeat (69) begin  // 552 bits / 8 bits = 69 shifts
            if (iready) begin
                shift = 1;
                #10;
                shift = 0;
                #10;
                $display("Time: %t, ibyte shifted to PNG decoder: %h", $time, ibyte);  // Display each 8-bit output
            end else begin
                // Wait until PNG decoder signals it's ready
                #10;
            end
        end

        // Step 4: Wait for PNG decoder to complete decoding and assert valid output
        wait (ovalid);
        #10;
        $display("PNG decode result: Colortype = %d, Width = %d, Height = %d", colortype, width, height);
        $display("Pixel Data: R = %h, G = %h, B = %h, A = %h", opixelr, opixelg, opixelb, opixela);

        #100;
        $finish;
    end

    // Dump waveform for post-simulation analysis
    initial begin
        $dumpfile("tb_hard_png_with_buffer.vcd");
        $dumpvars(0, tb_hard_png_with_buffer);
    end

endmodule


/*`timescale 1ps/1ps

module tb_hard_png_with_buffer;

// Clock and Reset
reg clk;
reg rstn;
always #5 clk = ~clk;  // 100MHz clock (10ns period)

initial begin
    clk = 0;
    rstn = 0;
    #20 rstn = 1;  // Reset deasserted after 20ns
end

// Control Signals
reg load;
reg shift;
reg istart;
reg [551:0] data_in;   // 336-bit input data (simulating a NIC packet)

// Output signals from PNG decoder
wire [2:0] colortype;
wire [13:0] width;
wire [31:0] height;
wire [7:0] opixelr, opixelg, opixelb, opixela;
wire ovalid;

// Additional control signals for handshake
wire iready;   // PNG decoder's ready signal
reg ivalid;    // Valid signal for PNG data input
wire [7:0] ibyte;  // 8-bit data output from buffer

// Instantiate the PNG decoder with buffer
hard_png_with_buffer uut (
    .rstn(rstn),
    .clk(clk),
    .load(load),
    .shift(shift),
    .istart(istart),
    .data_in(data_in),
    .colortype(colortype),
    .width(width),
    .height(height),
    .opixelr(opixelr),
    .opixelg(opixelg),
    .opixelb(opixelb),
    .opixela(opixela),
    .ovalid(ovalid)
);

// Test procedure
initial begin
    // Initialize signals
    load = 0;
    shift = 0;
    ivalid = 0;
    data_in = 552'h0;  // Clear the data_in
    
    // Apply reset
    #20;
    
    // Load valid PNG data into buffer (assuming it's a minimal, valid PNG image header and IDAT chunk)
    data_in = 552'h89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000C4944415408D763F8CFC000000301010018DD8DB00000000049454E44AE426082;
    
    // Send start signal
    istart = 1;
    @(posedge clk);
    istart = 0;

    // Load data into buffer
    load = 1;
    #10;
    load = 0;

    // Shift data from the buffer into the PNG decoder
    // Loop for 42 shifts (336 bits / 8 bits = 42 bytes)
    repeat(42) begin
        if (iready) begin
            shift = 1;
            ivalid = 1;
            #10;
            shift = 0;
            ivalid = 0;
            @(posedge clk);
            $display("Time: %t, ibyte shifted to PNG decoder: %h", $time, ibyte);  // Display the 8-bit output from the buffer
        end else begin
            @(posedge clk);  // Wait until iready is high
        end
    end

    // Wait for PNG decoder to produce output
    wait (ovalid);
    $display("PNG decode result: Colortype = %d, Width = %d, Height = %d", colortype, width, height);
    $display("Pixel Data: R = %h, G = %h, B = %h, A = %h", opixelr, opixelg, opixelb, opixela);
    
    #100;
    $finish;
end

// Dump waveform for debugging
initial begin
    $dumpfile("tb_hard_png_with_buffer.vcd");
    $dumpvars(0, tb_hard_png_with_buffer);
end

endmodule
*/

