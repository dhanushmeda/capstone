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


`define START_NO  1       // first png file number to decode
`define FINAL_NO  14      // last png file number to decode

`define IN_PNG_FILE_FOMRAT    "test_image/img%02d.png"
`define OUT_TXT_FILE_FORMAT   "out%02d.txt"

module tb_buffer;

    // Testbench signals
    reg clk;
    reg rst;
    reg load;
    reg shift;
    reg [31:0] ip;
    reg [15:0] port;
    reg [551:0] data_in;
    wire [7:0] data_out;
    reg istart;
    reg ivalid;
    wire iready;
    wire ostart;
    wire [2:0] colortype;
    wire [13:0] width;
    wire [31:0] height;
    wire ovalid;
    wire [7:0] opixelr, opixelg, opixelb, opixela;

    // Instantiate the shift_register module
    buffer uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .ip(ip),
        .port(port),
        .shift(shift),
        .data_in(data_in),
        .data_out(data_out),
        .istart(istart),
        .ivalid(ivalid),
        .iready(iready),
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
    integer fptxt = 0, fppng = 0;
    reg [256*8:1] fname_png;
    reg [256*8:1] fname_txt;
    integer png_no = 0;
    integer txt_no = 0;
    integer ii;
    integer cyccnt = 0;
    integer bytecnt = 0;
    reg [6:0] shift_count=0;

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
        istart = 0;
        ivalid = 0;

        // Apply reset
        #10;
        rst = 1;
        #10;
        rst = 0;
        

        // Load new data
        data_in = 552'h89504E470D0A1A0A0000000D4948445200000001000000010802000000907753DE0000000C4944415408D763F8CFC000000301010018DD8DB00000000049454E44AE426082;
        load = 1;
        #20;
        load = 0;
        #10
        while (shift_count < 69) begin
            @(posedge clk);
                shift = 1;
                #20
                ivalid = 1;
                
               
                $display("Time: %t, ibyte(data_out from buffer): %h", $time, data_out);
                if( ivalid & iready ) begin
                    $display("decoded data :%h",data_out); 
                    bytecnt = bytecnt + 1;
                end
                shift = 0;
                cyccnt = cyccnt + 1; 
             shift_count = shift_count +1;
        end
        ivalid = 0;
        
        #20
        $display("image decode done, input %d bytes in %d cycles, throughput=%f byte/cycle", bytecnt, cyccnt, (1.0*bytecnt)/cyccnt );
        
        
       #750
       $display("decode result:  colortype:%1d  width:%1d  height:%1d bit depth:08\n", colortype, width, height);

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


