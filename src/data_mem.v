`timescale 1ns / 1ps

module data_mem(
    input clk,
    input MemRead,
    input MemWrite,
    input [8:0] addr,
    input [31:0] write_data,
    output reg [31:0] read_data
);

reg [31:0] memory [127:0];
wire [6:0] index;

assign index = addr[8:2];

always @(posedge clk) begin
    if (MemWrite)
        memory[index] <= write_data;
end

always @(*) begin
    if (MemRead)
        read_data = memory[index];
    else
        read_data = 32'b0;
end

endmodule