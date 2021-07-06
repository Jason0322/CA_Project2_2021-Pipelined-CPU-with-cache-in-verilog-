module Forward_Unit
(
    RS1,
    RS2,
    EX_MEM_Rd,
    MEM_WB_Rd,
    EX_MEM_RW,
    MEM_WB_RW,
    forward1,
    forward2
);

// Interface
input   [4:0]       RS1;
input   [4:0]       RS2;
input   [4:0]       EX_MEM_Rd;
input   [4:0]       MEM_WB_Rd;
input               EX_MEM_RW;
input               MEM_WB_RW;
output  [1:0]       forward1;
output  [1:0]       forward2;

assign  forward1=   (EX_MEM_RW && EX_MEM_Rd!=0 && EX_MEM_Rd==RS1)?2'b10:
                    (MEM_WB_RW && MEM_WB_Rd!=0 && MEM_WB_Rd==RS1)?2'b01:2'b00;
assign  forward2=   (EX_MEM_RW && EX_MEM_Rd!=0 && EX_MEM_Rd==RS2)?2'b10:
                    (MEM_WB_RW && MEM_WB_Rd!=0 && MEM_WB_Rd==RS2)?2'b01:2'b00;
endmodule
