`include "define.v"
module NPC( PC, PCSrc, IMMEXT, NPC );  // next pc module
   input  [31:0] PC;        
   input  PCSrc;    
   input  [31:0] IMMEXT;       
   output [31:0] NPC; 

   wire [31:0] PCPLUS4;
   wire [31:0] PCIMM;

   assign PCPLUS4 = PC + 4;
   assign PCIMM   = PC + IMMEXT;

    assign NPC = (PCSrc == 1'b1) ? PCIMM : PCPLUS4;

endmodule