`timescale 1ns / 1ps
`include "define.v"

module Controller_tb;

    // Testbench signals
    reg Zero;
    reg [31:0] inst;
    reg [2:0] funct3;
    reg [6:0] funct7;
    
    wire RegWrite_E;
    wire ALUSrc;
    wire MemWrite_E;
    wire ResultSrc;
    wire PCSrc;
    wire [2:0] ImmSrc;
    wire [3:0] ALUControl;
    
    // Test tracking
    reg test_passed;
    integer test_count;
    
    // Expected values
    reg exp_RegWrite_E, exp_ALUSrc, exp_MemWrite_E, exp_ResultSrc, exp_PCSrc;
    reg [2:0] exp_ImmSrc;
    reg [3:0] exp_ALUControl;
    
    // Instantiate the Controller
    Controller uut (
        .Zero(Zero),
        .inst(inst),
        .RegWrite_E(RegWrite_E),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite_E(MemWrite_E),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );
    
    // VCD dump
    initial begin
        $dumpfile("Controller_tb.vcd");
        $dumpvars(0, Controller_tb);
    end
    
    // Helper task to check results
    task check_signals;
        input [255:0] test_name;
        begin
            if (RegWrite_E == exp_RegWrite_E && 
                ImmSrc == exp_ImmSrc &&
                ALUSrc == exp_ALUSrc &&
                MemWrite_E == exp_MemWrite_E &&
                ResultSrc == exp_ResultSrc &&
                PCSrc == exp_PCSrc &&
                ALUControl == exp_ALUControl) begin
                $display("✓ PASS: %s", test_name);
            end else begin
                $display("✗ FAIL: %s", test_name);
                $display("  Expected: RegW=%b ImmSrc=%b ALUSrc=%b MemW=%b ResltSrc=%b PCSrc=%b ALUCtrl=%b",
                         exp_RegWrite_E, exp_ImmSrc, exp_ALUSrc, exp_MemWrite_E, exp_ResultSrc, exp_PCSrc, exp_ALUControl);
                $display("  Got:      RegW=%b ImmSrc=%b ALUSrc=%b MemW=%b ResltSrc=%b PCSrc=%b ALUCtrl=%b", 
                         RegWrite_E, ImmSrc, ALUSrc, MemWrite_E, ResultSrc, PCSrc, ALUControl);
                test_passed = 0;
            end
            test_count = test_count + 1;
        end
    endtask
    
    // Test sequence
    initial begin
        $display("=== Controller Module Testbench ===");
        $display("Testing instruction decoding and control signal generation");
        
        test_passed = 1;
        test_count = 0;
        
        // Initialize signals
        Zero = 0;
        inst = 32'h0;
        funct3 = 3'b0;
        funct7 = 7'b0;
        #10;
        
        $display("\n--- Test 1: R-Type Instructions ---");
        
        // Test 1.1: ADD (R-type)
        // Instruction format: funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b000, 5'b00011, `OPCODE_RTYPE};  // ADD x3, x1, x2
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_ADD;
        #10;
        check_signals("R-type ADD");
        
        // Test 1.2: SUB (R-type)
        inst = {7'b0100000, 5'b00010, 5'b00001, 3'b000, 5'b00011, `OPCODE_RTYPE};  // SUB x3, x1, x2
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_SUB;
        #10;
        check_signals("R-type SUB");
        
        // Test 1.3: XOR (R-type)
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b100, 5'b00011, `OPCODE_RTYPE};  // XOR x3, x1, x2
        funct3 = 3'b100;
        funct7 = 7'b0000000;
        exp_ALUControl = `ALU_XOR;
        #10;
        check_signals("R-type XOR");
        
        // Test 1.4: OR (R-type)
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b110, 5'b00011, `OPCODE_RTYPE};  // OR x3, x1, x2
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        exp_ALUControl = `ALU_OR;
        #10;
        check_signals("R-type OR");
        
        // Test 1.5: AND (R-type)
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b111, 5'b00011, `OPCODE_RTYPE};  // AND x3, x1, x2
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        exp_ALUControl = `ALU_AND;
        #10;
        check_signals("R-type AND");
        
        $display("\n--- Test 2: I-Type Instructions ---");
        
        // Test 2.1: ADDI (I-type)
        inst = {12'h123, 5'b00001, 3'b000, 5'b00010, `OPCODE_ITYPE};  // ADDI x2, x1, 0x123
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_ADD;
        #10;
        check_signals("I-type ADDI");
        
        // Test 2.2: XORI (I-type)
        inst = {12'h456, 5'b00001, 3'b100, 5'b00010, `OPCODE_ITYPE};  // XORI x2, x1, 0x456
        funct3 = 3'b100;
        exp_ALUControl = `ALU_XOR;
        #10;
        check_signals("I-type XORI");
        
        // Test 2.3: SLLI (I-type shift left)
        inst = {7'b0000000, 5'b00100, 5'b00001, 3'b001, 5'b00010, `OPCODE_ITYPE};  // SLLI x2, x1, 4
        funct3 = 3'b001;
        funct7 = 7'b0000000;
        exp_ALUControl = `ALU_SHIFTL;
        #10;
        check_signals("I-type SLLI");
        
        $display("\n--- Test 3: Load Instructions ---");
        
        // Test 3.1: LW (Load Word)
        inst = {12'h100, 5'b00001, 3'b010, 5'b00010, `OPCODE_LOAD};  // LW x2, 0x100(x1)
        funct3 = 3'b010;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_MEM; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_ADD;
        #10;
        check_signals("Load LW");
        
        $display("\n--- Test 4: Store Instructions ---");
        
        // Test 4.1: SW (Store Word)
        inst = {7'b0000001, 5'b00010, 5'b00001, 3'b010, 5'b00000, `OPCODE_STORE};  // SW x2, 0x20(x1)
        funct3 = 3'b010;
        exp_RegWrite_E = `NO; exp_ImmSrc = `Ext_ImmS; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `YES; exp_ResultSrc = `RWD_MEM; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_ADD;
        #10;
        check_signals("Store SW");
        
        $display("\n--- Test 5: Branch Instructions ---");
        
        // Test 5.1: BEQ taken (Zero = 1)
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b000, 5'b01000, `OPCODE_BRANCH};  // BEQ x1, x2, offset
        funct3 = 3'b000;
        Zero = 1;  // Branch condition true
        exp_RegWrite_E = `NO; exp_ImmSrc = `Ext_ImmB; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_J_OFFSET;
        exp_ALUControl = `ALU_XOR;
        #10;
        check_signals("Branch BEQ taken");
        
        // Test 5.2: BEQ not taken (Zero = 0)
        Zero = 0;  // Branch condition false
        exp_PCSrc = `PC_NOJUMP;  // Only PCSrc changes
        #10;
        check_signals("Branch BEQ not taken");
        
        $display("\n--- Test 6: Jump Instructions ---");
        
        // Test 6.1: JAL (Jump and Link)
        inst = {20'h12345, `OPCODE_JAL};  // JAL x1, offset
        Zero = 0;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmJ; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_PC_; exp_PCSrc = `PC_J_OFFSET;
        exp_ALUControl = `ALU_NONE;
        #10;
        check_signals("Jump JAL");
        
        $display("\n--- Test 7: U-Type Instructions ---");
        
        // Test 7.1: LUI (Load Upper Immediate)
        inst = {20'hABCDE, 5'b00001, `OPCODE_LUI};  // LUI x1, 0xABCDE
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmU; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_IMM; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_NONE;
        #10;
        check_signals("U-type LUI");
        
        $display("\n--- Test 8: Edge Cases and Error Conditions ---");
        
        // Test 8.1: Invalid opcode (should default to NOP-like behavior)
        inst = {25'h0, 7'b1111111};  // Invalid opcode
        exp_RegWrite_E = `NO; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_ADD;  // Default case in Op_Decoder sets ALUOp to ALUOP_ITYPE -> ALU_ADD
        #10;
        check_signals("Invalid opcode");
        
        // Test 8.2: R-type with invalid funct3/funct7
        inst = {7'b1111111, 5'b00010, 5'b00001, 3'b111, 5'b00011, `OPCODE_RTYPE};  // Invalid funct7
        funct3 = 3'b111;  // Valid (AND)
        funct7 = 7'b1111111;  // Invalid
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_AND;  // Should still decode correctly
        #10;
        check_signals("R-type with invalid funct7");
        
        $display("\n--- Test 9: Shift Instructions with funct7 variations ---");
        
        // Test 9.1: SRL (Shift Right Logical) 
        inst = {7'b0000000, 5'b00100, 5'b00001, 3'b101, 5'b00010, `OPCODE_RTYPE};  // SRL x2, x1, x4
        funct3 = 3'b101;
        funct7 = 7'b0000000;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_SHIFTR;
        #10;
        check_signals("R-type SRL");
        
        // Test 9.2: SRA (Shift Right Arithmetic)
        inst = {7'b0100000, 5'b00100, 5'b00001, 3'b101, 5'b00010, `OPCODE_RTYPE};  // SRA x2, x1, x4
        funct3 = 3'b101;
        funct7 = 7'b0100000;
        exp_ALUControl = `ALU_SHIFTR_ARITH;
        #10;
        check_signals("R-type SRA");
        
        $display("\n--- Test 10: Comparison Instructions ---");
        
        // Test 10.1: SLT (Set Less Than)
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b010, 5'b00011, `OPCODE_RTYPE};  // SLT x3, x1, x2
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_REG;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_LESS_THAN_SIGNED;
        #10;
        check_signals("R-type SLT");
        
        // Test 10.2: SLTU (Set Less Than Unsigned)
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b011, 5'b00011, `OPCODE_RTYPE};  // SLTU x3, x1, x2
        funct3 = 3'b011;
        funct7 = 7'b0000000;
        exp_ALUControl = `ALU_LESS_THAN;
        #10;
        check_signals("R-type SLTU");
        
        // Test 10.3: SLTI (Set Less Than Immediate)
        inst = {12'h789, 5'b00001, 3'b010, 5'b00010, `OPCODE_ITYPE};  // SLTI x2, x1, 0x789
        funct3 = 3'b010;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_LESS_THAN_SIGNED;
        #10;
        check_signals("I-type SLTI");
        
        $display("\n--- Test 11: Complex Instruction Patterns ---");
        
        // Test all instruction types in sequence to verify no state retention
        
        // R-type -> I-type transition
        inst = {7'b0000000, 5'b00010, 5'b00001, 3'b000, 5'b00011, `OPCODE_RTYPE};  // ADD
        funct3 = 3'b000; funct7 = 7'b0000000;
        #5;
        
        inst = {12'h200, 5'b00001, 3'b000, 5'b00010, `OPCODE_ITYPE};  // ADDI
        funct3 = 3'b000;
        exp_RegWrite_E = `YES; exp_ImmSrc = `Ext_ImmI; exp_ALUSrc = `ALU_IMM;
        exp_MemWrite_E = `NO; exp_ResultSrc = `RWD_ALU; exp_PCSrc = `PC_NOJUMP;
        exp_ALUControl = `ALU_ADD;
        #5;
        check_signals("R-type to I-type transition");
        
        // Final results
        $display("\n=== Controller Testbench Complete ===");
        if (test_passed) begin
            $display("🎉 ALL TESTS PASSED! (%0d/%0d)", test_count, test_count);
        end else begin
            $display("❌ SOME TESTS FAILED!");
        end
        
        #50;
        $finish;
    end

endmodule