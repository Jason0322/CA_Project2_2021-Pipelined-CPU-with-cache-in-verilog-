module RegisterIF_ID (
 	clk_i      ,
    rst_i      ,
    pc_i       ,
    instr_i    ,
    stall_i    ,
    flush_i    ,
    Memstall_i ,
    pc_o 	   ,
    instr_o    
);

input 				clk_i, stall_i, flush_i;
input               rst_i;
input               Memstall_i;
input   [31:0]      pc_i;
input	[31:0] 		instr_i;

output reg  [31:0]      pc_o;
output reg	[31:0] 		instr_o;

always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        pc_o <= 32'b0;
        instr_o <= 32'b0;
    end  
    else begin
        if (flush_i == 1'b1) begin
            pc_o <= pc_i;
            instr_o <= 32'b0;
        end
        else if (stall_i || Memstall_i == 1'b1) begin
            pc_o <= pc_o;
            instr_o <= instr_o;
        end
        else begin
            pc_o <= pc_i;
            instr_o <= instr_i;
        end
    end
end
endmodule