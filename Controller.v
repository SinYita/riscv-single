`include "define.v"
`include "ALU_Decoder.v"
`include "Op_Decoder.v"

module Controller(Zero,inst, rf_we, sel_ext, alu_control, dmem_we, ResultSrc, PCSrc, funct3, funct7, alu_control);


    input Zero;
    input [31:0] inst;          
    input [2:0] funct3;        
    input [6:0] funct7;        

    
    output rf_we;           
    output alu_control;              
    output dmem_we;           
    output [2:0] ResultSrc;          
    output PCSrc;               
    output [2:0] sel_ext;       
    output [3:0] alu_control;  

    wire [2:0] ALUOp;           
    wire [6:0] Op = inst[6:0];  


    Op_Decoder main_decoder(
        .Zero(Zero),
        .inst(inst),                    
        .rf_we(rf_we),        
        .sel_ext(sel_ext),               
        .alu_control(alu_control),
        .dmem_we(dmem_we),      
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp)
    );

    ALU_Decoder alu_decoder(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),                     
        .alu_control(alu_control)
    );

endmodule