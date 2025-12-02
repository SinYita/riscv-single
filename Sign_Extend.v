module Sign_Extend(In, Imm_Ext,ImmSrc);
    input [31:0]In;
    input ImmSrc; // this input decides which type of immediate to be extended
    output [31:0] Imm_Ext;

    // ImmSrc == 1 -> S-type: imm[11:5]=In[31:25], imm[4:0]=In[11:7]
    // ImmSrc == 0 -> I-type: imm[11:0]=In[31:20]
    assign Imm_Ext = (ImmSrc == 1'b1) ? ({{20{In[31]}},In[31:25],In[11:7]}):
                                            {{20{In[31]},In[31:20]}};

endmodule