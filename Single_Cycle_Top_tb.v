`timescale 1ns / 1ps
`include "define.v"

module Single_Cycle_CPU_tb;

    // 信号定义
    reg clk;
    reg rst;

    // 内部观察信号 (假设你的 Top 模块名为 Single_Cycle_Top)
    // 请根据你 Top 模块的端口名进行修改
    wire [31:0] curr_pc;
    wire [31:0] instr;
    wire [31:0] alu_out;
    wire [31:0] write_data;
    wire mem_write;
    wire reg_write;

    // 实例化 CPU 顶层
    // 这里的端口连接需要根据你的 Top 模块定义来匹配
    Single_Cycle_Top uut (
        .clk(clk),
        .rst(rst)
    );

    // 时钟生成：周期为 10ns (100MHz)
    always #5 clk = ~clk;

    // 测试流程
    initial begin
        // 初始化信号
        clk = 0;
        rst = 0; // 低电平复位有效

        // 1. 发送复位脉冲
        $display("=====================================================");
        $display("开始测试 RISC-V 单周期 CPU...");
        $display("=====================================================");
        
        #2 rst = 0;   // 保持复位
        #15 rst = 1;  // 释放复位 (在时钟边沿之外释放)

        $display(" Time |    PC    |   Instr  | ALU_Res  | MemW | RegW | Jump");
        $display("-----------------------------------------------------");

        // 2. 运行仿真
        // 仿真时长取决于你的程序长度
        #1000; 

        $display("=====================================================");
        $display("仿真结束，请检查上述日志与预期结果是否相符。");
        $display("=====================================================");
        $finish;
    end

    // 3. 核心日志记录逻辑：在下降沿采样
    // 这样看到的 PC 和 Instr 就是当前周期正在执行的那一条
    always @(negedge clk) begin
        if (rst) begin
            $display("%5d | %h | %h | %h |  %b   |  %b   |  %b", 
                     $time, 
                     uut.PC_Current,         // 当前 PC
                     uut.Instr,      // 指令
                     uut.ALU_Out,    // ALU 结果
                     uut.MemWrite,   // 内存写使能
                     uut.RegWrite,   // 寄存器写使能
                     uut.PCSrc        // 跳转控制信号
            );

            // 如果有特定的 SW 指令，打印详细内存写入信息
            if (uut.MemWrite) begin
                $display("[SW] 地址:%h | 写入数据:%h", uut.ALU_Out, uut.RD2);
            end
            
            // 如果有特定的 LW 指令，打印详细读回信息
            if (uut.sel_wb == `WB_MEM && uut.RegWrite) begin
                $display("[LW] 地址:%h | 读回数据:%h", uut.ALU_Out, uut.Mem_Data);
            end
            $display("-----------------------------------------------------");
        end
    end

endmodule