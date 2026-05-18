`timescale 1ns / 1ps

module mux_32(
    input s,
    input [31:0] d0,
    input [31:0] d1,
    output reg [31:0] y
);

always @(*) begin
    case (s)
        1'b0: y = d0;
        1'b1: y = d1;
        default: y = d0;
    endcase
end

endmodule