`include "define.v"

module Datapath(
    input  wire        clk, rst_n,
    // F
    output wire [31:0] F_pc,
    input  wire [31:0] F_instr,
    // D
    output wire [31:0] D_instr,
    input  wire        E_pcsrc,
    // M
    output wire [31:0] M_alu_o,
    output wire [31:0] M_rf_wd,
    input  wire [31:0] M_dm_rd,
    // W
    input  wire        W_we_rf,
    input  wire [1:0]  W_sel_result,

    input  wire        E_sel_alu_src_b,
    input  wire [2:0]  D_sel_ext,
    input  wire [3:0]  E_alu_control,

    output wire        ZeroE,
    input  wire        F_stall, D_flush, D_stall, E_flush,
    input  wire [1:0]  E_fd_A, E_fd_B,
    output wire [4:0]  D_rf_a1, D_rf_a2,
    output wire [4:0]  E_rf_a1, E_rf_a2, E_rf_a3, M_rf_a3, W_rf_a3,
    // Register File Interface
    input  wire [31:0] D_rf_rd1, D_rf_rd2,
    output wire [31:0] W_result
);
    
    wire [31:0] F_PC_P4, E_target_PC, F_pc_next;
    
    wire [31:0] D_pc, D_PC_P4;
    wire [31:0] D_imm_ext;
    
    wire [31:0] E_rf_rd1, E_rf_rd2;
    wire [31:0] E_pc, E_imm_ext;
    wire [31:0] E_PC_P4;
    wire [31:0] E_alu_src_a, E_rf_wd_fwd, E_alu_src_b;
    wire [31:0] E_alu_result;
    

    wire [31:0] M_PC_P4;
    

    wire [31:0] W_alu_o;
    wire [31:0] W_dm_rd;
    wire [31:0] W_PC_P4;
    
    
    //F
    // PC mux
    mux2 #(32) pcfmux(F_PC_P4, E_target_PC, E_pcsrc, F_pc_next);
    
    flopenr #(32) pcfflopen(clk, rst_n, ~F_stall, F_pc_next, F_pc);
    
    // PC + 4 adder
    assign F_PC_P4 = F_pc + 32'd4;
    
    //F -> D
    
    flopenclr #(32) InstrDflopenclr(clk, rst_n, D_flush, ~D_stall, F_instr, D_instr);
    flopenclr #(32) PCDflopenclr(clk, rst_n, D_flush, ~D_stall, F_pc, D_pc);
    flopenclr #(32) PCPlus4Dflopenclr(clk, rst_n, D_flush, ~D_stall, F_PC_P4, D_PC_P4);
    
    //D
    
    assign D_rf_a1 = D_instr[19:15];
    assign D_rf_a2 = D_instr[24:20];
    
    Sign_Extend ext(
        .Ins(D_instr),
        .sel_ext(D_sel_ext),
        .ImmExt(D_imm_ext)
    );
    
    //D->E
    
    flopclr #(32) RD1Eflopclr(clk, rst_n, E_flush, D_rf_rd1, E_rf_rd1);
    flopclr #(32) RD2Eflopclr(clk, rst_n, E_flush, D_rf_rd2, E_rf_rd2);
    flopclr #(32) PCEflopclr(clk, rst_n, E_flush, D_pc, E_pc);
    flopclr #(5)  Rs1Eflopclr(clk, rst_n, E_flush, D_rf_a1, E_rf_a1);
    flopclr #(5)  Rs2Eflopclr(clk, rst_n, E_flush, D_rf_a2, E_rf_a2);
    flopclr #(5)  RdEflopclr(clk, rst_n, E_flush, D_instr[11:7], E_rf_a3);
    flopclr #(32) ImmExtEflopclr(clk, rst_n, E_flush, D_imm_ext, E_imm_ext);
    flopclr #(32) PCPlus4Eflopclr(clk, rst_n, E_flush, D_PC_P4, E_PC_P4);
    
    //E
    
    mux3 #(32) SrcAEMux(E_rf_rd1, W_result, M_alu_o, E_fd_A, E_alu_src_a);
    
    mux3 #(32) WDEMux(E_rf_rd2, W_result, M_alu_o, E_fd_B, E_rf_wd_fwd);
    
    mux2 #(32) SrcBEmux(E_rf_wd_fwd, E_imm_ext, E_sel_alu_src_b, E_alu_src_b);
    
    assign E_target_PC = E_pc + E_imm_ext;
    
    ALU alu_inst(
        .A(E_alu_src_a),
        .B(E_alu_src_b),
        .alu_control(E_alu_control),
        .Result(E_alu_result),
        .Zero(ZeroE)
    );
    
    //E-M
    
    flopr #(32) ALUReMflop(clk, rst_n, E_alu_result, M_alu_o);
    flopr #(32) WMMflop(clk, rst_n, E_rf_wd_fwd, M_rf_wd);
    flopr #(5)  RdMflop(clk, rst_n, E_rf_a3, M_rf_a3);
    flopr #(32) PCPlus4Mflop(clk, rst_n, E_PC_P4, M_PC_P4);
    
    // M
    //M-W
    
    flopr #(32) ALUReWBflop(clk, rst_n, M_alu_o, W_alu_o);
    flopr #(32) rdWflop(clk, rst_n, M_dm_rd, W_dm_rd);
    flopr #(5)  RdWflop(clk, rst_n, M_rf_a3, W_rf_a3);
    flopr #(32) PCPlus4Wflop(clk, rst_n, M_PC_P4, W_PC_P4);
    
    // W
    
    // 
    mux3 #(32) ResultWMux(W_alu_o, W_dm_rd, W_PC_P4, W_sel_result, W_result);
    
endmodule
