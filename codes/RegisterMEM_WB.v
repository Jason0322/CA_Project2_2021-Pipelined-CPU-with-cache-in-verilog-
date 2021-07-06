module RegisterMEM_WB(
	clk_i      ,
    rst_i,
    RegWrite_i ,
    MemtoReg_i  ,

    RegWrite_o ,
    MemtoReg_o  ,

    data_i ,
    ALU_Result_i ,
	RDaddr_i   ,
	
    data_o ,
    ALU_Result_o ,
	RDaddr_o,

    Memstall_i
);

input clk_i,Memstall_i;
input rst_i;
input RegWrite_i, MemtoReg_i;
output reg RegWrite_o, MemtoReg_o;

input [31:0] data_i, ALU_Result_i;
output reg [31:0] data_o, ALU_Result_o;
input       [4:0]     RDaddr_i;
output reg  [4:0]     RDaddr_o;

always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
     RegWrite_o  <= 1'b0;
     MemtoReg_o  <= 1'b0;
     ALU_Result_o  <= 32'b0;
     data_o  <= 32'b0;
     RDaddr_o  <= 5'b0;
    end
    else if(!rst_i && Memstall_i == 0) begin
        RegWrite_o <= RegWrite_i; 
        MemtoReg_o <= MemtoReg_i;
        data_o <= data_i;
        ALU_Result_o <= ALU_Result_i;
        RDaddr_o <= RDaddr_i;
    end
    else if(!rst_i && Memstall_i == 1) begin
        RegWrite_o <= RegWrite_o; 
        MemtoReg_o <= MemtoReg_o;
        data_o <= data_o;
        ALU_Result_o <= ALU_Result_o;
        RDaddr_o <= RDaddr_o;
    end
end

endmodule
