`include "define.v"
`include "PC.v"
`include "NPC.v"
`include "Instruction_Memory.v"
`include "Register_File.v"
`include "Sign_Extend.v"
`include "ALU.v"
`include "Controller.v"
`include "Data_Memory.v"
`include "Mux.v"

module Single_Cycle_Top(clk,rst);

    input clk,rst;

    wire [31:0] PC_Top,RD_Instr,RD1_Top,Imm_Ext_Top,ALUResult,ReadData,PCPlus4,RD2_Top,SrcB,Result;
    wire RegWrite,MemWrite,ALUSrc,PCSrc,Zero;
    wire [2:0] ImmSrc;
    wire [2:0] ResultSrc;
    wire [3:0] ALUControl_Top;

    PC PC(
        .clk(clk),
        .rst(rst),
        .NPC(PCPlus4),
        .PC(PC_Top)
    );

    NPC NPC(
        .PC(PC_Top),
        .PCSrc(PCSrc),
        .IMMEXT(Imm_Ext_Top),
        .NPC(PCPlus4)
    );
    
    Instruction_Memory Instruction_Memory(
        .rst(rst),
        .Address(PC_Top),
        .ReadData(RD_Instr)
    );

    Register_File Register_File(
        .clk(clk),
        .rst(rst),
        .WriteEnable3(RegWrite),
        .WD3(Result),
        .Address1(RD_Instr[19:15]),
        .Address2(RD_Instr[24:20]),
        .Address3(RD_Instr[11:7]),
        .RD1(RD1_Top),
        .RD2(RD2_Top)
    );

    Sign_Extend Sign_Extend(
        .Ins(RD_Instr),
        .Imm_src(ImmSrc),
        .ImmExt(Imm_Ext_Top)
    );

    Mux Mux_Register_to_ALU(
        .in_1(RD2_Top),
        .in_2(Imm_Ext_Top),
        .sel(ALUSrc),
        .out(SrcB)
    );

    ALU ALU(
        .A(RD1_Top),
        .B(SrcB),
        .ALUControl(ALUControl_Top),
        .Result(ALUResult),
        .Zero(Zero)
    );

    Controller Controller(
        .Zero(Zero),
        .inst(RD_Instr),
        .RegWrite_E(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite_E(MemWrite),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .funct3(RD_Instr[14:12]),
        .funct7(RD_Instr[31:25]),
        .ALUControl(ALUControl_Top)
    );

    Data_Memory Data_Memory(
                        .clk(clk),
                        .rst(rst),
                        .WE(MemWrite),
                        .WD(RD2_Top),
                        .A(ALUResult),
                        .RD(ReadData)
    );

    // 4-to-1 Result Multiplexer (can be regarded as a multilevel mux)
    // this is used to select the data to be written back to the register file
    assign Result = (ResultSrc == `FROM_ALU) ? ALUResult :
                   (ResultSrc == `FROM_MEM) ? ReadData :
                   (ResultSrc == `FROM_PC_) ? (PC_Top + 4) :
                   (ResultSrc == `FROM_IMM) ? Imm_Ext_Top : ALUResult;

endmodule