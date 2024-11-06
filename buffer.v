module buffer (
    input wire clk,
    input wire rst,
    input wire load,           
    input [31:0] ip,
    input [15:0] port,
    input wire [335:0] data_in, 
    output reg [335:0] data_out
);


    always @ (posedge clk) begin
        $display("Data in to buffer: %h",data_in);
        $display("Load signal in buffer: %h",load);
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
        end 
        if (load) begin
            data_out <= data_in;
            $display("data out from buffer: %h",data_out);
        end 
    end

hard_png inst (
	.clk(clk),
	.rstn(rst),
	.idata(data_out)
);
endmodule
