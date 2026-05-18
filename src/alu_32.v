module alu_32 (
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  Op,
    output reg [31:0] Result,
    output reg        CarryOut,
    output reg        Overflow,
    output reg        Zero
);

    reg [32:0] temp;

    always @(*) begin
        // default outputs
        Result    = 32'b0;
        CarryOut = 1'b0;
        Overflow  = 1'b0;
        Zero      = 1'b0;
        temp      = 33'b0;

        case (Op)

            4'b0000: begin
                // AND
                Result = A & B;
                Zero = (Result == 0);
            end

            4'b0001: begin
                // OR
                Result = A | B;
                Zero = (Result == 0);
            end

            4'b0010: begin
                // ADD
                temp = {1'b0, A} + {1'b0, B};
                Result = temp[31:0];
                CarryOut = temp[32];

                // signed overflow for addition
                Overflow = (($signed(A) > 0 && $signed(B) > 0 && $signed(Result) < 0) ||
                            ($signed(A) < 0 && $signed(B) < 0 && $signed(Result) > 0));
                Zero = (Result == 0);
            end

            4'b0110: begin
                // SUB
                temp = {1'b0, A} - {1'b0, B};
                Result = temp[31:0];
                CarryOut = 1'b0;

                // signed overflow for subtraction
                Overflow = (($signed(A) > 0 && $signed(B) < 0 && $signed(Result) < 0) ||
                            ($signed(A) < 0 && $signed(B) > 0 && $signed(Result) > 0));
                Zero = (Result == 0);
            end

            4'b0111: begin
                // SLT (signed)
                Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
                Zero = (Result == 0);
            end

            4'b1100: begin
                // NOR
                Result = ~(A | B);
                Zero = (Result == 0);
            end

            4'b1111: begin
                // EQ
                Result = (A == B) ? 32'b1 : 32'b0;
                Zero = (Result == 0);
            end

            default: begin
                // default to ADD
                temp = {1'b0, A} + {1'b0, B};
                Result = temp[31:0];
                CarryOut = temp[32];

                Overflow = (($signed(A) > 0 && $signed(B) > 0 && $signed(Result) < 0) ||
                            ($signed(A) < 0 && $signed(B) < 0 && $signed(Result) > 0));

                Zero = (Result == 0);
            end

        endcase
    end

endmodule