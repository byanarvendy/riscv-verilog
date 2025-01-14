`include "rtl/core/register_file.v"

`include "rtl/core/instruction_mux.v"
`include "rtl/core/instruction_r.v"
`include "rtl/core/instruction_i.v"
`include "rtl/core/instruction_s.v"
`include "rtl/core/instruction_b.v"
`include "rtl/core/instruction_u.v"
`include "rtl/core/instruction_j.v"

`include "rtl/soc/ram/ram_mux.v"

module riscv_32i (
    input           iRST,
    input           iCLK,

    /* rom */
    output          oROM_CE, oROM_RD,
    output  [7:0]   oROM_ADDR,
    input   [31:0]  iROM_DATA,

    /* ram */
    output          oRAM_CE, oRAM_RD, oRAM_WR,
    output  [31:0]  oRAM_DATA,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA,

    input   [1:0]   iMODE,
    input   [7:0]   iSW,
    output  [31:0]  oREG32
);

    integer i;

    reg     [7:0]   PC, iRAM_ADDR;

    wire    [31:0]  iROM_DATA, IR, BR_B, BR_J, BR_I;
    wire    [6:0]   OPCODE;

    wire            ROM_CE, ROM_RD;
    reg             RAM_WR, RAM_RD;

    wire            oRAM_WR;

    assign ROM_CE = 1;
    assign ROM_RD = 1;

    assign OPCODE       = iROM_DATA[6:0];
    assign oROM_ADDR    = (PC >> 2);
    assign IR           = iROM_DATA;

    /* register */
    wire    [4:0]   RD, RS1, RS2;                                           /* register file */
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;
    wire    [4:0]   RD_R, RS1_R, RS2_R;                                     /* instruction r */
    wire    [31:0]  ALU_IN1_R, ALU_IN2_R, ALU_OUT_R;
    wire    [4:0]   RD_I, RS1_I, RS2_I;                                     /* instruction i */
    wire    [31:0]  ALU_IN1_I, ALU_IN2_I, ALU_OUT_I;
    wire    [4:0]   RD_S, RS1_S, RS2_S;                                     /* instruction s */
    wire    [31:0]  ALU_IN1_S, ALU_IN2_S, ALU_OUT_S;
    wire    [4:0]   RD_B, RS1_B, RS2_B;                                     /* instruction b */
    wire    [31:0]  ALU_IN1_B, ALU_IN2_B, ALU_OUT_B;
    wire    [4:0]   RD_U, RS1_U, RS2_U;                                     /* instruction u */
    wire    [31:0]  ALU_IN1_U, ALU_IN2_U, ALU_OUT_U;
    wire    [4:0]   RD_J, RS1_J, RS2_J;                                     /* instruction j */
    wire    [31:0]  ALU_IN1_J, ALU_IN2_J, ALU_OUT_J;

    /* ram */
    wire            RAM_CE_I, RAM_RD_I, RAM_WR_I;                           /* instrucion i */
    wire    [31:0]  RAM_DATA_WR_I, RAM_DATA_RD_I;
    wire    [7:0]   RAM_ADDR_I;
    wire            RAM_CE_S, RAM_RD_S, RAM_WR_S;                           /* instrucion s */
    wire    [31:0]  RAM_DATA_WR_S, RAM_DATA_RD_S;
    wire    [7:0]   RAM_ADDR_S;

    assign oRAM_WR = RAM_WR;
	assign oRAM_RD = RAM_RD;

    register_file u1 (
        .iCLK(iCLK), .iRST(iRST),

        .iRD(RD), .iRS1(RS1), .iRS2(RS2),
        .oALU_IN1(ALU_IN1), .oALU_IN2(ALU_IN2), .iALU_OUT(ALU_OUT)
    );
        
    instruction_mux u2 (
        .OPCODE(OPCODE),
        
        .iRD_R(RD_R), .iRD_I(RD_I), .iRD_S(RD_S), 
        .iRD_B(RD_B), .iRD_U(RD_U), .iRD_J(RD_J),

        .iRS1_R(RS1_R), .iRS1_I(RS1_I), .iRS1_S(RS1_S),
        .iRS1_B(RS1_B), .iRS1_U(RS1_U), .iRS1_J(RS1_J),

        .iRS2_R(RS2_R), .iRS2_I(RS2_I), .iRS2_S(RS2_S),
        .iRS2_B(RS2_B), .iRS2_U(RS2_U), .iRS2_J(RS2_J),

        .oALU_IN1_R(ALU_IN1_R), .oALU_IN1_I(ALU_IN1_I), .oALU_IN1_S(ALU_IN1_S),
        .oALU_IN1_B(ALU_IN1_B), .oALU_IN1_U(ALU_IN1_U), .oALU_IN1_J(ALU_IN1_J),
        
        .oALU_IN2_R(ALU_IN2_R), .oALU_IN2_I(ALU_IN2_I), .oALU_IN2_S(ALU_IN2_S), 
        .oALU_IN2_B(ALU_IN2_B), .oALU_IN2_U(ALU_IN2_U), .oALU_IN2_J(ALU_IN2_J),

        .iALU_OUT_R(ALU_OUT_R), .iALU_OUT_I(ALU_OUT_I), .iALU_OUT_S(ALU_OUT_S), 
        .iALU_OUT_B(ALU_OUT_B), .iALU_OUT_U(ALU_OUT_U), .iALU_OUT_J(ALU_OUT_J),

        .oRD(RD), .oRS1(RS1), .oRS2(RS2),
        .iALU_IN1(ALU_IN1), .iALU_IN2(ALU_IN2),
        .oALU_OUT(ALU_OUT)
    );

    ram_mux u3 (
        .OPCODE(OPCODE),

        .iRAM_CE_I(RAM_CE_I), .iRAM_RD_I(RAM_RD_I), .iRAM_WR_I(RAM_WR_I),
        .iRAM_ADDR_I(RAM_ADDR_I), .iRAM_DATA_WR_I(RAM_DATA_WR_I),
        .oRAM_DATA_RD_I(RAM_DATA_RD_I),

        .iRAM_CE_S(RAM_CE_S), .iRAM_RD_S(RAM_RD_S), .iRAM_WR_S(RAM_WR_S),
        .iRAM_ADDR_S(RAM_ADDR_S), .iRAM_DATA_WR_S(RAM_DATA_WR_S),
        .oRAM_DATA_RD_S(RAM_DATA_RD_S),

        .oRAM_CE(oRAM_CE), .oRAM_RD(oRAM_RD), .oRAM_WR(oRAM_WR),
        .oRAM_ADDR(oRAM_ADDR), .oRAM_DATA_WR(oRAM_DATA),
        .iRAM_DATA_RD(iRAM_DATA)
    );

    instruction_r u4 (
        .iCLK(iCLK), .iIR(iROM_DATA),

        .iALU_IN1(ALU_IN1_R), .iALU_IN2(ALU_IN2_R),
        .oRD(RD_R), .oRS1(RS1_R),.oRS2(RS2_R),
        .oALU_OUT(ALU_OUT_R)
    );

    instruction_i u5 (
        .iCLK(iCLK), .iIR(iROM_DATA),

        .oRAM_CE(RAM_CE_I), .oRAM_RD(RAM_RD_I), .oRAM_WR(RAM_WR_I), 
        .oRAM_ADDR(RAM_ADDR_I), .iRAM_DATA(RAM_DATA_RD_I),

        .iREG_OUT1(ALU_IN1_I), .iREG_OUT2(ALU_IN2_I),
        .oRD(RD_I), .oRS1(RS1_I), .oRS2(RS2_I),

        .oREG_IN(ALU_OUT_I),

        .iPC(PC), .oPC(BR_I)
    );

    instruction_s u6 (
        .iCLK(iCLK), .iIR(iROM_DATA),

        .iREG_OUT1(ALU_IN1_S), .iREG_OUT2(ALU_IN2_S),
        .oRD(RD_S), .oRS1(RS1_S), .oRS2(RS2_S),
        .oREG_IN(ALU_OUT_S),

        .oRAM_CE(RAM_CE_S), .oRAM_RD(RAM_RD_S), .oRAM_WR(RAM_WR_S), 
        .oRAM_ADDR(RAM_ADDR_S), .iRAM_DATA(RAM_DATA_RD_S),

        .oRAM_DATA(oRAM_DATA)
    );

    instruction_b u7 (
        .iCLK(iCLK), .iIR(iROM_DATA), .iPC(PC),

        .iREG_OUT1(ALU_IN1_B), .iREG_OUT2(ALU_IN2_B),
        .oRS1(RS1_B), .oRS2(RS2_B),
        .oPCBR(BR_B)
    );

    instruction_u u8 (
        .iCLK(iCLK), .iIR(iROM_DATA),
        .iPC(PC),
    
        .oRD(RD_U), .oREG_IN(ALU_OUT_U)
    );

    instruction_j u9 (
        .iCLK(iCLK), .iIR(iROM_DATA),
        .iPC(PC),
    
        .oRD(RD_J), .oREG_IN(ALU_OUT_J),
        .oPCBR(BR_J)
    );

	initial begin
		i       = 0;
        PC      = 8'b00000000;
	end

    always @(posedge iCLK or posedge iRST) begin
        if (iRST) begin
            PC <= 8'b0;
            i  <= 0;
        end else begin
            $display("#clock: %0d", i);
            
            case (OPCODE)
                7'b0110011: begin
                    $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: R", PC, IR, OPCODE);
                end
                
                7'b0010011, 7'b0000011, 7'b1100111: begin
                    $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: I", PC, IR, OPCODE);

                    if (OPCODE == 7'b0000011) begin
                        RAM_WR = 0;
                        RAM_RD = 1;
                    end

                end

                7'b0100011: begin
                    $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: S", PC, IR, OPCODE);
                    RAM_WR = 1;
                    RAM_RD = 0;
                end

                7'b0110111, 7'b0010111: begin
                    $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: U", PC, IR, OPCODE);
                end
                
                7'b1100011: begin
                    $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: B", PC, IR, OPCODE);
                end
                
                7'b1101111: begin
                    $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: J", PC, IR, OPCODE);
                end
                
                default: begin
                    
                end 
            endcase

            PC <= (OPCODE == 7'b1100011) ? (BR_B) : 
                  (OPCODE == 7'b1101111) ? (BR_J) :
                  (OPCODE == 7'b1100111) ? (BR_I) :
                  PC + 4;

            i <= i + 1;
        end
    end

    assign oREG32 = ALU_OUT;

endmodule