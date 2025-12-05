.text
.global _start

_start:
    # ===== I-TYPE IMMEDIATE OPERATIONS =====
    addi x1, x0, 10          # x1 = 10
    addi x2, x0, 5           # x2 = 5  
    addi x3, x0, 15          # x3 = 15
    
    # ===== R-TYPE ARITHMETIC OPERATIONS =====
    add  x4, x1, x2          # x4 = 10 + 5 = 15
    sub  x5, x1, x2          # x5 = 10 - 5 = 5
    
    # ===== R-TYPE LOGICAL OPERATIONS =====
    and  x6, x1, x2          # x6 = 10 & 5 = 0
    or   x7, x1, x2          # x7 = 10 | 5 = 15
    xor  x8, x1, x2          # x8 = 10 ^ 5 = 15
    
    # ===== I-TYPE LOGICAL OPERATIONS =====
    andi x9, x3, 7           # x9 = 15 & 7 = 7
    ori  x10, x1, 8          # x10 = 10 | 8 = 10 
    xori x11, x3, 7          # x11 = 15 ^ 7 = 8
    
    # ===== SHIFT OPERATIONS =====
    slli x12, x1, 1          # x12 = 10 << 1 = 20
    srli x13, x3, 1          # x13 = 15 >> 1 = 7 
    srai x14, x1, 1          # x14 = 10 >> 1 = 5
    
    # ===== COMPARISON OPERATIONS =====
    slt  x15, x2, x1         # x15 = 1 if 5 < 10 = 1
    sltu x16, x1, x2         # x16 = 1 if 10 < 5 (unsigned) = 0
    slti x17, x1, 15         # x17 = 1 if 10 < 15 = 1
    sltiu x18, x2, 3         # x18 = 1 if 5 < 3 (unsigned) = 0
    
    # ===== U-TYPE OPERATIONS =====
    lui  x19, 0x1            # x19 = 0x1000
    
    # ===== MEMORY OPERATIONS =====
    sw   x4, 100(x1)         # Store x4 (15) at mem[100+10] = mem[110]
    sw   x5, 104(x2)         # Store x5 (5) at mem[104+5] = mem[109] 
    lw   x20, 100(x1)        # Load x20 from mem[110] (should be 15)
    lw   x21, 104(x2)        # Load x21 from mem[109] (should be 5)
    
    # ===== BRANCH OPERATION (BEQ only) =====
    beq  x20, x4, success    # Should branch (15 == 15)
    addi x22, x0, 999        # Should be skipped
    addi x21, x0, 888        # Should be skipped
    
success:
    addi x22, x0, 42         # x22 = 42 
    
    # ===== JUMP OPERATION =====
    jal  x23, function       
    addi x24, x0, 100        # x24 = 100
    
    sw   x22, 8(x19)        # x22 =  42
    sw   x23, 12(x19)       # x23 = 116
    sw   x24, 16(x19)       # x24 = 100
    
end_loop:
    beq  x0, x0, end_loop    # Loop forever (BEQ x0,x0 always true)

function:
    addi x25, x0, 200        # x25 = 200 (function executed flag)