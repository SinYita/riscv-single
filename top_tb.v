`timescale 1ns/1ps

module rv_mc_tb();
    reg clk;
    reg rst;

    rv_mc dut (
        .clk(clk),
        .rst(rst)
    );

    always begin
        clk = 1; #100;
        clk = 0; #100;
    end

    initial begin
        rst = 0; // assert reset

        $readmemh("./memfile.hex", dut.MEM.RAM);

        #15;         
        rst = 1;    

    end

    always @(posedge clk) begin
        if (rst) begin
            $display("%0d\t%h\t%h\t%h", $time, dut.DP.pc, dut.DP.instr, dut.DP.result);
        end
    end

    reg [31:0] cycle_cnt;
    initial cycle_cnt = 0;

    always @(posedge clk) begin
        if (rst) cycle_cnt <= cycle_cnt + 1;
    end

    always @(posedge clk) begin
        if (rst) begin
            if (dut.DP.pc >= 32'h58) begin
                $display("--------------------------------------------------");
                $display("Simulation Finished: PC reached %h after %0d cycles.", dut.DP.pc, cycle_cnt);
                $display("Final regs: x1=%h x2=%h x3=%h x4=%h x5=%h", dut.DP.rf.Register[1], dut.DP.rf.Register[2], dut.DP.rf.Register[3], dut.DP.rf.Register[4], dut.DP.rf.Register[5]);
                $display("Mem[0]=%h", dut.MEM.RAM[0]);
                $stop;
            end
            if (cycle_cnt > 10000) begin
                $display("Timeout after %0d cycles, PC=%h", cycle_cnt, dut.DP.pc);
                $stop;
            end
        end
    end

endmodule