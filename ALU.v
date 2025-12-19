`include "define.v"

module ALU(
    input  signed [31:0] A, B,
    input         [3:0]  alu_control,  
    output [31:0]        Result,
    output               Zero
);
   
   reg [31:0] res;
       
   always @(*) begin
      case (alu_control)
          `ALU_ADD:         res = A + B;
          `ALU_SUB:         res = A - B; 
          `ALU_XOR:         res = A ^ B;
          `ALU_OR:          res = A | B;
          `ALU_AND:         res = A & B;
          `ALU_SHIFTL:      res = A << B[4:0]; 
          `ALU_SHIFTR:      res = A >> B[4:0];  
          `ALU_SHIFTR_ARITH: res = $signed(A) >>> B[4:0];
          
          `ALU_LESS_THAN_SIGNED: res = (A < B) ? 32'b1 : 32'b0;  
          
          `ALU_LESS_THAN:        res = ($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0; 
          
          `ALU_COPY_B:      res = B; 
          
          `ALU_NONE:        res = A;
          default:          res = A;
      endcase
   end 
   
   assign Result = res;
   assign Zero = (res == 32'b0);  

endmodule