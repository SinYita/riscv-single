module Register_File(clk,rst,WriteEnable3,WD3,Address1,Address2,Address3,RD1,RD2);
    input clk,rst,WriteEnable3;
    input [4:0]Address1,Address2,Address3;
    input [31:0]WD3;
    output[31:0] RD1,RD2;
    
    reg[31:0] Register [31:0];
    integer i;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 0; i < 32; i = i + 1) begin
                Register[i] <= 32'd0;
            end
        end else if(WriteEnable3 && Address3 != 5'd0) begin // the $zero register is always 0   
            Register[Address3] <= WD3; 
        end
    end
    assign RD1 = Register[Address1];
    assign RD2 = Register[Address2];

    initial begin // initialize all registers to 0
        for(i = 0;i < 32;i = i + 1) begin
            Register[i] = 32'd0;
        end
    end

endmodule