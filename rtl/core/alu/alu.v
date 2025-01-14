`include "rtl/core/alu/instruction_mux.v"
`include "rtl/core/alu/rv32i/instruction_r.v"
`include "rtl/core/alu/rv32i/instruction_i.v"
`include "rtl/core/alu/rv32i/instruction_s.v"
`include "rtl/core/alu/rv32i/instruction_b.v"
`include "rtl/core/alu/rv32i/instruction_u.v"
`include "rtl/core/alu/rv32i/instruction_j.v"
`include "rtl/core/alu/rv32m.v"

module alu (
    input           iCLK,
    input           iRST,
    input   [6:0]   OPCODE,
    input   [31:0]  IR,
    input   [31:0]  ALU_IN1, ALU_IN2,
    input   [7:0]   PC,

    output  [31:0]  ALU_OUT,
    output  [31:0]  BR_B, BR_J, BR_I,

    /* register */
    output  [4:0]   RD, RS1, RS2,

    /* ram */
    output          RAM_CE_I, RAM_RD_I, RAM_WR_I,
    output          RAM_CE_S, RAM_RD_S, RAM_WR_S,
    output  [7:0]   RAM_ADDR_I, RAM_ADDR_S,
    output  [31:0]  RAM_DATA_WR_I, RAM_DATA_WR_S, oRAM_DATA,
    input   [31:0]  RAM_DATA_RD_I, RAM_DATA_RD_S
);

    wire    [4:0]   RD, RS1, RS2;                           /* register file */
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;
    wire    [4:0]   RD_R, RS1_R, RS2_R;                     /* instruction r */
    wire    [31:0]  ALU_IN1_R, ALU_IN2_R, ALU_OUT_R;
    wire    [4:0]   RD_I, RS1_I, RS2_I;                     /* instruction i */
    wire    [31:0]  ALU_IN1_I, ALU_IN2_I, ALU_OUT_I;
    wire    [4:0]   RD_S, RS1_S, RS2_S;                     /* instruction s */
    wire    [31:0]  ALU_IN1_S, ALU_IN2_S, ALU_OUT_S;
    wire    [4:0]   RS1_B, RS2_B;                           /* instruction b */
    wire    [31:0]  ALU_IN1_B, ALU_IN2_B;
    wire    [4:0]   RD_U, RD_J;                             /* instruction u & j*/
    wire    [31:0]  ALU_OUT_U, ALU_OUT_J;
    wire    [4:0]   RD_M, RS1_M, RS2_M;                     /* rv32m multiply */
    wire    [31:0]  ALU_IN1_M, ALU_IN2_M, ALU_OUT_M;

    instruction_mux u1 (
        .iIR(IR), .OPCODE(OPCODE),

        .iRD_R(RD_R), .iRD_I(RD_I), .iRD_S(RD_S),
        .iRD_U(RD_U), .iRD_J(RD_J), .iRD_M(RD_M),

        .iRS1_R(RS1_R), .iRS1_I(RS1_I), .iRS1_S(RS1_S),
        .iRS1_B(RS1_B), .iRS1_M(RS1_M),

        .iRS2_R(RS2_R), .iRS2_I(RS2_I), .iRS2_S(RS2_S),
        .iRS2_B(RS2_B), .iRS2_M(RS2_M),

        .oALU_IN1_R(ALU_IN1_R), .oALU_IN1_I(ALU_IN1_I), .oALU_IN1_S(ALU_IN1_S),
        .oALU_IN1_B(ALU_IN1_B), .oALU_IN1_M(ALU_IN1_M),
        
        .oALU_IN2_R(ALU_IN2_R), .oALU_IN2_I(ALU_IN2_I), .oALU_IN2_S(ALU_IN2_S), 
        .oALU_IN2_B(ALU_IN2_B), .oALU_IN2_M(ALU_IN2_M),

        .iALU_OUT_R(ALU_OUT_R), .iALU_OUT_I(ALU_OUT_I), .iALU_OUT_S(ALU_OUT_S), 
        .iALU_OUT_U(ALU_OUT_U), .iALU_OUT_J(ALU_OUT_J), .iALU_OUT_M(ALU_OUT_M),

        .oRD(RD), .oRS1(RS1), .oRS2(RS2),
        .iALU_IN1(ALU_IN1), .iALU_IN2(ALU_IN2),

        .oALU_OUT(ALU_OUT)
    );

    instruction_r u2 (
        .iCLK(iCLK), .iIR(IR),

        .iALU_IN1(ALU_IN1_R), .iALU_IN2(ALU_IN2_R),
        .oRD(RD_R), .oRS1(RS1_R), .oRS2(RS2_R),
        .oALU_OUT(ALU_OUT_R)
    );

    instruction_i u3 (
        .iCLK(iCLK), .iIR(IR),

        .oRAM_CE(RAM_CE_I), .oRAM_RD(RAM_RD_I), .oRAM_WR(RAM_WR_I), 
        .oRAM_ADDR(RAM_ADDR_I), .iRAM_DATA(RAM_DATA_RD_I),

        .iREG_OUT1(ALU_IN1_I), .iREG_OUT2(ALU_IN2_I),
        .oRD(RD_I), .oRS1(RS1_I), .oRS2(RS2_I),

        .oREG_IN(ALU_OUT_I),

        .iPC(PC), .oPC(BR_I)
    );

    instruction_s u4 (
        .iCLK(iCLK), .iIR(IR),

        .iREG_OUT1(ALU_IN1_S), .iREG_OUT2(ALU_IN2_S),
        .oRD(RD_S), .oRS1(RS1_S), .oRS2(RS2_S),
        .oREG_IN(ALU_OUT_S),

        .oRAM_CE(RAM_CE_S), .oRAM_RD(RAM_RD_S), .oRAM_WR(RAM_WR_S), 
        .oRAM_ADDR(RAM_ADDR_S), .iRAM_DATA(RAM_DATA_RD_S),

        .oRAM_DATA(oRAM_DATA)
    );

    instruction_b u5 (
        .iCLK(iCLK), .iIR(IR), .iPC(PC),

        .iREG_OUT1(ALU_IN1_B), .iREG_OUT2(ALU_IN2_B),
        .oRS1(RS1_B), .oRS2(RS2_B),
        .oPCBR(BR_B)
    );

    instruction_u u7 (
        .iCLK(iCLK), .iIR(IR),
        .iPC(PC),
    
        .oRD(RD_U), .oREG_IN(ALU_OUT_U)
    );

    instruction_j u8 (
        .iCLK(iCLK), .iIR(IR),
        .iPC(PC),
    
        .oRD(RD_J), .oREG_IN(ALU_OUT_J),
        .oPCBR(BR_J)
    );

    rv32m_multiply u9 (
        .iCLK(iCLK), .iIR(IR),

        .iALU_IN1(ALU_IN1_M), .iALU_IN2(ALU_IN2_M),
        .oRD(RD_M), .oRS1(RS1_M), .oRS2(RS2_M),
        .oALU_OUT(ALU_OUT_M)
    );

endmodule