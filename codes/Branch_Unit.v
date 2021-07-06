module Branch_Unit
(
    BRANCH,//from control unit
    RS1,
    RS2,
    FLUSH//also BRANCH control for PC_MUX
);

// Interface
input   [31:0]      RS1;
input   [31:0]      RS2;
input               BRANCH;
output              FLUSH;

assign  FLUSH=  ((RS1 == RS2) && (BRANCH == 1'b1))?1'b1:1'b0;
endmodule
