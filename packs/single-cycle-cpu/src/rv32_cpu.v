// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Single-cycle RV32I core. Supported instructions:
//   * ADDI, ADD, SUB   -- arithmetic / register ops
//   * LW,   SW         -- 32-bit word load / store
//   * BEQ              -- conditional branch
//   * JAL              -- unconditional jump-and-link
//
// All other opcodes execute as NOPs (no register write, PC advances by
// 4). Intended for visualization, not synthesis.

`timescale 1ns / 1ns

module rv32_cpu (
    input  wire        clk,
    input  wire        rst,
    output reg  [31:0] pc,
    output wire [31:0] instr
);
    // ── Instruction fetch ────────────────────────────────────────────
    imem u_imem (.addr(pc), .instr(instr));

    // ── Decode ──────────────────────────────────────────────────────
    wire [ 6:0] opcode = instr[ 6: 0];
    wire [ 4:0] rd     = instr[11: 7];
    wire [ 2:0] funct3 = instr[14:12];
    wire [ 4:0] rs1    = instr[19:15];
    wire [ 4:0] rs2    = instr[24:20];
    wire [ 6:0] funct7 = instr[31:25];

    localparam [6:0] OP_RTYPE  = 7'b0110011;
    localparam [6:0] OP_ITYPE  = 7'b0010011;
    localparam [6:0] OP_LOAD   = 7'b0000011;
    localparam [6:0] OP_STORE  = 7'b0100011;
    localparam [6:0] OP_BRANCH = 7'b1100011;
    localparam [6:0] OP_JAL    = 7'b1101111;

    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7],
                         instr[30:25], instr[11:8], 1'b0};
    wire [31:0] imm_j = {{11{instr[31]}}, instr[31], instr[19:12],
                         instr[20], instr[30:21], 1'b0};

    // ── Register file ────────────────────────────────────────────────
    wire [31:0] rs1_val;
    wire [31:0] rs2_val;
    reg         rf_we;
    reg  [31:0] rf_wdata;

    regfile u_regfile (
        .clk     (clk),
        .we      (rf_we),
        .rd_addr (rd),
        .rd_data (rf_wdata),
        .rs1_addr(rs1),
        .rs1_data(rs1_val),
        .rs2_addr(rs2),
        .rs2_data(rs2_val)
    );

    // ── ALU ──────────────────────────────────────────────────────────
    reg [31:0] alu_out;
    always @(*) begin
        case (opcode)
            OP_RTYPE: alu_out = funct7[5] ? (rs1_val - rs2_val)
                                          : (rs1_val + rs2_val);
            OP_ITYPE: alu_out = rs1_val + imm_i;
            OP_LOAD:  alu_out = rs1_val + imm_i;
            OP_STORE: alu_out = rs1_val + imm_s;
            default:  alu_out = 32'h0;
        endcase
    end

    // ── Data memory ─────────────────────────────────────────────────
    reg [31:0] dmem [0:31];
    wire [4:0] dmem_idx = alu_out[6:2];

    // ── Branch / next-PC ────────────────────────────────────────────
    wire branch_taken = (opcode == OP_BRANCH) &&
                        (funct3 == 3'b000) &&
                        (rs1_val == rs2_val);

    wire [31:0] pc_next = (opcode == OP_JAL) ? (pc + imm_j) :
                          branch_taken       ? (pc + imm_b) :
                                               (pc + 32'd4);

    // ── Writeback control ───────────────────────────────────────────
    always @(*) begin
        rf_we    = 1'b0;
        rf_wdata = 32'h0;
        case (opcode)
            OP_RTYPE, OP_ITYPE: begin
                rf_we    = 1'b1;
                rf_wdata = alu_out;
            end
            OP_LOAD: begin
                rf_we    = 1'b1;
                rf_wdata = dmem[dmem_idx];
            end
            OP_JAL: begin
                rf_we    = 1'b1;
                rf_wdata = pc + 32'd4;
            end
            default: ;
        endcase
    end

    // ── Sequential: PC, store ───────────────────────────────────────
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'h0;
            for (i = 0; i < 32; i = i + 1) dmem[i] <= 32'h0;
        end else begin
            pc <= pc_next;
            if (opcode == OP_STORE && funct3 == 3'b010) begin
                dmem[dmem_idx] <= rs2_val;
            end
        end
    end
endmodule
