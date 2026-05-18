`timescale 1ns / 1ps

module data_path #(
    parameter PC_W = 8,
    parameter INS_W = 32,
    parameter RF_ADDRESS = 5,
    parameter DATA_W = 32,
    parameter DM_ADDRESS = 9,
    parameter ALU_CC_W = 4
)(
    input clk,
    input reset,
    input reg_write,
    input mem2reg,
    input alu_src,
    input mem_write,
    input mem_read,
    input [ALU_CC_W-1:0] alu_cc,
    output [6:0] opcode,
    output [6:0] funct7,
    output [2:0] funct3,
    output [DATA_W-1:0] alu_result
);

    // ----- Wries -----
    wire [PC_W-1:0] pc_out, pc_plus4;
    wire [INS_W-1:0] instruction;

    wire [DATA_W-1:0] rg_rd_data1, rg_rd_data2;
    wire [DATA_W-1:0] imm_out, alu_b, alu_out;
    wire [DATA_W-1:0] dm_read_data, wb_data;

    wire zero, overflow, carry_out;

    wire [4:0] rs1, rs2, rd;

    // ----- PC -----
    assign pc_plus4 = pc_out + 8'd4;

    pc_reg #(.PC_W(PC_W)) PC (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_plus4),
        .pc_out(pc_out)
    );

    // ----- Instruction Memory -----
    InstMem imem (
        .addr(pc_out),
        .instruction(instruction)
    );

    // ----- Decode -----
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // ----- Register File -----
    RegFile rf (
        .clk(clk),
        .reset(reset),
        .rg_wrt_en(reg_write),
        .rg_wrt_addr(rd),
        .rg_rd_addr1(rs1),
        .rg_rd_addr2(rs2),
        .rg_wrt_data(wb_data),
        .rg_rd_data1(rg_rd_data1),
        .rg_rd_data2(rg_rd_data2)
    );

    // ----- Immediate -----
    ImmGen imm (
        .InstCode(instruction),
        .ImmOut(imm_out)
    );

    // ----- ALU MUX -----
    mux_32 alu_mux (
        .s(alu_src),
        .d0(rg_rd_data2),
        .d1(imm_out),
        .y(alu_b)
    );

    // ----- ALU -----
    alu_32 alu (
        .A(rg_rd_data1),
        .B(alu_b),
        .Op(alu_cc),
        .Result(alu_out),
        .CarryOut(carry_out),
        .Overflow(overflow),
        .Zero(zero)
    );

    assign alu_result = alu_out;

    // ----- Data Memory -----
    data_mem dmem (
        .clk(clk),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .addr(alu_out[DM_ADDRESS-1:0]),
        .write_data(rg_rd_data2),
        .read_data(dm_read_data)
    );

    // ----- Writeback MUX -----
    mux_32 wb_mux (
        .s(mem2reg),
        .d0(alu_out),
        .d1(dm_read_data),
        .y(wb_data)
    );

endmodule