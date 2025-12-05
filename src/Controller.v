`include "define.v"
`include "ALU_Decoder.v"
`include "Op_Decoder.v"

module Controller(Zero,inst, RegWrite_E, ImmSrc, ALUSrc, MemWrite_E, ResultSrc, PCSrc, funct3, funct7, ALUControl);


    input Zero;
    input [31:0] inst;          
    input [2:0] funct3;        
    input [6:0] funct7;        

    
    output RegWrite_E;           
    output ALUSrc;              
    output MemWrite_E;           
    output [2:0] ResultSrc;          
    output PCSrc;               
    output [2:0] ImmSrc;       
    output [3:0] ALUControl;  

    wire [2:0] ALUOp;           
    wire [6:0] Op = inst[6:0];  


    Op_Decoder main_decoder(
        .Zero(Zero),
        .inst(inst),                    
        .RegWrite_E(RegWrite_E),        
        .ImmSrc(ImmSrc),               
        .ALUSrc(ALUSrc),
        .MemWrite_E(MemWrite_E),      
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp)
    );

    ALU_Decoder alu_decoder(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),                     
        .ALUControl(ALUControl)
    );

endmodule