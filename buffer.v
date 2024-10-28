module buffer (
    input wire clk,
    input wire rst,
    input wire load,            // Signal to load the data
    input wire shift,           // Signal to shift the data
    input [31:0] ip,
    input [15:0] port,
    input wire [335:0] data_in, // 336-bit input data
    output reg [7:0] data_out   // 8-bit output data
    //output reg istart,
    //output reg ivalid
);

    reg [335:0] shift_reg; // 336-bit shift register
    reg [2:0]  shift_count; // Counter to manage shifts

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 336'b0;
            data_out <= 8'b0;
            shift_count <= 3'b0;
        end else if (load) begin
            shift_reg <= data_in;
            shift_count <= 3'b0;
        end else if (shift) begin
            if (shift_count < 31) begin
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
	.ibyte(data_out),
	.ip(ip),

	.port(port)	
);
endmodule
