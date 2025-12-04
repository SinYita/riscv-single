`include "define.v"

module ALU(A, B, ALUControl, Result, Zero);
   input  signed [31:0] A, B;
   input         [3:0]  ALUControl;  
   output Zero;  
   
   output reg [31:0] Result;
       
   always @(*) begin
      case (ALUControl)
      `ALU_ADD: Result = A + B;
      `ALU_SUB: Result = A - B; 
      `ALU_XOR: Result = A ^ B;
      `ALU_OR:  Result = A | B;
      `ALU_AND: Result = A & B;
      `ALU_SHIFTL: Result = A << B[4:0]; 
      `ALU_SHIFTR: Result = A >> B[4:0];  
      `ALU_SHIFTR_ARITH: Result = A >>> B[4:0];  
      `ALU_LESS_THAN_SIGNED: Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;  // SLT
      `ALU_LESS_THAN: Result = ($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0;  // SLTU
      
      `ALU_NONE: Result = A;  // Pass through A
      default: Result = A;
      endcase
   end 
   
   assign Zero = (Result == 32'b0);  

endmodule