`timescale 1ns/1ps

module testbench();

    reg         clk;
    reg         rst_n;

    wire [31:0] WriteDataM;
    wire [31:0] DataAdrM;
    wire        MemWriteM;

    // 1. 实例化顶层模块
    rv_pl dut (
        .clk(clk),
        .rst_n(rst_n),
        .M_rf_wd(WriteDataM), 
        .M_alu_o(DataAdrM),   
        .M_we_dm(MemWriteM)   
    );

    // 2. 加载 memfile.hex
    initial begin
        // 注意：路径必须指向你定义存储器数组的具体位置
        // 假设在 top 模块里实例化的 imem 模块中有一个变量叫 RAM
        $readmemh("memfile.hex", dut.imem_inst.RAM); 
        
        // 如果你的数据存储器也需要初始化，可以加上：
        // $readmemh("datafile.hex", dut.dmem_inst.RAM);
    end

    // 3. 时钟生成
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // 4. 初始化与复位
    initial begin
        rst_n <= 0;
        #22; 
        rst_n <= 1;

        // 自动超时保护
        #5000;
        $display("Error: Simulation Timeout!");
        $finish;
    end

    // 5. 结果检查：根据 Harris 的测试逻辑
    always @(negedge clk) begin
        if (MemWriteM) begin
            // 检查是否在地址 104 写入了数值 25
            if (DataAdrM === 104 && WriteDataM === 25) begin
                $display("========================================");
                $display("  SUCCESS: Simulation Succeeded!");
                $display("  Value 25 written to Address 104");
                $display("========================================");
                $stop;
            end 
            // 这里的 96 是通常汇编测试中存储中间结果（如数据段起始地址）的合法位置
            else if (DataAdrM !== 96) begin
                $display("FAILURE: Unexpected Write! Addr: %h, Data: %h", DataAdrM, WriteDataM);
                $stop;
            end
        end
    end

endmodule