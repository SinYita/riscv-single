module datapath(
    input  clk, rst,
    input  [1:0] sel_result,       // 对应 ResultSrc
    input  we_rf,                  // 对应 RegWrite
    input  [2:0] sel_ext,          // 对应 ImmSrc (RISC-V通常需要3位)
    input  [3:0] alu_control,      // 对应 ALUControl
    output zero,
    output [31:0] instr,           // 输出给 Controller 译码
    output [31:0] addr,            // 输出给 Memory 的地址
    output [31:0] write_data,      // 输出给 Memory 的写数据 (B寄存器)
    input  [31:0] read_data,       // 从 Memory 读回的数据
    input  we_ir, we_pc,           // 使能信号
    input  sel_mem_addr,           // 对应 AdrSrc
    input  [1:0] sel_alu_src_a,    // 对应 ALUSrcA
    input  [1:0] sel_alu_src_b     // 对应 ALUSrcB
);

    wire [31:0] pc, pc_next, old_pc;
    wire [31:0] imm_ext;
    wire [31:0] rd1, rd2, SrcA, SrcB,A,data_out;
    wire [31:0] result, alu_result, alu_out_reg;

    // --- PC 逻辑 ---
    // PC 寄存器 (带使能)
    assign pc_next = result;
    flopenr #(32) PC_reg(
        .clk(clk), 
        .rst(rst), 
        .en(we_pc), 
        .d(pc_next), 
        .q(pc)
    );
    
    // --- Memory 接口逻辑 ---
    // AdrSrc Mux: 选择 PC 或 ALUOut 作为访存地址
    mux2 #(32) addr_mux(
        .d0(pc), 
        .d1(result), 
        .s(sel_mem_addr), 
        .y(addr)
    );
    
//memflop2
    flopenr #(32) instr_reg(
        .clk(clk), 
        .rst(rst), 
        .en(we_ir), 
        .d(read_data), 
        .q(instr)
    );
    //memflop1
    flopenr #(32) old_pc_reg(
        .clk(clk), 
        .rst(rst), 
        .en(we_ir), 
        .d(pc), 
        .q(old_pc)
    );
    // dataflop
    flopr #(32) datSrcA(
        .clk(clk), 
        .rst(rst), 
        .d(read_data), 
        .q(data_out)
    );

    Register_File rf(
        .clk(clk), 
        .WE(we_rf), 
        .A1(instr[19:15]), 
        .A2(instr[24:20]), 
        .A3(instr[11:7]), 
        .WD(result), 
        .RD1(rd1), 
        .RD2(rd2)
    );

    Sign_Extend ext(
        .Ins(instr[31:7]), 
        .sel_ext(sel_ext), 
        .ImmExt(imm_ext)
    );

//reg_f1
    flopr #(32) rd1_reg(
        .clk(clk), 
        .rst(rst), 
        .d(rd1), 
        .q(A)
    );
    //reg_f2
    flopr #(32) rd2_reg(
        .clk(clk), 
        .rst(rst), 
        .d(rd2), 
        .q(write_data)
    );
    

    mux3 #(32) src_a_mux(
        .d0(pc), 
        .d1(old_pc), 
        .d2(A), 
        .s(sel_alu_src_a), 
        .y(SrcA)
    );

    // ALUSrcB Mux
    mux3 #(32) src_b_mux(
        .d0(write_data), 
        .d1(imm_ext), 
        .d2(32'd4), 
        .s(sel_alu_src_b), 
        .y(SrcB)
    );

    // --- ALU ---
    ALU alu_inst(
        .A(SrcA), 
        .B(SrcB), 
        .alu_control(alu_control), 
        .Result(alu_result), 
        .Zero(zero)
    );

    // ALUOut 寄存器
    flopr #(32) alu_reg(
        .clk(clk), 
        .rst(rst), 
        .d(alu_result), 
        .q(alu_out_reg)
    );

    // --- 结果写回选择 (Result Mux) ---
    mux3 #(32) res_mux(
        .d0(alu_out_reg), 
        .d1(data_out), 
        .d2(alu_result), 
        .s(sel_result), 
        .y(result)
    );

endmodule