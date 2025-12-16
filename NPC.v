`include "define.v"
module NPC( PC, PCSrc, IMMEXT, NPC );  // next pc module
   input  [31:0] PC;        
   input  PCSrc;    
   input  [31:0] IMMEXT;       
   output reg [31:0] NPC;   
   
   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; 
   
   always @(*) begin
      case (PCSrc)
          `PC_NOJUMP:  NPC = PCPLUS4;   // NPC computes addr
          `PC_J_OFFSET: NPC = PC+IMMEXT;    //B type, NPC computes addr
          default:     NPC = PCPLUS4;
      endcase
   end
   
endmodule