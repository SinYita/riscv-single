`include "defines.v"
module NPC( PC, PCSrc, IMM, NPC );  // next pc module
   input  [31:0] PC;        // pc
   input  [2:0]  PCSrc;     // next pc operation
   input  [31:0] IMM;       // immediate
   output reg [31:0] NPC;   // next pc
   
   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; // pc + 4
   
   always @(*) begin
      case (PCSrc)
          `NPC_PLUS4:  NPC = PCPLUS4;   // NPC computes addr
          `NPC_BRANCH: NPC = PC+IMM;    //B type, NPC computes addr
          `NPC_JUMP:   NPC = PC+IMM;    //J type, NPC computes 
          default:     NPC = PCPLUS4;
      endcase
   end 
   
endmodule