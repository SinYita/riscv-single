`timescale 1ns/1ps

module rv_pl_tb;
    reg clk;
    reg rst_n;
    integer cycle_cnt;
    reg [31:0] last_pc;
    integer same_pc_count;
    localparam MAX_SAME_PC = 3;

    rv_pl dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    function [63:0] get_instr_name(input [31:0] i);
        reg [6:0] op;
        reg [2:0] f3;
        reg [6:0] f7;
        begin
            op = i[6:0];
            f3 = i[14:12];
            f7 = i[31:25];
            if (i == 32'b0) get_instr_name = "NOP";
            else case (op)
                7'b0110011: begin // R-type
                    case (f3)
                        3'b000: get_instr_name = (f7[5]) ? "SUB" : "ADD";
                        3'b111: get_instr_name = "AND";
                        3'b110: get_instr_name = "OR";
                        default: get_instr_name = "R-TYPE";
                    endcase
                end
                7'b0010011: get_instr_name = "ADDI";
                7'b0000011: get_instr_name = "LW";
                7'b0100011: get_instr_name = "SW";
                7'b1100011: get_instr_name = "BEQ";
                7'b1101111: get_instr_name = "JAL";
                7'b0110111: get_instr_name = "LUI";
                default:    get_instr_name = "UNK";
            endcase
        end
    endfunction

    always @(negedge clk) begin
        if (rst_n) begin
            cycle_cnt = cycle_cnt + 1;
            

            if (dut.F_pc == last_pc && !dut.F_stall) begin
                same_pc_count = same_pc_count + 1;
            end else begin
                same_pc_count = 0;
                last_pc = dut.F_pc;
            end

            if (same_pc_count >= MAX_SAME_PC) begin
                $display("\n [!] DETECTED INFINITE LOOP / STUCK AT PC: %h. TERMINATING.", dut.F_pc);
                $finish;
            end

            $display("┌────────────────── Cycle %0d ──────────────────┐", cycle_cnt);

            $display("│ [F] PC:%h | Instr:%h (%s)", 
                     dut.F_pc, dut.F_instr, get_instr_name(dut.F_instr));
            
            $display("│ [D] PC:%h | Instr:%h | Rs1:x%0d Rs2:x%0d Rd:x%0d", 
                     dut.datapath_inst.D_pc, dut.D_instr, dut.D_rf_a1, dut.D_rf_a2, dut.D_instr[11:7]);
            
            $display("│ [E] ALU_Res:%h | Target:%h | PCSrc:%b ForwardA:%b", 
                     dut.datapath_inst.E_alu_result, dut.datapath_inst.E_target_PC, dut.E_pcsrc, dut.E_fd_A);
            $display("│     E_branch:%b E_jump:%b ZeroE:%b | SrcA:%h SrcB:%h",
                     dut.controller_inst.E_branch, dut.controller_inst.E_jump, dut.datapath_inst.ZeroE, 
                     dut.datapath_inst.E_alu_src_a, dut.datapath_inst.E_alu_src_b);

            if (dut.M_we_dm)
                $display("│ [M] WRITE MEM: Addr:%h <= Data:%h", dut.M_alu_o, dut.M_rf_wd);
            else
                $display("│ [M] MEM_Addr:%h | M_rf_a3:x%0d M_we_rf:%b", dut.M_alu_o, dut.M_rf_a3, dut.M_we_rf);
            
            if (dut.W_we_rf && dut.W_rf_a3 != 0)
                $display("│ [W] REG_WRITE: x%0d <= %h", dut.W_rf_a3, dut.W_result);
            else
                $display("│ [W] NO_WRITE");

            $display("║ x0=%08h x1=%08h x2=%08h x3=%08h x4=%08h x5=%08h ║",

dut.RF.Register[0], dut.RF.Register[1], dut.RF.Register[2], dut.RF.Register[3], dut.RF.Register[4], dut.RF.Register[5]);

$display("║ x6=%08h x7=%08h x8=%08h x9=%08h║",

dut.RF.Register[6], dut.RF.Register[7], dut.RF.Register[8], dut.RF.Register[9]);
            $display("└───────────────────────────────────────────────┘");
        end
    end

    initial begin
        clk = 0;
        rst_n = 0;
        cycle_cnt = 0;
        last_pc = 32'hFFFFFFFF;
        same_pc_count = 0;

        $readmemh("memfile.hex", dut.IMEM.RAM);
        
        #15 rst_n = 1;

        #300;
        $display("Simulation Timeout.");
        $finish;
    end

    // 波形记录
    initial begin
        $dumpfile("rv_pl_sim.vcd");
        $dumpvars(0, rv_pl_tb);
    end

endmodule