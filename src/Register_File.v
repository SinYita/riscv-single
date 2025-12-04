module Register_File(clk,rst,WriteEnable3,WD3,Address1,Address2,Address3,RD1,RD2);
    input clk,rst,WriteEnable3;
    input [4:0]Address1,Address2,Address3;
    input [31:0]WD3;
    output[31:0] RD1,RD2;
    
    reg[31:0] Register [31:0]; // we have 32 registers, each is 32 bits wide
    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i = 0; i < 32; i = i + 1) begin
                Register[i] <= 32'd0;
            end
        end else if(WriteEnable3 && Address3 != 5'd0) begin
            Register[Address3] <= WD3; 
        end
    end
    assign RD1 = Register[Address1];
    assign RD2 = Register[Address2];

    // initial begin
    //     Register[5] = 32'h00000005;
    //     Register[6] = 32'h00000004;
    // end

endmodule