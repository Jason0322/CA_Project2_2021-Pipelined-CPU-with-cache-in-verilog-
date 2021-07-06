module Hazard_Detection_Unit
(
    RS1,
    RS2,
    ID_EX_Rd,
    ID_EX_MR,
    STALL,
    PC_write,
    No_Op
);

// Interface
input   [4:0]       RS1;
input   [4:0]       RS2;
input   [4:0]       ID_EX_Rd;
input               ID_EX_MR;

output              STALL;
output              PC_write;
output              No_Op;

assign  PC_write=    (ID_EX_MR==1'b1 && ((ID_EX_Rd==RS1&&RS1!=32'b0) || (ID_EX_Rd==RS2&&RS2!=32'b0)))?1'b0:1'b1;
assign  STALL=       (ID_EX_MR==1'b1 && ((ID_EX_Rd==RS1&&RS1!=32'b0) || (ID_EX_Rd==RS2&&RS2!=32'b0)))?1'b1:1'b0;
assign  No_Op=       (ID_EX_MR==1'b1 && ((ID_EX_Rd==RS1&&RS1!=32'b0) || (ID_EX_Rd==RS2&&RS2!=32'b0)))?1'b1:1'b0;
endmodule
