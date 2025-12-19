`timescale 1ns/1ps

module rv_mc_tb();
    reg clk;
    reg rst;
    // helpers for JAL check
    integer jal_rd;
    reg [31:0] jal_returned;
    reg [31:0] jal_expect;

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

    // Snapshot of register file to detect changes
    reg [31:0] prev_regs [31:0];

    // initialize snapshot after reset release
    integer ri;
    initial begin
        for (ri = 0; ri < 32; ri = ri + 1) prev_regs[ri] = 32'h0;
    end

    // On every cycle where Register File write enable is asserted, compare and print changed registers
    always @(posedge clk) begin
        if (rst) begin
            if (dut.CTRL.we_rf) begin
                $display("%0t PC=%h instr=%h ALUOp=%b funct3=%b f7b5=%b ALUctrl=%b", $time, dut.DP.pc, dut.DP.instr, dut.CTRL.alu_op, dut.DP.instr[14:12], dut.DP.instr[30], dut.CTRL.alu_control);
                // compare registers and print only the ones that changed
                for (ri = 0; ri < 32; ri = ri + 1) begin
                    if (dut.DP.rf.Register[ri] !== prev_regs[ri]) begin
                        $display("%0t REG[%0d] changed: %h -> %h", $time, ri, prev_regs[ri], dut.DP.rf.Register[ri]);
                    end
                end
                // If this write-back is from memory (LW), sel_result==2'b01
                if (dut.CTRL.sel_result == 2'b01) begin
                    $display("%0t LOAD: rd=%0d <- MEM[%h] = %h", $time, dut.DP.instr[11:7], dut.DP.addr, dut.DP.result);
                end
                // If this write-back corresponds to JAL (opcode 1101111)
                if (dut.DP.instr[6:0] == 7'b1101111) begin
                    jal_rd = dut.DP.instr[11:7];
                    jal_returned = dut.DP.rf.Register[jal_rd];
                    jal_expect = dut.DP.old_pc + 32'd4;
                    $display("%0t JAL: rd=x%0d returned=%h old_pc=%h expect(old_pc+4)=%h imm_ext=%h PC=%h", $time, jal_rd, jal_returned, dut.DP.old_pc, jal_expect, dut.DP.imm_ext, dut.DP.pc);
                    if (jal_returned === jal_expect)
                        $display("%0t JAL status: RETURN OK", $time);
                    else
                        $display("%0t JAL status: RETURN MISMATCH", $time);
                end
                // update snapshot
                for (ri = 0; ri < 32; ri = ri + 1) prev_regs[ri] = dut.DP.rf.Register[ri];
            end
        end
    end

    // Print memory writes when they occur
    always @(posedge clk) begin
        if (rst && dut.CTRL.we_mem) begin
            $display("%0t STORE: MEM[%h] <- %h (from rs2)", $time, dut.DP.addr, dut.DP.write_data);
        end
    end

endmodule