`timescale 1ns / 1ps

/*module tb_buffer;

    // Testbench signals
    reg clk;
    reg rst;
    reg [255:0] data;
    reg [31:0] ip;
    reg [15:0] port;
    wire [7:0] data_out;
    wire istart;
    wire ivalid;

    // Instantiate the buffer module
    buffer uut (
        .clk(clk),
        .rst(rst),
        .data(data),
        .ip(ip),
        .port(port),
        .data_out(data_out),
        .istart(istart),
        .ivalid(ivalid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize inputs
        rst = 1;
        data = 256'h0;
        ip = 32'h0;
        port = 16'h0;

        // Apply reset
        #10;
        rst = 0;

        // Provide some test data
        data = 256'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5;

        // Wait for a few clock cycles
        #10;

        // Check outputs
        $display("Time: %t, data_out: %h, istart: %b, ivalid: %b", $time, data_out, istart, ivalid);

        // Apply reset
        rst = 1;
        #10;
        rst = 0;

        // Apply different test data
        data = 256'h1234567890ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;

        // Wait for a few clock cycles
        #20;

        // Check outputs
        $display("Time: %t, data_out: %h, istart: %b, ivalid: %b", $time, data_out, istart, ivalid);

        // Finish simulation
        $finish;
    end

endmodule
*/
/*`timescale 1ns / 1ps

module tb_buffer;

    // Testbench signals
    reg clk;
    reg rst;
    reg load;
    reg shift;
    reg [551:0] data_in;
    wire [7:0] data_out;

    // Instantiate the shift_register module
    buffer uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift(shift),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize signals
        rst = 0;
        load = 0;
        shift = 0;
        data_in = 552'h0;

        // Apply reset
        #10;
        rst = 1;
        #10;
        rst = 0;


        // Load new data
        data_in = 552'h89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000C4944415408D763F8CFC000000301010018DD8DB00000000049454E44AE426082;
;
        load = 1;
        #10;
        load = 0;

        // Shift data again
        shift = 1;
        #10;
        $display("Time: %t, data_out: %h", $time, data_out); // Expect 8'hEF

        #10;
        $display("Time: %t, data_out: %h", $time, data_out); // Expect 8'hCD

        #10;
        $display("Time: %t, data_out: %h", $time, data_out); // Expect 8'hAB

        #500

        // Apply reset and check the output
        #10;
        rst = 1;
        #10;
        rst = 0;
        $display("Time: %t, data_out after reset: %h", $time, data_out); // Expect 8'h0
	
        // Finish simulation
        $finish;
    end
    initial begin
    $dumpfile("test.vcd");
	$dumpvars(0,tb_buffer);
	end

endmodule
*/


`timescale 1ns / 1ps

module tb_buffer;

    // Testbench signals
    reg clk;
    reg rst;
    reg load;
    reg shift;
    reg [551:0] data_in;
    wire [7:0] data_out;

    // Signals for hard_png
    reg istart;
    reg ivalid;
    wire iready;
    wire ostart;
    wire [2:0] colortype;
    wire [13:0] width;
    wire [31:0] height;
    wire ovalid;
    wire [7:0] opixelr, opixelg, opixelb, opixela;

    // Instantiate the buffer module
    buffer uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .shift(shift),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Instantiate the hard_png module
    hard_png hard_png_i (
        .rstn(!rst),
        .clk(clk),
        .istart(istart),
        .ivalid(ivalid),
        .iready(iready),
        .ibyte(data_out),      // Connecting buffer's data_out to hard_png's ibyte
        .ostart(ostart),
        .colortype(colortype),
        .width(width),
        .height(height),
        .ovalid(ovalid),
        .opixelr(opixelr),
        .opixelg(opixelg),
        .opixelb(opixelb),
        .opixela(opixela)
    );
    
    wire shift_count = 5'b0;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize signals
        rst = 1;
        load = 0;
        shift = 0;
        istart = 0;
        ivalid = 0;
        data_in = 552'h0;

        // Apply reset
        #20;
        rst = 0;

        // Load data into buffer
        data_in = 552'h89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000C4944415408D763F8CFC000000301010018DD8DB00000000049454E44AE426082;
        load = 1;
        #10;
        load = 0;

        // Start hard_png decoding
        istart = 1;
        #10;
        istart = 0;

        // Shift data from buffer to hard_png
        while (shift_count < 69) begin
            @(posedge clk);
            if (iready) begin
                shift = 1;
                ivalid = 1;
                #10;
                //shift = 0;
                $display("Time: %t, ibyte(data_out from buffer): %h", $time, data_out);
            end else begin
                ivalid = 0;
            end
        end
        ivalid = 0;

        // Wait for decoding to finish
        wait (ovalid);
        $display("Decode complete: colortype=%0d, width=%0d, height=%0d", colortype, width, height);

        #100;
        $finish;
    end

    initial begin
        $dumpfile("tb_buffer.vcd");
        $dumpvars(0, tb_buffer);
    end

endmodule


