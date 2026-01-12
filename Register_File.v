module Register_File(clk,rst_n,WE,WD,A1,A2,A3,RD1,RD2);
    input clk,rst_n,WE;
    input [4:0] A1, A2, A3;
    input [31:0] WD;
    output [31:0] RD1, RD2;
    
    reg [31:0] Register [31:0];
    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for(i = 0; i < 32; i = i + 1) begin
                Register[i] <= 32'd0;
            end
        end else if (WE && A3 != 5'd0) begin
            Register[A3] <= WD; 
        end
    end

    assign RD1 = (A1 == 5'd0) ? 32'd0 : Register[A1];
    assign RD2 = (A2 == 5'd0) ? 32'd0 : Register[A2];

    // initial begin
    //     for(i = 0; i < 32; i = i + 1) begin
    //         Register[i] = 32'd0;
    //     end
    // end

endmodule