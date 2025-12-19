module rv_mc(
    input clk,
    input rst
);
    wire [31:0] instr, addr, write_data, read_data;
    wire [1:0]  sel_alu_src_a, sel_alu_src_b, alu_op, sel_result;
    wire [2:0]  sel_ext;
    wire [3:0]  alu_control;
    wire        sel_mem_addr, we_mem, we_pc, we_ir, we_rf, branch, zero;
    wire       we_pc_to_dp;
    mem MEM (
        .clk(clk),
        .WE(we_mem),
        .A(addr),
        .WD(write_data),
        .RD(read_data)
    );

    controller CTRL (
        .clk(clk),
        .rst(rst),
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7b5(instr[30]),
        .zero(zero),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b),
        .alu_op(alu_op),
        .sel_result(sel_result),
        .sel_mem_addr(sel_mem_addr),
        .we_mem(we_mem),
        .we_pc(we_pc_to_dp),      // FSM 输出的基本 PC 写信号
        .we_ir(we_ir),
        .we_rf(we_rf),
        .sel_ext(sel_ext),
        .alu_control(alu_control),
        .branch(branch)     // 分支指令标识
    );

    datapath DP (
        .clk(clk),
        .rst(rst),
        .sel_result(sel_result),
        .we_rf(we_rf),
        .sel_ext(sel_ext),
        .alu_control(alu_control),
        .zero(zero),
        .instr(instr),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data),
        .we_ir(we_ir),
        .we_pc(we_pc_to_dp), 
        .sel_mem_addr(sel_mem_addr),
        .sel_alu_src_a(sel_alu_src_a),
        .sel_alu_src_b(sel_alu_src_b)
    );

endmodule