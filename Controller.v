`include "define.v"

module Controller(
    input  clk, rst_n,
    input  [6:0] op,          
    input  [2:0] funct3,       
    input  [6:0] funct7,      
    input  E_flush,       
    input  ZeroE,       
    output M_we_rf,    // 输出给 Hazard Unit 和 Datapath
    output W_we_rf,    // 输出给 Register File
    output M_we_dm,    // 输出给 Data Memory
    output E_pcsrc,       
    output [1:0] E_sel_result,   
    output [1:0] W_sel_result,   
    output [3:0] E_alu_control,  
    output E_sel_alu_src_b,      
    output [2:0] D_sel_ext,
    output E_we_rf       
);
    
    // D
    wire D_we_rf, D_we_dm, D_jump, D_branch, D_sel_alu_src_b;
    wire [1:0] D_sel_result;
    wire [3:0] D_alu_control;
    wire [1:0] ALUOp;
    
    Op_Decoder md(
        .Op(op), .RegWrite(D_we_rf), .ImmSrc(D_sel_ext),
        .ALUSrc(D_sel_alu_src_b), .MemWrite(D_we_dm),
        .ResultSrc(D_sel_result), .Branch(D_branch),
        .ALUOp(ALUOp), .Jump(D_jump)
    );
    
    ALU_Decoder alu_dec(
        .ALUOp(ALUOp), .funct3(funct3),
        .funct7b5(funct7[5]), .opb5(op[5]),
        .alu_control(D_alu_control)
    );
    
    // E
    wire E_we_dm, E_jump, E_branch;
    wire [1:0] E_sel_res_mid;

    flopclr #(1)  RWE_reg(clk, rst_n, E_flush, D_we_rf, E_we_rf); // 直接输出给顶层
    flopclr #(2)  RSE_reg(clk, rst_n, E_flush, D_sel_result, E_sel_result); // 赋值给输出端口
    flopclr #(1)  MWE_reg(clk, rst_n, E_flush, D_we_dm, E_we_dm);
    flopclr #(1)  JE_reg(clk, rst_n, E_flush, D_jump, E_jump);
    flopclr #(1)  BE_reg(clk, rst_n, E_flush, D_branch, E_branch);
    flopclr #(4)  ALUConE_reg(clk, rst_n, E_flush, D_alu_control, E_alu_control);
    flopclr #(1)  ASrcE_reg(clk, rst_n, E_flush, D_sel_alu_src_b, E_sel_alu_src_b);
    
    // 
    assign E_pcsrc = (E_branch & ZeroE) | E_jump;
    
    // M
    wire [1:0] M_sel_res_mid;

    // E -> M
    flopr #(1) RWM_reg(clk, rst_n, E_we_rf, M_we_rf);
    flopr #(2) RSM_reg(clk, rst_n, E_sel_result, M_sel_res_mid);
    flopr #(1) MWM_reg(clk, rst_n, E_we_dm, M_we_dm);
    
    //W
    // M -> W 
    flopr #(1) RWWB_reg(clk, rst_n, M_we_rf, W_we_rf);
    flopr #(2) RSWB_reg(clk, rst_n, M_sel_res_mid, W_sel_result);
    
endmodule