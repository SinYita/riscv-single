`timescale 1ns / 1ps
`include "../src/define.v"
`include "../src/Single_Cycle_Top.v"

module Single_Cycle_Top_tb;

    reg clk, rst;
    
    integer cycle_count;
    
    reg [31:0] prev_pc;
    reg [31:0] prev_instr;
    
    wire [31:0] PC_current;
    wire [31:0] instruction;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] reg_write_data;
    wire [31:0] immediate;
    wire RegWrite, MemWrite;
    wire [31:0] memory_read_data;
    wire [31:0] alu_result;
    wire [2:0] result_src;
    
    Single_Cycle_Top cpu (
        .clk(clk),
        .rst(rst)
    );
    
    assign PC_current = cpu.PC_Top;
    assign instruction = cpu.RD_Instr;
    assign reg_data1 = cpu.RD1_Top;
    assign reg_data2 = cpu.RD2_Top;
    assign reg_write_data = cpu.Result;
    assign immediate = cpu.Imm_Ext_Top;
    assign RegWrite = cpu.RegWrite;
    assign MemWrite = cpu.MemWrite;
    assign memory_read_data = cpu.ReadData;
    assign alu_result = cpu.ALUResult;
    assign result_src = cpu.ResultSrc;
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("Single_Cycle_Top_tb.vcd");
        $dumpvars(0, Single_Cycle_Top_tb);
    end
    
    task display_registers;
        integer i;
        begin
            $display("    Register Contents:");
            for (i = 0; i < 32; i = i + 1) begin
                if (cpu.Register_File.Register[i] !== 32'h00000000) begin
                    $display("      R%0d = 0x%08x (%0d)", i, cpu.Register_File.Register[i], cpu.Register_File.Register[i]);
                end
            end
        end
    endtask
    
    task decode_instruction;
        input [31:0] pc;
        input [31:0] instr;
        reg [6:0] opcode;
        reg [4:0] rd, rs1, rs2;
        reg [2:0] funct3;
        reg [6:0] funct7;
        reg [31:0] imm;
        begin
            opcode = instr[6:0];
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = instr[24:20];
            funct3 = instr[14:12];
            funct7 = instr[31:25];
            
            $display("  PC: 0x%08x | Instruction: 0x%08x", pc, instr);
            
            case (opcode)
                `OPCODE_RTYPE: begin
                    case ({funct7, funct3})
                        10'b0000000000: $display("    ADD R%0d, R%0d, R%0d  (R%0d = 0x%08x + 0x%08x)", rd, rs1, rs2, rd, reg_data1, reg_data2);
                        10'b0100000000: $display("    SUB R%0d, R%0d, R%0d  (R%0d = 0x%08x - 0x%08x)", rd, rs1, rs2, rd, reg_data1, reg_data2);
                        10'b0000000100: $display("    XOR R%0d, R%0d, R%0d  (R%0d = 0x%08x ^ 0x%08x)", rd, rs1, rs2, rd, reg_data1, reg_data2);
                        10'b0000000110: $display("    OR  R%0d, R%0d, R%0d  (R%0d = 0x%08x | 0x%08x)", rd, rs1, rs2, rd, reg_data1, reg_data2);
                        10'b0000000111: $display("    AND R%0d, R%0d, R%0d  (R%0d = 0x%08x & 0x%08x)", rd, rs1, rs2, rd, reg_data1, reg_data2);
                        10'b0000000001: $display("    SLL R%0d, R%0d, R%0d  (R%0d = 0x%08x << %0d)", rd, rs1, rs2, rd, reg_data1, reg_data2[4:0]);
                        10'b0000000101: $display("    SRL R%0d, R%0d, R%0d  (R%0d = 0x%08x >> %0d)", rd, rs1, rs2, rd, reg_data1, reg_data2[4:0]);
                        10'b0100000101: $display("    SRA R%0d, R%0d, R%0d  (R%0d = 0x%08x >>> %0d)", rd, rs1, rs2, rd, reg_data1, reg_data2[4:0]);
                        10'b0000000010: $display("    SLT R%0d, R%0d, R%0d  (R%0d = %0d < %0d)", rd, rs1, rs2, rd, $signed(reg_data1), $signed(reg_data2));
                        10'b0000000011: $display("    SLTU R%0d, R%0d, R%0d (R%0d = %0d < %0d)", rd, rs1, rs2, rd, reg_data1, reg_data2);
                        default: $display("    Unknown R-type instruction");
                    endcase
                end
                
                `OPCODE_ITYPE: begin
                    case (funct3)
                        3'b000: $display("    ADDI R%0d, R%0d, %0d  (R%0d = 0x%08x + %0d)", rd, rs1, $signed(immediate), rd, reg_data1, $signed(immediate));
                        3'b100: $display("    XORI R%0d, R%0d, %0d  (R%0d = 0x%08x ^ 0x%08x)", rd, rs1, $signed(immediate), rd, reg_data1, immediate);
                        3'b110: $display("    ORI  R%0d, R%0d, %0d  (R%0d = 0x%08x | 0x%08x)", rd, rs1, $signed(immediate), rd, reg_data1, immediate);
                        3'b111: $display("    ANDI R%0d, R%0d, %0d  (R%0d = 0x%08x & 0x%08x)", rd, rs1, $signed(immediate), rd, reg_data1, immediate);
                        3'b001: $display("    SLLI R%0d, R%0d, %0d  (R%0d = 0x%08x << %0d)", rd, rs1, immediate[4:0], rd, reg_data1, immediate[4:0]);
                        3'b101: begin
                            if (funct7[5]) 
                                $display("    SRAI R%0d, R%0d, %0d  (R%0d = 0x%08x >>> %0d)", rd, rs1, immediate[4:0], rd, reg_data1, immediate[4:0]);
                            else 
                                $display("    SRLI R%0d, R%0d, %0d  (R%0d = 0x%08x >> %0d)", rd, rs1, immediate[4:0], rd, reg_data1, immediate[4:0]);
                        end
                        3'b010: $display("    SLTI R%0d, R%0d, %0d  (R%0d = %0d < %0d)", rd, rs1, $signed(immediate), rd, $signed(reg_data1), $signed(immediate));
                        3'b011: $display("    SLTIU R%0d, R%0d, %0d (R%0d = %0d < %0d)", rd, rs1, immediate, rd, reg_data1, immediate);
                        default: $display("    Unknown I-type instruction");
                    endcase
                end
                
                `OPCODE_LOAD: begin
                    $display("    LW R%0d, %0d(R%0d)  (R%0d = MEM[0x%08x])", rd, $signed(immediate), rs1, rd, reg_data1 + $signed(immediate));
                    $display("      Debug: ALU_Result=0x%08x, MemReadData=0x%08x, ResultSrc=%0d", alu_result, memory_read_data, result_src);
                end
                `OPCODE_STORE: begin
                    $display("    SW R%0d, %0d(R%0d)  (MEM[0x%08x] = 0x%08x)", rs2, $signed(immediate), rs1, reg_data1 + $signed(immediate), reg_data2);
                    $display("      Debug: ALU_Result=0x%08x, ResultSrc=%0d", alu_result, result_src);
                end
                `OPCODE_BRANCH: $display("    BEQ R%0d, R%0d, %0d (Branch if 0x%08x == 0x%08x)", rs1, rs2, $signed(immediate), reg_data1, reg_data2);
                `OPCODE_JAL:   $display("    JAL R%0d, %0d  (R%0d = PC+4, PC = PC + %0d)", rd, $signed(immediate), rd, $signed(immediate));
                `OPCODE_LUI:   $display("    LUI R%0d, %0d  (R%0d = 0x%08x)", rd, immediate[31:12], rd, immediate);
                default:       $display("    UNKNOWN opcode 0x%02x", opcode);
            endcase
            
            if (RegWrite && rd != 0) begin
                $display("    -> Will write 0x%08x to R%0d", reg_write_data, rd);
            end
            if (MemWrite) begin
                $display("    -> Will write 0x%08x to memory address 0x%08x", reg_data2, cpu.ALUResult);
            end
        end
    endtask
    
    initial begin
        $display("Executing program from memfile.hex with register monitoring\n");
        
        cycle_count = 0;
        
        rst = 0;
        #15;
        $display("During Reset: PC = 0x%08x", PC_current);
        rst = 1;
        #1;
        
        $display("=== Starting CPU Execution ===\n");
        
        decode_instruction(PC_current, instruction);
        
        @(posedge clk);
        #1;
        
        if (RegWrite && instruction[11:7] != 0) begin
            $display("    Result: R%0d = 0x%08x", instruction[11:7], reg_write_data);
        end
        
        display_registers();
        cycle_count = cycle_count + 1;
        $display("");
        
        begin: repeat_loop
        repeat(50) begin
            $display("Cycle %0d:", cycle_count);
            decode_instruction(PC_current, instruction);
            
            @(posedge clk);
            #1;
            
            if (RegWrite && instruction[11:7] != 0) begin
                $display("    Result: R%0d = 0x%08x", instruction[11:7], reg_write_data);
            end
            
            if (cycle_count % 5 == 0 || RegWrite) begin
                display_registers();
            end
            cycle_count = cycle_count + 1;
            $display("");
            
            if (instruction == 32'h00000063 || instruction == 32'h00000000 || PC_current >= 32'h200 || instruction === 32'hxxxxxxxx) begin
                // if (instruction == 32'h00000063)
                //     $display("Program terminated with infinite loop (BEQ x0, x0, 0)");
                // else if (instruction == 32'h00000000)
                //     $display("Program terminated - reached uninitialized memory (NOP)");
                // else if (instruction === 32'hxxxxxxxx)
                //     $display("Program terminated - reached uninitialized memory (unknown instruction)");
                // else
                //     $display("Program terminated - PC exceeded expected range");
                disable repeat_loop;
            end
            
            @(negedge clk);
        end
        end
        
        $display("\n=== Final Register State ===");
        display_registers();
        
        $finish;
    end

endmodule