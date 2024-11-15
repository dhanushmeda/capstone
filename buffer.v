/*module buffer (
    input clk,
    input rst,
    input [255:0] data,
    input [31:0] ip,
    input [15:0] port,
    output reg [7:0] data_out,
    output reg istart,
    output reg ivalid
);

reg [255:0]data_reg;
reg [7:0] bit_count;


always @ (posedge clk or posedge rst)
begin
	if (rst) begin
		data_reg<=0;
		bit_count<=0;
		ivalid<=0;
		istart<=0;
	end
	else begin
		ivalid<=1;
		istart<=1;
		data_reg<=data;
		data_out<=data_reg[bit_count+7:bit_count];
		bit_count<=bit_count+7;
		
	end
end*/

/*module buffer (
    input wire clk,
    input wire rst,
    input wire load,            // Signal to load the data
    input wire shift,           // Signal to shift the data
    input [31:0] ip,
    input [15:0] port,
    input wire [551:0] data_in, // 552-bit input data
    output reg [7:0] data_out,   // 8-bit output data
    input  wire         istart,
    input  wire         ivalid,
    output wire          iready,
    //input  wire [ 7:0]  ibyte,
    // image frame configuration output
    output wire          ostart,
    output wire [ 2:0]  colortype, // 0:gray   1:gray+A   2:RGB   3:RGBA   4:RGB-plte
    output wire [13:0]  width,     // image width
    output wire [31:0]  height,    // image height
    // pixel output
    output wire          ovalid,
    output wire [ 7:0]  opixelr, opixelg, opixelb, opixela

    //output reg istart,
    //output reg ivalid
);

    reg [551:0] shift_reg; // 336-bit shift register
    reg [5:0]  shift_count; // Counter to manage shifts

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 552'b0;
            data_out <= 8'b0;
            shift_count <= 3'b0;
        end else if (load) begin
            shift_reg <= data_in;
            shift_count <= 3'b0;
        end else if (shift) begin
            if (shift_count < 69) begin
                shift_reg <= shift_reg >> 8; // Shift the register right by 8 bits
                shift_count <= shift_count + 1;
            end
            data_out <= shift_reg[7:0]; // Output the lowest 8 bits
            $display("data out: %d",data_out);
        end
    end




hard_png inst (
	.clk(clk),
	.rstn(rst),
	.istart(istart),
	.ivalid(ivalid),
	.iready(iready),
	.ibyte(data_out),
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
endmodule
*/

module buffer (
    input wire clk,
    input wire rst,
    input wire load,            // Signal to load the data
    input wire shift,           // Signal to shift the data
    input [31:0] ip,
    input [15:0] port,
    input wire [551:0] data_in, // 256-bit input data
    output reg [7:0] data_out,   // 8-bit output data
    input wire istart,
    input wire ivalid,
    output wire iready,
    output wire ostart,
    output wire [ 2:0]  colortype, // 0:gray   1:gray+A   2:RGB   3:RGBA   4:RGB-plte
    output wire [13:0]  width,     // image width
    output wire [31:0]  height,    // image height
    // pixel output
    output wire          ovalid,
    output wire [ 7:0]  opixelr, opixelg, opixelb, opixela
);

    reg [551:0] shift_reg; // 256-bit shift register
    reg [6:0]  shift_count; // Counter to manage shifts

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 552'b0;
            data_out <= 8'b0;
            shift_count <= 7'b0;
        end else if (load) begin
            shift_reg <= data_in;
            shift_count <= 7'b0;
            $display("shift reg %h",shift_reg);
            
        end else if (shift) begin
            if (shift_count < 69) begin
                shift_reg <= shift_reg << 8; // Shift the register left by 8 bits
                shift_count <= shift_count + 1;
            end
            data_out <= shift_reg[551:544]; // Output the highest 8 bits
            $display("data out %d",data_out);
        end
    end




hard_png inst (
	.clk(clk),
	.rstn(rst),
	.istart(istart),
	.ivalid(ivalid),
	.ibyte(data_out),
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
	

endmodule
