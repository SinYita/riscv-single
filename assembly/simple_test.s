# RISC-V 简化测试程序
# 适用于单周期CPU的基础功能测试

.text
.globl _start

_start:
    # 基础立即数操作测试
    addi x1, x0, 10        # x1 = 10
    addi x2, x0, 20        # x2 = 20
    
    # R型指令测试
    add  x3, x1, x2        # x3 = x1 + x2 = 30
    sub  x4, x2, x1        # x4 = x2 - x1 = 10
    
    # 逻辑操作测试
    xor  x5, x1, x2        # x5 = x1 XOR x2
    or   x6, x1, x2        # x6 = x1 OR x2  
    and  x7, x1, x2        # x7 = x1 AND x2
    
    # 立即数逻辑操作
    xori x8, x1, 15        # x8 = x1 XOR 15
    ori  x9, x1, 7         # x9 = x1 OR 7
    andi x10, x1, 14       # x10 = x1 AND 14
    
    # 移位操作测试
    slli x11, x1, 2        # x11 = x1 << 2
    srli x12, x3, 1        # x12 = x3 >> 1
    
    # 比较操作
    slt  x13, x1, x2       # x13 = (x1 < x2) ? 1 : 0
    sltu x14, x1, x2       # x14 = (x1 < x2 unsigned) ? 1 : 0
    
    # 内存操作测试
    addi x15, x0, 100      # x15 = 内存地址
    sw   x3, 0(x15)        # 存储x3到内存
    lw   x16, 0(x15)       # 从内存加载到x16
    
    # 上位立即数
    lui  x17, 0x1234       # x17 = 0x12340000
    
    # 简单分支测试
    beq  x1, x1, branch1   # x1 == x1，应该跳转
    addi x18, x0, 999      # 不应执行
    
branch1:
    addi x18, x0, 100      # x18 = 100，标记跳转成功
    
    # 程序结束
end:
    beq  x0, x0, end       # 无限循环