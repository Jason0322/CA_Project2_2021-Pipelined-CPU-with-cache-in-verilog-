module CPU
(
    clk_i, 
    rst_i,
    start_i,
     // to Data Memory interface        
    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

// to Data Memory interface     
//
input   [256-1:0]     mem_data_i; 
input                     mem_ack_i; 
    
output  [256-1:0]   mem_data_o; 
output  [32-1:0]    mem_addr_o;     
output                  mem_enable_o; 
output                  mem_write_o; 

wire [3:0]  alu_ctrl;       //ALU_Control output and ALU input

wire [31:0] alu_result;     //ALU output, Registers input

//wire zero;      //ALU output not used in Project

wire [31:0] instr;          
//instructions: Instruction_Memory output --> IF/ID ->
//inst[6:0] = Control input
//inst[19:15],[24:20] = Registers input
//inst[31:0] = ImmGen input
//inst[31:25],[14:12] -> ID/EX -> ALU_Control input
//inst[11:7] -> ID/EX -> EX/MEM             -> MEM/WB                       -> register input (write register)
//                    -> Hazard.DU input    -> Forwarding.U input(MEM.Rd)
wire [31:0] reg_data1_temp;     //Registers output -> ID/EX
wire [31:0] reg_data2_temp;     //Registers output -> ID/EX


wire flush;                 //branch_unit output, left mux32 input, if/id input
wire stall;                 //hdu output, if/id input



//wire [31:0] data_ext;   //Sign_extend output, MUX32 input(Not needed)

wire reg [31:0] PC_o;       //PC output, Adder input, Instruction_Memory input
wire [31:0] PC_i;       //Adder output, PC input

wire ctrl_reg_write;    //Control output, registers input
wire ctrl_memtoreg;     //Control output, back mux32 input
wire ctrl_memread;      //Control output, data memory input
wire ctrl_memwrite;     //Control output, data memory input
wire [2:0] ALUOp;       //Control output, ALU_Contol input
wire ctrl_alu_src;      //Control output, center MUX32 input
wire branch;            //control output, branch_unit input 

wire NoOp;              //hazarddu output, control input
wire PCWrite;           //hazarddu output, pc input

wire [31:0] imm_out;           //immeGen output, adder(pc+immgen) & id/ex input (size unsure)


wire [31:0] ALU_i1;     //center MUX32 output, ALU input

wire [31:0] Add_imm_data_o;     //right adder output, left mux input

wire [31:0] IF_ID_pc_o;            //PC output                 = IF/ID output -> right adder
wire [31:0] IF_ID_instr;           //instruction_memory output = IF/ID output -> control [6:0], rdreg1[19:15], rdreg2[24:20], imm gen[31:0], id/ex ([31:25],[14:12]),[19:15],[24:20],[11:7]

wire [31:0] mux_pc;                //left mux output, pc input


wire [31:0] WB_Write_Data;         //right mux32 output, registers input(writedata) & 2 mux4 inputs(01)

wire [31:0] dcache_o;           //Dcache output, MEM/WB input 

wire [1:0] ForwardA, ForwardB;  //from forwarding unit to mux4 as signal
wire [31:0] muxA_o,muxB_o;       //output wire for top and bottom mux4

//wires needed for ID/EX
wire ID_EX_ALUSrc_o, ID_EX_RegWrite_o, ID_EX_MemWrite_o, ID_EX_MemRead_o, ID_EX_MemtoReg_o;
wire [31:0] ID_EX_RS1data_o, ID_EX_RS2data_o, ID_EX_imm_o;
wire [4:0]  ExRs1, ExRs2;                                   //ID/EX -> Forwarding Unit
wire [9:0]  ID_EX_funct_o;                                  //ID/EX -> ALUControl
wire [4:0]  ID_EX_RDaddr_o;                                 //ID/EX -> EX/MEM & Hazard DU
wire [2:0] ID_EX_ALUOp_o;        //not sure size (either 1 or 2 bit(s))

//wires needed for EX/MEM 
wire EX_MEM_RegWrite_o, EX_MEM_MemtoReg_o;
wire [31:0] EX_MEM_ALUResult;
wire EX_MEM_MemRead_o, EX_MEM_MemWrite_o;
wire [31:0] EX_MEM_muxB;
wire [4:0] EX_MEM_RDaddr_o;

//wires needed in MEM/WB
wire [31:0] MEM_WB_ALUResult; 
wire MEM_WB_RegWrite_o,MEM_WB_MemtoReg_o;
wire [4:0] MEM_WB_RDaddr_o;
wire [31:0] MEM_WB_dcache_o;

//from Data Cache to PC & pipeline reg
wire MemStall;

wire    [255:0]      Mem_data_i; 
wire                 Mem_ack_i; 
    
wire   [255:0]      Mem_data_o; 
wire   [31:0]       Mem_addr_o;     
wire                Mem_enable_o; 
wire                Mem_write_o; 

Adder Add_PC(          //left adder    same as HW4                OK
    .data1_in   (PC_o),
    .data2_in   (4),
    .data_o     (PC_i)
);

Adder Add_imm(          //right adder                
    .data1_in   (imm_out),         //imm gen output already shift left (refer immegen) 
    .data2_in   (IF_ID_pc_o),         //from if/id pc_o
    .data_o     (Add_imm_data_o)
);

Branch_Unit Branch_Unit(        //include 'and' and '=':comparing rddata1 & rddata2 from registers
    .BRANCH     (branch),
    .RS1        (reg_data1_temp),
    .RS2        (reg_data2_temp),
    .FLUSH      (flush)
);


PC PC(                  //add HDU output, the rest same as hw4 except pc input   OK
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .stall_i    (MemStall),     //for MemStall from Data Cache
    .pc_i       (mux_pc),       //changed from hw4
    .PCWrite_i  (PCWrite),      //add HDU output
    .pc_o       (PC_o)
);

Instruction_Memory Instruction_Memory(              //OK
    .addr_i     (PC_o), 
    .instr_o    (instr)
);

Control Control(                    //ok
    .Op_i       (IF_ID_instr[6:0]),           
    .No_Op_i    (NoOp),
    .RegWrite_o (ctrl_reg_write),
    .MemtoReg_o (ctrl_memtoreg),
    .MemRead_o  (ctrl_memread),
    .MemWrite_o (ctrl_memwrite),
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ctrl_alu_src),
    .Branch_o   (branch)
);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (IF_ID_instr[19:15]),     
    .RS2addr_i   (IF_ID_instr[24:20]),    
    .RDaddr_i   (MEM_WB_RDaddr_o),      //writereg = from MEM/WB
    .RDdata_i   (WB_Write_Data),       //writedata = from right mux output
    .RegWrite_i (MEM_WB_RegWrite_o),   //from mem/wb_regwrite
    .RS1data_o   (reg_data1_temp),  //output readdata1
    .RS2data_o   (reg_data2_temp)   //output readdata2
);

///MUX with input 0/1 (same module)

MUX32 MUX_ALUSrc(           //center mux
    .data1_i    (muxB_o),         //connect bottom mux4 output 
    .data2_i    (ID_EX_imm_o),         //connect immgen output ->id/ex output
    .select_i   (ID_EX_ALUSrc_o),  //connect ID/EX ->center mux 
    .data_o     (ALU_i1)            //output sent to alu as input 2 (ignore wire naming)
);

MUX32 HazardMUX(           //For Hazard DU (left mux)
    .data1_i    (PC_i),
    .data2_i    (Add_imm_data_o),
    .select_i   (flush),   
    .data_o     (mux_pc)  
);

MUX32 WB_MUX32(           //After MEM/WB (right mux)
    .data1_i    (MEM_WB_ALUResult),
    .data2_i    (MEM_WB_dcache_o),
    .select_i   (MEM_WB_MemtoReg_o),   
    .data_o     (WB_Write_Data)  
);

////////////////

immeGen immeGen(
    .data_i    (IF_ID_instr[31:0]),            
    .data_o    (imm_out)
);





//Pipeline Registers//
RegisterIF_ID RegisterIF_ID(                
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .pc_i       (PC_o),
    .instr_i    (instr),
    .stall_i    (stall),
    .flush_i    (flush),
    .Memstall_i (MemStall),
    .pc_o       (IF_ID_pc_o),
    .instr_o    (IF_ID_instr)
);




RegisterID_EX RegisterID_EX(
    //inputs
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    //from Control (only branch is not connected)
    .RegWrite_i   (ctrl_reg_write),
    .MemtoReg_i   (ctrl_memtoreg),
    .MemRead_i    (ctrl_memread),
    .MemWrite_i   (ctrl_memwrite),
    .ALUOp_i      (ALUOp),
    .ALUSrc_i     (ctrl_alu_src),

    //from Registers
    .RS1data_i   (reg_data1_temp),  //receives output readdata1
    .RS2data_i   (reg_data2_temp),  //receives output readdata2

    //from ImmGen
    .imm_i       (imm_out),

    //from Dcache
    .Memstall_i   (MemStall),

    //from IF/ID
    .funct_i    ({IF_ID_instr[31:25], IF_ID_instr[14:12]}),
    .RSaddr_i   (IF_ID_instr[19:15]),
    .RTaddr_i   (IF_ID_instr[24:20]),
    .RDaddr_i   (IF_ID_instr[11:7]),

    //outputs
    //to EX/MEM
    .RegWrite_o  (ID_EX_RegWrite_o),
    .MemtoReg_o  (ID_EX_MemtoReg_o),
    .MemRead_o   (ID_EX_MemRead_o),
    .MemWrite_o  (ID_EX_MemWrite_o),

    //to ALU_Control
    .ALUOp_o     (ID_EX_ALUOp_o),
    .funct_o     (ID_EX_funct_o),
    //to center mux32
    .ALUSrc_o    (ID_EX_ALUSrc_o),
    .imm_o       (ID_EX_imm_o),
    //to top mux4
    .RS1data_o   (ID_EX_RS1data_o),
    //to bottom mux4
    .RS2data_o   (ID_EX_RS2data_o),

    //to Forwarding Unit
    .RSaddr_o   (ExRs1),
    .RTaddr_o   (ExRs2),
    
    //to EX/MEM & Hazard DU
    .RDaddr_o   (ID_EX_RDaddr_o)
);


RegisterEX_MEM RegisterEX_MEM(
    //inputs
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    //from ID/EX
    .RegWrite_i   (ID_EX_RegWrite_o),
    .MemtoReg_i   (ID_EX_MemtoReg_o),
    .MemRead_i    (ID_EX_MemRead_o),
    .MemWrite_i   (ID_EX_MemWrite_o),
    //from ALU
    .ALU_Result_i (alu_result),
    //from bottom Mux4
    .muxBresult_i  (muxB_o),
    //from Dcache
    .Memstall_i   (MemStall),
    //from ID/EX
    .RDaddr_i   (ID_EX_RDaddr_o),

    //outputs
    //to MEM/WB
    .RegWrite_o  (EX_MEM_RegWrite_o),       
    .MemtoReg_o  (EX_MEM_MemtoReg_o),
    //to DataMemory
    .MemRead_o   (EX_MEM_MemRead_o),        
    .MemWrite_o  (EX_MEM_MemWrite_o),
    //to MUX4 (10) & Data Memory(address)
    .ALU_Result_o (EX_MEM_ALUResult),
    //to DataMemory(write data)
    .muxBresult_o (EX_MEM_muxB),
    //to MEM/WB
    .RDaddr_o     (EX_MEM_RDaddr_o)
);


RegisterMEM_WB RegisterMEM_WB(
    //inputs
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    //from EX/MEM
    .RegWrite_i   (EX_MEM_RegWrite_o),
    .MemtoReg_i   (EX_MEM_MemtoReg_o),
    .ALU_Result_i (EX_MEM_ALUResult),
    .RDaddr_i     (EX_MEM_RDaddr_o),
    //from Data Memory(read data)
    .data_i        (dcache_o),
    //from Dcache
    .Memstall_i   (MemStall),

    //outputs
    //to Forwarding Unit & Registers
    .RegWrite_o   (MEM_WB_RegWrite_o),
    //to right mux32
    .MemtoReg_o   (MEM_WB_MemtoReg_o),  //control
    .ALU_Result_o (MEM_WB_ALUResult),   //0
    .data_o        (MEM_WB_dcache_o),       //1
    //to Forwarding Unit & Registers
    .RDaddr_o     (MEM_WB_RDaddr_o)
);
/////////////////////////////////////

Hazard_Detection_Unit Hazard_Detection_Unit(
    .ID_EX_MR (ID_EX_MemRead_o),   //from ID/EX MemRead
    .ID_EX_Rd  (ID_EX_RDaddr_o),    //from ID/EX RDaddr = instruction[11:7]
    .RS1(IF_ID_instr[19:15]), //from if/id
    .RS2(IF_ID_instr[24:20]), //from if/id
    .No_Op   (NoOp),          //to Ctrl
    .PC_write (PCWrite),       //to PC
    .STALL   (stall)          //to IF/ID
);

Forward_Unit Forward_Unit(
    //from ID/EX
    .RS1       (ExRs1),
    .RS2       (ExRs2),
    .MEM_WB_Rd        (MEM_WB_RDaddr_o),      //WBRd = from MEM/WB
    .MEM_WB_RW  (MEM_WB_RegWrite_o),
    .EX_MEM_RW (EX_MEM_RegWrite_o),    //MEMRegwrite from EX/MEM
    .EX_MEM_Rd       (EX_MEM_RDaddr_o),      //MEMRd from EX/MEM
    .forward1    (ForwardA),     //to top mux
    .forward2    (ForwardB)      //to bottom mux
);

//MUX with input 00,01,10,11
Forward_MUX Forward_MUX_A(      //for ForwardA    //top MUX4    ok
    .RS_VALUE    (ID_EX_RS1data_o),         //read_data1 00
    .MEM_WB_VALUE(WB_Write_Data),         //01
    .EX_MEM_VALUE (EX_MEM_ALUResult),         //10
    .forward_control       (ForwardA),         //from Forwarding Unit
    .VALUE_OUT          (muxA_o)          //mux output -> alu
);    

Forward_MUX Forward_MUX_B(      //for ForwardB     //bottom MUX4    ok
    .RS_VALUE    (ID_EX_RS2data_o),         //read_data1 00
    .MEM_WB_VALUE(WB_Write_Data),         //01
    .EX_MEM_VALUE (EX_MEM_ALUResult),         //10
    .forward_control       (ForwardB),         //from Forwarding Unit
    .VALUE_OUT          (muxB_o)          //mux output -> center mux32 & EX/MEM 
);    
////////////////////////////////

ALU ALU(                //ok
    .data1_i    (muxA_o),           //topmux4 ->alu input 1
    .data2_i    (ALU_i1),           //bottom mux4 -> alu input 2 (ignore the wire naming)
    .ALUCtrl_i  (alu_ctrl),         //aluctrl -> alu
    .data_o     (alu_result)       //alu output -> EX/MEM
    //.Zero_o     (zero)            //unused in Project
);

ALU_Control ALU_Control(            //ok
    .funct_i    (ID_EX_funct_o),            // id/ex -> aluctrl input
    .ALUOp_i    (ID_EX_ALUOp_o),            // id/ex -> aluctrl input
    .ALUCtrl_o  (alu_ctrl)                  //aluctrl output -> alu
);

dcache_controller dcache(   //Data Cache
    // System clock, reset and stall
    .clk_i		(clk_i), 
    .rst_i 		(rst_i),
    
    // to Data Memory interface        
    .mem_data_i		(mem_data_i), 
    .mem_ack_i 		(mem_ack_i),     
    .mem_data_o	    (mem_data_o), 
    .mem_addr_o 	(mem_addr_o),     
    .mem_enable_o 	(mem_enable_o), 
    .mem_write_o 	(mem_write_o), 
    
    // to CPU interface    
    .cpu_data_i		(EX_MEM_muxB), 			//from EX/MEM(bottom mux4 result) (write data in dcache)
    .cpu_addr_i 	(EX_MEM_ALUResult),    //EX/MEM to Dcache (address)   
    .cpu_MemRead_i  (EX_MEM_MemRead_o), 		//from EX/MEM to Dcache(MemRead)
    .cpu_MemWrite_i (EX_MEM_MemWrite_o), 		//from EX/MEM to Dcache(MemWrite)
    .cpu_data_o 	(dcache_o), 					//Dcache output to MEM/WB
    .cpu_stall_o	(MemStall)					//Memstall signal for 4 pipeline reg and pc
);
endmodule
