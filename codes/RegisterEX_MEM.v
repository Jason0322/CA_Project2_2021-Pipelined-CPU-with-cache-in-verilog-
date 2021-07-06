module RegisterEX_MEM(    
	clk_i      ,
    rst_i,

    RegWrite_i ,
    MemWrite_i ,
    MemRead_i  ,
    MemtoReg_i  ,

    RegWrite_o ,
    MemWrite_o ,
    MemRead_o  ,
    MemtoReg_o  ,

    //Zero_i     ,
    ALU_Result_i ,
    muxBresult_i,
    RDaddr_i   ,
    
    //Zero_o     ,
    ALU_Result_o ,
    muxBresult_o,
    RDaddr_o   ,

    Memstall_i
);

input clk_i, Memstall_i;
input rst_i;
input RegWrite_i, MemWrite_i, MemRead_i, MemtoReg_i;
output reg RegWrite_o, MemWrite_o, MemRead_o, MemtoReg_o;

//input                 Zero_i;
input       [31:0]    ALU_Result_i, muxBresult_i;
input       [4:0]     RDaddr_i;

//output reg            Zero_o;
output reg  [31:0]    ALU_Result_o, muxBresult_o;
output reg  [4:0]     RDaddr_o;


always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
         RegWrite_o  <= 1'b0;
     MemtoReg_o  <= 1'b0;
     MemRead_o  <= 1'b0;
     MemWrite_o  <= 1'b0;
     ALU_Result_o  <= 32'b0;
     muxBresult_o  <= 32'b0;
     RDaddr_o  <= 5'b0;
    end  
    else if (!rst_i && Memstall_i == 0) begin
        RegWrite_o <= RegWrite_i; 
        MemWrite_o <= MemWrite_i; 
        MemRead_o <= MemRead_i; 
        MemtoReg_o <= MemtoReg_i;
        ALU_Result_o <= ALU_Result_i;
        muxBresult_o <= muxBresult_i;
        RDaddr_o <= RDaddr_i;
    end
    else if (!rst_i && Memstall_i == 1) begin
        RegWrite_o <= RegWrite_o; 
        MemWrite_o <= MemWrite_o; 
        MemRead_o <= MemRead_o; 
        MemtoReg_o <= MemtoReg_o;
        ALU_Result_o <= ALU_Result_o;
        muxBresult_o <= muxBresult_o;
        RDaddr_o <= RDaddr_o;
    end
end

endmodule
