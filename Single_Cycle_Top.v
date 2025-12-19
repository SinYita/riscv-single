`include "define.v"

module Single_Cycle_Top(
    input clk,
    input rst
);

    wire [31:0] PC_Current, PC_Next;
    wire [31:0] Instr;
    wire [31:0] RD1, RD2, WD3;
    wire [31:0] Imm_Ext;
    wire [31:0] ALU_Out, SrcB, Mem_Data;
    
    wire RegWrite, MemWrite, ALUSrcB, PCSrc, Zero;
    wire [2:0] sel_ext;
    wire [1:0] sel_wb;     
    wire [3:0] alu_ctrl;
    PC pc_inst(
        .clk(clk),
        .rst(rst),
        .NPC(PC_Next),
        .PC(PC_Current)
    );

    NPC npc_inst(
        .PC(PC_Current),
        .PCSrc(PCSrc),
        .IMMEXT(Imm_Ext),
        .NPC(PC_Next)
    );
    
    Instruction_Memory imem_inst(
        .rst(rst),
        .A(PC_Current),     
        .RD(Instr)         
    );

    Register_File regfile_inst(
        .clk(clk),
        .rst(rst),
        .WE(RegWrite),
        .A1(Instr[19:15]),
        .A2(Instr[24:20]),
        .A3(Instr[11:7]),
        .WD(WD3),         
        .RD1(RD1),
        .RD2(RD2)
    );

    Sign_Extend ext_inst(
        .Ins(Instr),
        .sel_ext(sel_ext),
        .ImmExt(Imm_Ext)
    );

    Mux alu_src_mux(
        .in_1(RD2),
        .in_2(Imm_Ext),
        .sel(ALUSrcB),
        .out(SrcB)
    );

    ALU alu_inst(
        .A(RD1),
        .B(SrcB),
        .alu_control(alu_ctrl),
        .Result(ALU_Out),
        .Zero(Zero)
    );

    Controller controller_inst(
        .Op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7(Instr[31:25]),
        .Zero(Zero),
        .rf_we(RegWrite),
        .sel_ext(sel_ext),
        .sel_alu_src_b(ALUSrcB),
        .dmem_we(MemWrite),
        .sel_result(sel_wb),
        .PCSrc(PCSrc),
        .alu_control(alu_ctrl)
    );

    Data_Memory dmem_inst(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite),
        .WD(RD2),
        .A(ALU_Out),
        .RD(Mem_Data)
    );
    assign WD3 = (sel_wb == `WB_ALU) ? ALU_Out :
                 (sel_wb == `WB_MEM) ? Mem_Data :
                 (sel_wb == `WB_PC4) ? (PC_Current + 4) : ALU_Out;

endmodule