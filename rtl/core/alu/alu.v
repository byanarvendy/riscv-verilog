`include "rtl/core/alu/instruction_mux.v"

/* rv32i */
`include "rtl/core/alu/rv32i/instruction_r.v"
`include "rtl/core/alu/rv32i/instruction_i.v"
`include "rtl/core/alu/rv32i/instruction_s.v"
`include "rtl/core/alu/rv32i/instruction_b.v"
`include "rtl/core/alu/rv32i/instruction_u.v"
`include "rtl/core/alu/rv32i/instruction_j.v"

/* standard extension */
`include "rtl/core/alu/standard_extension/rv32m.v"
`include "rtl/core/alu/standard_extension/rv32a.v"
`include "rtl/core/alu/standard_extension/rv32f/rv32f.v"

module alu (
    input           iCLK,
    input           iRST,
    input   [6:0]   OPCODE,
    input   [7:0]   PC,
    input   [31:0]  IR,
    input   [31:0]  X_ALU_IN1, X_ALU_IN2,
    input   [31:0]  F_ALU_IN1, F_ALU_IN2, F_ALU_IN3,

    output  [31:0]  X_ALU_OUT, F_ALU_OUT,
    output  [31:0]  BR_B, BR_J, BR_I,

    /* register */
    output  [4:0]   X_RD, X_RS1, X_RS2,
    output  [4:0]   F_RD, F_RS1, F_RS2, F_RS3,

    /* ram */
    output          RAM_CE_I, RAM_RD_I, RAM_WR_I,
    output          RAM_CE_S, RAM_RD_S, RAM_WR_S,
    output          RAM_CE_A, RAM_RD_A, RAM_WR_A,
    output          RAM_CE_F, RAM_RD_F, RAM_WR_F,
    output  [7:0]   RAM_ADDR_I, RAM_ADDR_S, RAM_ADDR_A, RAM_ADDR_F,
    output  [31:0]  RAM_DATA_WR_I, RAM_DATA_WR_S, RAM_DATA_WR_A, RAM_DATA_WR_F, oRAM_DATA,
    input   [31:0]  RAM_DATA_RD_I, RAM_DATA_RD_S, RAM_DATA_RD_A, RAM_DATA_RD_F
);

    wire    [4:0]   RD, RS1, RS2, RS3;                                   /* register file */
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_IN3, ALU_OUT;

    /* rv32i */
    wire    [4:0]   RD_R, RS1_R, RS2_R;                             /* instruction r */
    wire    [31:0]  ALU_IN1_R, ALU_IN2_R, ALU_OUT_R;
    wire    [4:0]   RD_I, RS1_I, RS2_I;                             /* instruction i */
    wire    [31:0]  ALU_IN1_I, ALU_IN2_I, ALU_OUT_I;
    wire    [4:0]   RD_S, RS1_S, RS2_S;                             /* instruction s */
    wire    [31:0]  ALU_IN1_S, ALU_IN2_S, ALU_OUT_S;
    wire    [4:0]   RS1_B, RS2_B;                                   /* instruction b */
    wire    [31:0]  ALU_IN1_B, ALU_IN2_B;
    wire    [4:0]   RD_U, RD_J;                                     /* instruction u & j*/
    wire    [31:0]  ALU_OUT_U, ALU_OUT_J;

    /* standard extension */
    wire    [4:0]   RD_M, RS1_M, RS2_M;                             /* rv32m multiply */
    wire    [31:0]  ALU_IN1_M, ALU_IN2_M, ALU_OUT_M;
    wire    [4:0]   RD_A, RS1_A, RS2_A;                             /* rv32a atomic */
    wire    [31:0]  ALU_IN1_A, ALU_IN2_A, ALU_OUT_A;
    wire    [4:0]   RD_F, RS1_F;                                    /* rv32f float */
    wire    [31:0]  ALU_IN1_F, ALU_OUT_F;

    instruction_mux u1 (
        .iCLK(iCLK),
        .iIR(IR), .OPCODE(OPCODE),

        .iRD_R(RD_R), .iRD_I(RD_I), .iRD_S(RD_S), .iRD_U(RD_U), .iRD_J(RD_J),
        .iRD_M(RD_M), .iRD_A(RD_A), .iRD_F(RD_F),

        .iRS1_R(RS1_R), .iRS1_I(RS1_I), .iRS1_S(RS1_S), .iRS1_B(RS1_B), 
        .iRS1_M(RS1_M), .iRS1_A(RS1_A), .iRS1_F(RS1_F),

        .iRS2_R(RS2_R), .iRS2_I(RS2_I), .iRS2_S(RS2_S), .iRS2_B(RS2_B),
        .iRS2_M(RS2_M), .iRS2_A(RS2_A),

        .oALU_IN1_R(ALU_IN1_R), .oALU_IN1_I(ALU_IN1_I), .oALU_IN1_S(ALU_IN1_S), .oALU_IN1_B(ALU_IN1_B),
        .oALU_IN1_M(ALU_IN1_M), .oALU_IN1_A(ALU_IN1_A), .oALU_IN1_F(ALU_IN1_F),
        
        .oALU_IN2_R(ALU_IN2_R), .oALU_IN2_I(ALU_IN2_I), .oALU_IN2_S(ALU_IN2_S), .oALU_IN2_B(ALU_IN2_B), 
        .oALU_IN2_M(ALU_IN2_M), .oALU_IN2_A(ALU_IN2_A),

        .iALU_OUT_R(ALU_OUT_R), .iALU_OUT_I(ALU_OUT_I), .iALU_OUT_S(ALU_OUT_S), .iALU_OUT_U(ALU_OUT_U), .iALU_OUT_J(ALU_OUT_J),
        .iALU_OUT_M(ALU_OUT_M), .iALU_OUT_A(ALU_OUT_A), .iALU_OUT_F(ALU_OUT_F),

        .oRD(X_RD), .oRS1(X_RS1), .oRS2(X_RS2),
        .iALU_IN1(X_ALU_IN1), .iALU_IN2(X_ALU_IN2),
        .oALU_OUT(X_ALU_OUT)
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

        .oRAM_DATA(RAM_DATA_WR_S)        
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

    rv32a_atomic u10 (
        .iCLK(iCLK), .iIR(IR),

        .iALU_IN1(ALU_IN1_A), .iALU_IN2(ALU_IN2_A),
        .oRD(RD_A), .oRS1(RS1_A), .oRS2(RS2_A),
        .oALU_OUT(ALU_OUT_A),

        .oRAM_CE(RAM_CE_A), .oRAM_RD(RAM_RD_A), .oRAM_WR(RAM_WR_A), 
        .oRAM_ADDR(RAM_ADDR_A), .iRAM_DATA(RAM_DATA_RD_A),

        .oRAM_DATA(RAM_DATA_WR_A)
    );

    rv32f_floating u11(
        .iCLK(iCLK), .iIR(IR),
    
        .iALU_IN1(F_ALU_IN1), .iALU_IN2(F_ALU_IN2), .iALU_IN3(F_ALU_IN3),
        .oRD(F_RD), .oRS1(F_RS1), .oRS2(F_RS2), .oRS3(F_RS3),
        .oALU_OUT(F_ALU_OUT),

        .oX_RD(RD_F), .oX_RS1(RS1_F),
        .oX_ALU_OUT(ALU_OUT_F), .iX_ALU_IN1(ALU_IN1_F),

        .oRAM_CE(RAM_CE_F), .oRAM_RD(RAM_RD_F), .oRAM_WR(RAM_WR_F),
        .oRAM_ADDR(RAM_ADDR_F), .iRAM_DATA(RAM_DATA_RD_F),

        .oRAM_DATA(RAM_DATA_WR_F)
    );

    assign oRAM_DATA    = (OPCODE == 7'b0100011) ? RAM_DATA_WR_S :
                          (OPCODE == 7'b0101111) ? RAM_DATA_WR_A :
                          (OPCODE == 7'b0100111) ? RAM_DATA_WR_F :
                          32'h00;

endmodule