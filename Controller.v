`include "define.v"

module Controller(
    input        Zero,          
    input [6:0]  Op,           
    input [2:0]  funct3,        
    input [6:0]  funct7,        
    
    output       rf_we,         
    output [2:0] sel_ext,       
    output       sel_alu_src_b, 
    output       dmem_we,       
    output [1:0] sel_result,    
    output       PCSrc,         
    output [3:0] alu_control    
);

    wire [1:0] ALUOp; 

    Op_Decoder main_decoder (
        .Zero(Zero),
        .Op(Op),                    
        .rf_we(rf_we),        
        .sel_ext(sel_ext),               
        .sel_alu_src_b(sel_alu_src_b),
        .dmem_we(dmem_we),      
        .sel_result(sel_result),  
        .PCSrc(PCSrc),
        .ALUOp(ALUOp)             
    );

    ALU_Decoder alu_decoder (
        .ALUOp(ALUOp),              
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)  
    );

endmodule