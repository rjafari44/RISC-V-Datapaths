`timescale 1ns / 1ps

module pc_reg #(
    parameter PC_W = 8
)(
    input clk,
    input reset,
    input [PC_W-1:0] pc_in,
    output reg [PC_W-1:0] pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc_out <= 0;
    else
        pc_out <= pc_in;
end

endmodule