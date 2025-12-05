# Comprehensive RISC-V Single Cycle CPU Test
# Tests all implemented operations: R-type, I-type, U-type, S-type, B-type, J-type
.text
.global _start

_start:
    # ===== I-TYPE IMMEDIATE OPERATIONS =====
    addi x1, x0, 15          # x1 = 15
    addi x2, x0, 7           # x2 = 7  
    addi x3, x0, -5          # x3 = -5 (test negative immediate)
    addi x4, x0, 255         # x4 = 255 (test large positive)
    
    # ===== R-TYPE ARITHMETIC OPERATIONS =====
    add  x5, x1, x2          # x5 = 15 + 7 = 22
    sub  x6, x1, x2          # x6 = 15 - 7 = 8
    sub  x7, x2, x1          # x7 = 7 - 15 = -8 (test negative result)
    
    # ===== R-TYPE LOGICAL OPERATIONS =====
    and  x8, x1, x2          # x8 = 15 & 7 = 7 (binary: 1111 & 0111 = 0111)
    or   x9, x1, x2          # x9 = 15 | 7 = 15 (binary: 1111 | 0111 = 1111)
    xor  x10, x1, x2         # x10 = 15 ^ 7 = 8 (binary: 1111 ^ 0111 = 1000)
    
    # ===== I-TYPE LOGICAL OPERATIONS =====
    andi x11, x1, 0x0F       # x11 = 15 & 15 = 15 (mask lower 4 bits)
    ori  x12, x1, 0xF0       # x12 = 15 | 240 = 255 (set upper 4 bits)
    xori x13, x1, 0xFF       # x13 = 15 ^ 255 = 240 (flip all 8 bits)
    
    # ===== SHIFT OPERATIONS =====
    slli x14, x1, 2          # x14 = 15 << 2 = 60 (shift left logical)
    srli x15, x4, 3          # x15 = 255 >> 3 = 31 (shift right logical)
    srai x16, x3, 1          # x16 = -5 >> 1 = -3 (shift right arithmetic)
    
    # ===== U-TYPE OPERATIONS =====
    lui  x17, 0x12345        # x17 = 0x12345000 (load upper immediate)
    auipc x18, 0x1000        # x18 = PC + 0x1000000 (add upper imm to PC)
    
    # ===== MEMORY BASE ADDRESS SETUP =====
    addi x19, x0, 0x400      # x19 = 1024 (memory base address)
    
    # ===== S-TYPE STORE OPERATIONS =====
    sw   x5, 0(x19)          # Store x5 (22) at mem[1024]
    sw   x6, 4(x19)          # Store x6 (8) at mem[1028]
    sw   x7, 8(x19)          # Store x7 (-8) at mem[1032]
    sw   x8, 12(x19)         # Store x8 (7) at mem[1036]
    
    # ===== I-TYPE LOAD OPERATIONS =====
    lw   x20, 0(x19)         # Load x20 from mem[1024] (should be 22)
    lw   x21, 4(x19)         # Load x21 from mem[1028] (should be 8)
    lw   x22, 8(x19)         # Load x22 from mem[1032] (should be -8)
    lw   x23, 12(x19)        # Load x23 from mem[1036] (should be 7)
    
    # ===== B-TYPE BRANCH OPERATIONS =====
    # Test BEQ (branch if equal)
    beq  x20, x5, branch1    # Should branch (22 == 22)
    addi x24, x0, 999        # Should be skipped
    
branch1:
    addi x24, x0, 1          # x24 = 1 (branch taken flag)
    
    # Test BNE (branch if not equal)  
    bne  x21, x7, branch2    # Should branch (8 != -8)
    addi x25, x0, 999        # Should be skipped
    
branch2:
    addi x25, x0, 2          # x25 = 2 (branch taken flag)
    
    # Test BLT (branch if less than)
    blt  x7, x6, branch3     # Should branch (-8 < 8)
    addi x26, x0, 999        # Should be skipped
    
branch3:
    addi x26, x0, 3          # x26 = 3 (branch taken flag)
    
    # Test BGE (branch if greater equal)
    bge  x6, x7, branch4     # Should branch (8 >= -8)
    addi x27, x0, 999        # Should be skipped
    
branch4:
    addi x27, x0, 4          # x27 = 4 (branch taken flag)
    
    # ===== J-TYPE JUMP OPERATIONS =====
    jal  x28, function       # Jump to function, save return address
    addi x29, x0, 100        # x29 = 100 (executed after return)
    
    # ===== COMPARISON AND SET OPERATIONS =====
    slt  x30, x7, x6         # x30 = 1 if x7 < x6 (-8 < 8) = 1
    sltu x31, x1, x2         # x31 = 1 if x1 < x2 unsigned (15 < 7) = 0
    slti x1, x7, 0           # x1 = 1 if x7 < 0 (-8 < 0) = 1
    sltiu x2, x1, 2          # x2 = 1 if x1 < 2 unsigned (1 < 2) = 1
    
    # Final verification - store test results
    sw   x24, 16(x19)        # Store BEQ result
    sw   x25, 20(x19)        # Store BNE result  
    sw   x26, 24(x19)        # Store BLT result
    sw   x27, 28(x19)        # Store BGE result
    sw   x28, 32(x19)        # Store JAL return address
    sw   x29, 36(x19)        # Store post-function value
    sw   x30, 40(x19)        # Store SLT result
    sw   x31, 44(x19)        # Store SLTU result
    
    # Infinite loop to end program
end_loop:
    beq  x0, x0, end_loop    # Loop forever

function:
    # Simple function to test JAL/JALR
    addi x3, x3, 10          # Modify x3 inside function
    jalr x0, x28, 0          # Return to caller (x28 has return address)