`include "define.v"

module controller(
    input        clk, rst,
    input  [6:0] op,
    input  [2:0] funct3,
    input        funct7b5, // instr[30]
    input        zero,
    output [1:0] sel_alu_src_a, sel_alu_src_b, alu_op, sel_result,
    output       sel_mem_addr,
    output       we_mem, we_pc, we_ir, we_rf,
    output [2:0] sel_ext,
    output [3:0] alu_control,
    output       branch
);
    wire pc_update;
    main_fsm FSM (
        .clk(clk),
        .rst(rst),
        .op(op),
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
        .ALUOp(alu_op),
        .funct3(funct3),
        .funct7({1'b0, funct7b5, 5'b0}),
        .alu_control(alu_control)
    );

    // 3. 立即数扩展选择 (这个依然是组合逻辑，根据 op 直接判断即可)
    // 对应你之前 Op_Decoder 里的 sel_ext 部分
    Instr_Decoder INST_DEC (
        .op(op),
        .sel_ext(sel_ext)
    );
    assign we_pc = (branch & zero) | pc_update;

endmodule