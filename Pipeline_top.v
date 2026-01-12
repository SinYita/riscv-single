`include "define.v"

module rv_pl(
    input  wire clk,
    input  wire rst_n
);

    wire [31:0] F_pc;
    wire [31:0] F_instr;
    
    wire [31:0] D_instr;
    wire [4:0]  D_rf_a1, D_rf_a2;
    wire [2:0]  D_sel_ext;
    
    wire [4:0]  E_rf_a1, E_rf_a2, E_rf_a3;
    wire [3:0]  E_alu_control;
    wire        E_sel_alu_src_b;
    wire [1:0]  E_sel_result;
    wire        E_pcsrc;
    wire        ZeroE;
    wire [1:0]  E_fd_A, E_fd_B;
    
    wire [31:0] M_alu_o;
    wire [31:0] M_rf_wd;
    wire [31:0] M_dm_rd;
    wire [4:0]  M_rf_a3;
    wire        M_we_rf;
    wire        M_we_dm;
    
    wire [4:0]  W_rf_a3;
    wire [1:0]  W_sel_result;
    wire        W_we_rf;
    
    wire [31:0] D_rf_rd1, D_rf_rd2;
    wire [31:0] W_result;
    
    wire F_stall, D_flush, D_stall, E_flush;
    
    Instruction_Memory #(
        .MEM_DEPTH(1024)
    ) IMEM (
        .rst_n(rst_n),
        .A(F_pc),
        .RD(F_instr)
    );
    
    // ===== Data Memory =====
    Data_Memory #(
        .MEM_DEPTH(1024)
    ) DMEM (
        .clk(clk),
        .rst_n(rst_n),
        .WE(M_we_dm),
        .A(M_alu_o),
        .WD(M_rf_wd),
        .RD(M_dm_rd)
    );
    
    // ===== Register File =====
    Register_File RF (
        .clk(~clk),
        .rst_n(rst_n),
        .WE(W_we_rf),
        .A1(D_rf_a1),
        .A2(D_rf_a2),
        .A3(W_rf_a3),
        .WD(W_result),
        .RD1(D_rf_rd1),
        .RD2(D_rf_rd2)
    );
    
    // ===== Datapath =====
    Datapath datapath_inst (
        .clk(clk),
        .rst_n(rst_n),
        // Fetch
        .F_pc(F_pc),
        .F_instr(F_instr),
        .D_instr(D_instr),
        .D_rf_a1(D_rf_a1),
        .D_rf_a2(D_rf_a2),
        .D_sel_ext(D_sel_ext),
        .E_pcsrc(E_pcsrc),
        .E_sel_alu_src_b(E_sel_alu_src_b),
        .E_alu_control(E_alu_control),
        .E_rf_a1(E_rf_a1),
        .E_rf_a2(E_rf_a2),
        .E_rf_a3(E_rf_a3),
        .E_fd_A(E_fd_A),
        .E_fd_B(E_fd_B),
        .ZeroE(ZeroE),
        .M_alu_o(M_alu_o),
        .M_rf_wd(M_rf_wd),
        .M_dm_rd(M_dm_rd),
        .M_rf_a3(M_rf_a3),
        .W_we_rf(W_we_rf),
        .W_sel_result(W_sel_result),
        .W_rf_a3(W_rf_a3),
        .D_rf_rd1(D_rf_rd1),
        .D_rf_rd2(D_rf_rd2),
        .W_result(W_result),
        .F_stall(F_stall),
        .D_flush(D_flush),
        .D_stall(D_stall),
        .E_flush(E_flush)
    );
    
    // ===== Controller =====
    Controller controller_inst (
        .clk(clk),
        .rst_n(rst_n),
        // Decode inputs
        .op(D_instr[6:0]),
        .funct3(D_instr[14:12]),
        .funct7(D_instr[31:25]),
        .D_sel_ext(D_sel_ext),
        .E_flush(E_flush),
        .ZeroE(ZeroE),
        .E_pcsrc(E_pcsrc),
        .E_sel_result(E_sel_result),
        .E_alu_control(E_alu_control),
        .E_sel_alu_src_b(E_sel_alu_src_b),
        .M_we_rf(M_we_rf),
        .M_we_dm(M_we_dm),
        .W_we_rf(W_we_rf),
        .W_sel_result(W_sel_result)
    );
    
    Hazard_Unit hazard_inst (
        .D_rf_a1(D_rf_a1),
        .D_rf_a2(D_rf_a2),
        .E_rf_a1(E_rf_a1),
        .E_rf_a2(E_rf_a2),
        .E_rf_a3(E_rf_a3),
        .E_pcsrc(E_pcsrc),
        .E_sel_result0(E_sel_result[0]), 
        .M_rf_a3(M_rf_a3),
        .M_we_rf(M_we_rf),
        .W_rf_a3(W_rf_a3),
        .W_we_rf(W_we_rf),
        .F_stall(F_stall),
        .D_flush(D_flush),
        .D_stall(D_stall),
        .E_flush(E_flush),
        .E_fd_A(E_fd_A),
        .E_fd_B(E_fd_B)
    );

endmodule
