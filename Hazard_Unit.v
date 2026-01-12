module Hazard_Unit(
    input  wire [4:0] D_rf_a1, D_rf_a2,     
    input  wire [4:0] E_rf_a1, E_rf_a2,     
    input  wire [4:0] E_rf_a3, M_rf_a3, W_rf_a3,  
    input  wire       E_pcsrc,         
    input  wire       E_sel_result0,    
    input  wire       M_we_rf,      
    input  wire       W_we_rf,      
    output wire       F_stall,         
    output wire       D_flush,         
    output wire       D_stall,         
    output wire       E_flush,         
    output reg [1:0]  E_fd_A,      
    output reg [1:0]  E_fd_B       
);
    
    wire lwStall; 
    
    always @(*) begin
        //case 1
        if (((E_rf_a1 == M_rf_a3) && M_we_rf) && (E_rf_a1 != 0)) 
            E_fd_A = 2'b10;
        else if (((E_rf_a1 == W_rf_a3) && W_we_rf) && (E_rf_a1 != 0)) 
            E_fd_A = 2'b01;
        else 
            E_fd_A = 2'b00;
        
        if (((E_rf_a2 == M_rf_a3) && M_we_rf) && (E_rf_a2 != 0)) 
            E_fd_B = 2'b10;
        else if (((E_rf_a2 == W_rf_a3) && W_we_rf) && (E_rf_a2 != 0)) 
            E_fd_B = 2'b01;
        else 
            E_fd_B = 2'b00;
    end
    
    // check if lw
    assign lwStall = ((D_rf_a1 == E_rf_a3) || (D_rf_a2 == E_rf_a3)) && E_sel_result0;
    
    assign F_stall = lwStall;
    assign D_stall = lwStall;
    
    assign D_flush = E_pcsrc;
    assign E_flush = lwStall || E_pcsrc;
    
endmodule
