module ALU_Control
(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

input [9:0] funct_i;
input [2:0] ALUOp_i;
output [3:0] ALUCtrl_o;

assign ALUCtrl_o =  (ALUOp_i == 3'b011 && funct_i == 10'b0000000111) ? 4'b0000 :
                    (ALUOp_i == 3'b011 && funct_i == 10'b0000000100) ? 4'b0001 :
                    (ALUOp_i == 3'b011 && funct_i == 10'b0000000001) ? 4'b0010 :
                    (ALUOp_i == 3'b011 && funct_i == 10'b0000000000) ? 4'b0011 :
                    (ALUOp_i == 3'b011 && funct_i == 10'b0100000000) ? 4'b0100 :
                    (ALUOp_i == 3'b011 && funct_i == 10'b0000001000) ? 4'b0101 :
                    (ALUOp_i == 3'b001 && funct_i[2:0]   ==  3'b000) ? 4'b0110 :
                    (ALUOp_i == 3'b001 && funct_i == 10'b0100000101) ? 4'b0111 :
                    (ALUOp_i == 3'b000 && funct_i[2:0] == 3'b010)    ? 4'b1000 :
                    (ALUOp_i == 3'b010 && funct_i[2:0] == 3'b010)    ? 4'b1001 :
                    (ALUOp_i == 3'b110 && funct_i == 10'b0000001000) ? 4'b1010 :
                    4'b0000;

endmodule