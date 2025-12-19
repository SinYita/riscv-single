`include "define.v"

module controller(
    input        clk, rst,
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7b5, // instr[30]
    input        zero,
    output [1:0] sel_alu_src_a, sel_alu_src_b, sel_result,
    output       sel_mem_addr,
    output       we_mem, we_pc, we_ir, we_rf,
    output [2:0] sel_ext,
    output [3:0] alu_control
);
    wire pc_update;
    wire branch;
    wire [1:0] alu_op;
    main_fsm FSM (
        .clk(clk),
        .rst(rst),
        .op(op),
        .zero(zero),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .alu_op(alu_op),
        .sel_result(sel_result),
        .sel_mem_addr(sel_mem_addr),
        .we_mem(we_mem),
        .pc_update(pc_update),
        .we_ir(we_ir),
        .we_rf(we_rf),
        .branch(branch)
    );

    ALU_Decoder ALU_DEC (
        .opb5(op[5]),
        .ALUOp(alu_op),
        .funct3(funct3),
        .funct7({1'b0, funct7b5, 5'b0}),
        .alu_control(alu_control)
    );

    Instr_Decoder INST_DEC (
        .op(op),
        .sel_ext(sel_ext)
    );
    assign we_pc = (branch & zero) | pc_update;

endmodule