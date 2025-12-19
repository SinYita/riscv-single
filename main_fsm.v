module main_fsm(
    input clk,
    input rst,
    input [6:0] op,
    output reg [1:0] sel_alu_src_a,
    output reg [1:0] sel_alu_src_b,
    output reg [1:0] alu_op,
    output reg [1:0] sel_result,
    output reg sel_mem_addr,
    output reg we_mem,
    output reg pc_update,
    output reg we_ir,
    output reg we_rf,     // 写回寄存器堆需要此信号
    output reg branch     // 分支指令标识
);

    localparam S0_FETCH    = 4'd0,
               S1_DECODE   = 4'd1,
               S2_EXE_ADDR = 4'd2,
               S3_MEM_RD   = 4'd3,
               S4_WB_MEM   = 4'd4,
               S5_MEM_WR   = 4'd5,
               S6_EXE_R    = 4'd6,
               S7_WB_ALU   = 4'd7,
               S8_BEQ      = 4'd8,
               S9_EXE_I    = 4'd9,
               S10_JAL     = 4'd10,
               S11_LUI     = 4'd11; // 手册要求增加对 LUI 的支持 

    reg [3:0] state, next_state;

    always @(posedge clk or negedge rst) begin
        if (!rst) state <= S0_FETCH;
        else     state <= next_state;
    end

    always @(*) begin
        case (state)
            S0_FETCH:    next_state = S1_DECODE;
            S1_DECODE: begin
                case (op)
                    `OPCODE_LW: next_state = S2_EXE_ADDR; // LW
                    `OPCODE_SW: next_state = S2_EXE_ADDR; // SW
                    `OPCODE_RTP: next_state = S6_EXE_R;    // R-type
                    `OPCODE_ITP: next_state = S9_EXE_I;    // I-type
                    `OPCODE_BEQ: next_state = S8_BEQ;      // BEQ
                    `OPCODE_JAL: next_state = S10_JAL;     // JAL
                    `OPCODE_LUI: next_state = S11_LUI;     // LUI
                    default:    next_state = S0_FETCH;
                endcase
            end
            S2_EXE_ADDR: next_state = (op == `OPCODE_LW) ? S3_MEM_RD : S5_MEM_WR;
            S3_MEM_RD:   next_state = S4_WB_MEM;
            S6_EXE_R:    next_state = S7_WB_ALU;
            S9_EXE_I:    next_state = S7_WB_ALU;
            S10_JAL:     next_state = S7_WB_ALU;
            S11_LUI:     next_state = S7_WB_ALU;
            default:     next_state = S0_FETCH; // S4, S5, S7, S8, S11 结束后回 S0
        endcase
    end
    always @(*) begin

        // set default values
        sel_alu_src_a = 2'b00; sel_alu_src_b = 2'b00; alu_op = 2'b00;
        sel_result = 2'b00; sel_mem_addr = 1'b0;
        we_mem = 1'b0; pc_update = 1'b0; we_ir = 1'b0; we_rf = 1'b0; branch = 1'b0;

        case (state)
            S0_FETCH: begin
                sel_mem_addr = 1'b0;   // A = PC
                we_ir = 1'b1;          // 写指令寄存器 
                sel_alu_src_a = 2'b00; // ALU A = PC 
                sel_alu_src_b = 2'b10; // ALU B = 4 
                alu_op = 2'b00;        // ADD [cite: 105]
                sel_result = 2'b10;    // Result = ALU Result
                pc_update = 1'b1;          // PC = PC + 4 
            end

            S1_DECODE: begin
                sel_alu_src_a = 2'b01;
                sel_alu_src_b = 2'b01;
                alu_op = 2'b00;
            end

            S2_EXE_ADDR: begin
                sel_alu_src_a = 2'b10; // ALU A = rd1_reg 
                sel_alu_src_b = 2'b01; // ALU B = ExtImm 
                alu_op = 2'b00;        // Add [cite: 109]
            end

            S3_MEM_RD: begin
                sel_result = 2'b00;    // 使用 ALUOut
                sel_mem_addr = 1'b1;   // 内存地址选 ALUOut
            end

            S4_WB_MEM: begin
                sel_result = 2'b01;    // 选择 Data Reg
                sel_mem_addr = 1'b1;   
                
                we_rf = 1'b1;          // 写回寄存器堆
            end

            S5_MEM_WR: begin
                sel_result = 2'b00;    
                sel_mem_addr = 1'b1;   
                we_mem = 1'b1;         // 执行内存写
            end

            S6_EXE_R: begin
                sel_alu_src_a = 2'b10; 
                sel_alu_src_b = 2'b00; // ALU B = rd2_reg
                alu_op = 2'b10;        // R-type ALU
            end

            S7_WB_ALU: begin
                sel_result = 2'b00;    // 选 ALUOut
                we_rf = 1'b1;          // 写回
            end

            S9_EXE_I: begin
                sel_alu_src_a = 2'b10; 
                sel_alu_src_b = 2'b01; 
                alu_op = 2'b10;        // I-type ALU
            end

            S8_BEQ: begin
                sel_alu_src_a = 2'b10;
                sel_alu_src_b = 2'b00;
                alu_op = 2'b01;        // Sub
                sel_result = 2'b00;
                branch = 1'b1;         // 触发分支判断
            end

            S10_JAL: begin
                sel_alu_src_a = 2'b01; // ALU A = PC
                sel_alu_src_b = 2'b10; // ALU B = Imm
                alu_op = 2'b00;
                sel_result = 2'b00;
                pc_update = 1'b1;          // 跳转更新 PC [cite: 114]
            end

            S11_LUI: begin
                sel_alu_src_a = 2'b11; // ALU A = 0
                sel_alu_src_b = 2'b01; // ALU B = Imm
                alu_op = 2'b11;
                sel_result = 2'b00;
                next_state = S7_WB_ALU; // 写回寄存器堆
            end
        endcase
    end
endmodule