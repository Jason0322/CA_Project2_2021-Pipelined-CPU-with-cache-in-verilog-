module immeGen
(
    data_i,
    data_o,
);
input [31:0]data_i;
output [31:0]data_o;
assign data_o[0:0]=     (data_i[6:6]==1'b1)?1'b0:
                        (data_i[5:5]==1'b0)?data_i[20:20]:data_i[7:7];
assign data_o[4:1]=     (data_i[5:5]==1'b0)?data_i[24:21]:data_i[11:8];
assign data_o[10:5]=    (data_i[14:14]==1'b0)?data_i[30:25]:
                    /*(data_i[24:24]==1'b1)?6'b111111:*/6'b000000;
assign data_o[11:11]=   (data_i[6:6]==1'b1)?data_i[7:7]:
                        (data_i[14:14]==1'b0)?data_i[31:31]:
                        /*(data_i[24:24]==1'b1)?1'b1:*/1'b0;
assign data_o[12:12]=   (data_i[6:6]==1'b1)?data_i[31:31]:
                        (data_i[14:14]==1'b0)?((data_i[31:31]==1'b1)?1'b1:1'b0):
                        /*(data_i[24:24]==1'b1)?1'b1:*/1'b0;
assign data_o[31:13]=   (data_i[14:14]==1'b0)?((data_i[31:31]==1'b1)?19'b1111111111111111111:19'b0000000000000000000):
                        /*(data_i[24:24]==1'b1)?19'b1:*/19'b0;
endmodule