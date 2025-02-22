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
/* rv32 c extension */
`include "rtl/core/alu/standard_extension/rv32c/instruction_cr.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_ci.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_css.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_ciw.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_cl.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_cs.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_cb.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_cj.v"

module alu (
    input           iCLK,
    input           iRST,
    input   [6:0]   OPCODE,
    input   [7:0]   PC,
    input   [15:0]  IR_C,
    input   [31:0]  IR,
    input   [31:0]  ALU_IN1, ALU_IN2, ALU_IN3,

    output  [31:0]  ALU_OUT,
    output  [31:0]  BR_B, BR_J, BR_I, BR_CR, BR_CB, BR_CJ,

    /* register */
    output  [4:0]   RD, RS1, RS2, RS3,

    /* ram */
    output          RAM_CE_I, RAM_RD_I, RAM_WR_I,
    output          RAM_CE_S, RAM_RD_S, RAM_WR_S,
    output          RAM_CE_A, RAM_RD_A, RAM_WR_A,
    output          RAM_CE_F, RAM_RD_F, RAM_WR_F,
    output          RAM_CE_CI, RAM_RD_CI, RAM_WR_CI,
    output          RAM_CE_CSS, RAM_RD_CSS, RAM_WR_CSS,
    output          RAM_CE_CL, RAM_RD_CL, RAM_WR_CL,
    output          RAM_CE_CS, RAM_RD_CS, RAM_WR_CS,
    output  [7:0]   RAM_ADDR_I, RAM_ADDR_S, RAM_ADDR_A, RAM_ADDR_F, RAM_ADDR_CI, RAM_ADDR_CSS, RAM_ADDR_CL, RAM_ADDR_CS,
    output  [31:0]  RAM_DATA_WR_I, RAM_DATA_WR_S, RAM_DATA_WR_A, RAM_DATA_WR_F, RAM_DATA_WR_CSS, RAM_DATA_WR_CS, oRAM_DATA,
    input   [31:0]  RAM_DATA_RD_I, RAM_DATA_RD_S, RAM_DATA_RD_A, RAM_DATA_RD_F, RAM_DATA_RD_CI, RAM_DATA_RD_CL
);

    wire    [4:0]   RD, RS1, RS2;                                   /* register file */
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;

    /* rv32i */
    wire    [4:0]   RD_R, RS1_R, RS2_R;                             /* instruction r */
    wire    [31:0]  ALU_IN1_R, ALU_IN2_R, ALU_OUT_R;
    wire    [4:0]   RD_I, RS1_I, RS2_I;                             /* instruction i */
    wire    [31:0]  ALU_IN1_I, ALU_IN2_I, ALU_OUT_I;
    wire    [4:0]   RD_S, RS1_S, RS2_S;                             /* instruction s */
    wire    [31:0]  ALU_IN1_S, ALU_IN2_S, ALU_OUT_S, oRAM_DATA_S;
    wire    [4:0]   RS1_B, RS2_B;                                   /* instruction b */
    wire    [31:0]  ALU_IN1_B, ALU_IN2_B;
    wire    [4:0]   RD_U, RD_J;                                     /* instruction u & j*/
    wire    [31:0]  ALU_OUT_U, ALU_OUT_J;

    /* standard extension */
    wire    [4:0]   RD_M, RS1_M, RS2_M;                             /* rv32m multiply */
    wire    [31:0]  ALU_IN1_M, ALU_IN2_M, ALU_OUT_M;
    wire    [4:0]   RD_A, RS1_A, RS2_A;                             /* rv32a atomic */
    wire    [31:0]  ALU_IN1_A, ALU_IN2_A, ALU_OUT_A, oRAM_DATA_A;
    wire    [4:0]   RD_F, RS1_F, RS2_F, RS3_F;                      /* rv32f float */
    wire    [31:0]  ALU_IN1_F, ALU_IN2_F, ALU_IN3_F, ALU_OUT_F, oRAM_DATA_F;
    /* rv32c */
    wire    [4:0]   RD_CR, RS1_CR, RS2_CR;                          /* instruction cr */
    wire    [31:0]  ALU_IN1_CR, ALU_IN2_CR, ALU_OUT_CR;
    wire    [4:0]   RD_CI, RS1_CI, RS2_CI;                          /* instruction ci */
    wire    [31:0]  ALU_IN1_CI, ALU_IN2_CI, ALU_OUT_CI;
    wire    [4:0]   RS1_CSS, RS2_CSS;                               /* instruction css */
    wire    [31:0]  ALU_IN1_CSS, ALU_IN2_CSS;
    wire    [4:0]   RD_CIW, RS_CIW;                                 /* instruction ciw */
    wire    [31:0]  ALU_IN_CIW, ALU_OUT_CIW;
    wire    [4:0]   RD_CL, RS_CL;                                   /* instruction cl */
    wire    [31:0]  ALU_IN_CL, ALU_OUT_CL;
    wire    [4:0]   RD_CS, RS1_CS, RS2_CS;                          /* instruction cs */
    wire    [31:0]  ALU_IN1_CS, ALU_IN2_CS, ALU_OUT_CS;
    wire    [4:0]   RD_CB, RS_CB;                                   /* instruction cb */
    wire    [31:0]  ALU_IN_CB, ALU_OUT_CB;
    wire    [4:0]   RD_CJ;                                          /* instruction cj */
    wire    [31:0]  ALU_OUT_CJ;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(IR_C);


    instruction_mux u1 (
        .iCLK(iCLK),
        .iIR_C(IR_C), .iIR(IR), .OPCODE(OPCODE),

        .iRD_R(RD_R), .iRD_I(RD_I), .iRD_S(RD_S), .iRD_U(RD_U), .iRD_J(RD_J),
        .iRD_M(RD_M), .iRD_A(RD_A), .iRD_F(RD_F),

        .iRS1_R(RS1_R), .iRS1_I(RS1_I), .iRS1_S(RS1_S), .iRS1_B(RS1_B), 
        .iRS1_M(RS1_M), .iRS1_A(RS1_A), .iRS1_F(RS1_F),

        .iRS2_R(RS2_R), .iRS2_I(RS2_I), .iRS2_S(RS2_S), .iRS2_B(RS2_B),
        .iRS2_M(RS2_M), .iRS2_A(RS2_A), .iRS2_F(RS2_F),

        .iRS3_F(RS3_F),

        .oALU_IN1_R(ALU_IN1_R), .oALU_IN1_I(ALU_IN1_I), .oALU_IN1_S(ALU_IN1_S), .oALU_IN1_B(ALU_IN1_B),
        .oALU_IN1_M(ALU_IN1_M), .oALU_IN1_A(ALU_IN1_A), .oALU_IN1_F(ALU_IN1_F),
        
        .oALU_IN2_R(ALU_IN2_R), .oALU_IN2_I(ALU_IN2_I), .oALU_IN2_S(ALU_IN2_S), .oALU_IN2_B(ALU_IN2_B), 
        .oALU_IN2_M(ALU_IN2_M), .oALU_IN2_A(ALU_IN2_A), .oALU_IN2_F(ALU_IN2_F),

        .oALU_IN3_F(ALU_IN3_F),

        .iALU_OUT_R(ALU_OUT_R), .iALU_OUT_I(ALU_OUT_I), .iALU_OUT_S(ALU_OUT_S), .iALU_OUT_U(ALU_OUT_U), .iALU_OUT_J(ALU_OUT_J),
        .iALU_OUT_M(ALU_OUT_M), .iALU_OUT_A(ALU_OUT_A), .iALU_OUT_F(ALU_OUT_F),


        /* rv32c */
        .iRD_CR(RD_CR), .iRD_CI(RD_CI), .iRD_CIW(RD_CIW), .iRD_CL(RD_CL), 
        .iRD_CS(RD_CS), .iRD_CB(RD_CB), .iRD_CJ(RD_CJ),
        
        .iRS1_CR(RS1_CR), .iRS1_CI(RS1_CI), .iRS1_CSS(RS1_CSS), .iRS1_CS(RS1_CS), 
        .iRS2_CR(RS2_CR), .iRS2_CI(RS2_CI), .iRS2_CSS(RS2_CSS), .iRS2_CS(RS2_CS),
        .iRS_CIW(RS_CIW), .iRS_CL(RS_CL), .iRS_CB(RS_CB),

        .oALU_IN1_CR(ALU_IN1_CR), .oALU_IN1_CI(ALU_IN1_CI), .oALU_IN1_CSS(ALU_IN1_CSS), .oALU_IN1_CS(ALU_IN1_CS), 
        .oALU_IN2_CR(ALU_IN2_CR), .oALU_IN2_CI(ALU_IN2_CI), .oALU_IN2_CSS(ALU_IN2_CSS), .oALU_IN2_CS(ALU_IN2_CS), 
        .oALU_IN_CIW(ALU_IN_CIW), .oALU_IN_CL(ALU_IN_CL), .oALU_IN_CB(ALU_IN_CB), 
        
        .iALU_OUT_CR(ALU_OUT_CR), .iALU_OUT_CI(ALU_OUT_CI), .iALU_OUT_CIW(ALU_OUT_CIW), .iALU_OUT_CL(ALU_OUT_CL), 
        .iALU_OUT_CS(ALU_OUT_CS), .iALU_OUT_CB(ALU_OUT_CB), .iALU_OUT_CJ(ALU_OUT_CJ),


        .oRD(RD), .oRS1(RS1), .oRS2(RS2), .oRS3(RS3),
        .iALU_IN1(ALU_IN1), .iALU_IN2(ALU_IN2), .iALU_IN3(ALU_IN3),

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

    rv32f_floating u11 (
        .iCLK(iCLK), .iIR(IR),
    
        .iALU_IN1(ALU_IN1_F), .iALU_IN2(ALU_IN2_F), .iALU_IN3(ALU_IN3_F),
        .oRD(RD_F), .oRS1(RS1_F), .oRS2(RS2_F), .oRS3(RS3_F),
        .oALU_OUT(ALU_OUT_F),

        .oRAM_CE(RAM_CE_F), .oRAM_RD(RAM_RD_F), .oRAM_WR(RAM_WR_F),
        .oRAM_ADDR(RAM_ADDR_F), .iRAM_DATA(RAM_DATA_RD_F),

        .oRAM_DATA(RAM_DATA_WR_F)
    );

    instruction_cr u12 (
        .iCLK(iCLK), .iIR(IR_C),
        .iPC(PC),

        .oRS1(RS1_CR), .oRS2(RS2_CR),
        .oRD(RD_CR),

        .iRS1(ALU_IN1_CR), .iRS2(ALU_IN2_CR),   
        .oALU_OUT(ALU_OUT_CR),

        .oPC(BR_CR)
    );

    instruction_ci u13 (
        .iCLK(iCLK), .iIR(IR_C),

        .iRS1(ALU_IN1_CI), .iRS2(ALU_IN2_CI),
        .oRD(RD_CI), .oRS1(RS1_CI), .oRS2(RS2_CI),
        .oALU_OUT(ALU_OUT_CI),

        .oRAM_CE(RAM_CE_CI), .oRAM_RD(RAM_RD_CI), .oRAM_WR(RAM_WR_CI),
        .oRAM_ADDR(RAM_ADDR_CI), .iRAM_DATA(RAM_DATA_RD_CI)
    );

    instruction_css u14 (
        .iCLK(iCLK), .iIR(IR_C),
    
        .iRS1(ALU_IN1_CSS), .iRS2(ALU_IN2_CSS),
        .oRS1(RS1_CSS), .oRS2(RS2_CSS),

        .oRAM_CE(RAM_CE_CSS), .oRAM_RD(RAM_RD_CSS), .oRAM_WR(RAM_WR_CSS),
        .oRAM_ADDR(RAM_ADDR_CSS), .oRAM_DATA(RAM_DATA_WR_CSS)
    );

    instruction_ciw u15 (
        .iCLK(iCLK), .iIR(IR_C),

        .oRS(RS_CIW), .oRD(RD_CIW),
        .iRS(ALU_IN_CIW),

        .oALU_OUT(ALU_OUT_CIW)
    );

    instruction_cl u16 (
        .iCLK(iCLK), .iIR(IR_C),

        .oRS(RS_CL), .oRD(RD_CL),
        .iRS(ALU_IN_CL),

        .oALU_OUT(ALU_OUT_CL),

        .oRAM_CE(RAM_CE_CL), .oRAM_RD(RAM_RD_CL), .oRAM_WR(RAM_WR_CL),
        .oRAM_ADDR(RAM_ADDR_CL), .iRAM_DATA(RAM_DATA_RD_CL)
    );

    instruction_cs u17 (
        .iCLK(iCLK), .iIR(IR_C),

        .iRS1(ALU_IN1_CS), .iRS2(ALU_IN2_CS),
        .oRS1(RS1_CS), .oRS2(RS2_CS), .oRD(RD_CS),

        .oALU_OUT(ALU_OUT_CS),

        .oRAM_CE(RAM_CE_CS), .oRAM_RD(RAM_RD_CS), .oRAM_WR(RAM_WR_CS),
        .oRAM_ADDR(RAM_ADDR_CS), .oRAM_DATA(RAM_DATA_WR_CS)
    );

    instruction_cb u18 (
        .iCLK(iCLK), .iIR(IR_C),
        .iPC(PC),

        .iRS(ALU_IN_CB),
        .oRD(RD_CB), .oRS(RS_CB),
        .oALU_OUT(ALU_OUT_CB),

        .oPC(BR_CB)
    );

    instruction_cj u19 (
        .iCLK(iCLK), .iIR(IR_C),
        .iPC(PC),

        .oRD(RD_CJ),
        .oALU_OUT(ALU_OUT_CJ), .oPC(BR_CJ)
    );

    assign oRAM_DATA    = (IR[1:0] == 2'b11) ?
                            ((OPCODE == 7'b0100011) ? RAM_DATA_WR_S :
                             (OPCODE == 7'b0101111) ? RAM_DATA_WR_A :
                             (OPCODE == 7'b0100111) ? RAM_DATA_WR_F :
                             32'h0)                                 :
                          (IR_C[1:0] != 2'b11) ?
							((C_MUX == 3'b010) ? RAM_DATA_WR_CSS	:
                             (C_MUX == 3'b101) ? RAM_DATA_WR_CS     :
					   		 32'h0) 								:
						  32'h0;

endmodule