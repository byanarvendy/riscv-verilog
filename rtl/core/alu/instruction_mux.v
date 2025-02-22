module instruction_mux(
    input           iCLK,
    input   [6:0]   OPCODE,
    input   [15:0]  iIR_C,
    input   [31:0]  iIR,

    input   [4:0]   iRD_R, iRD_I, iRD_S, iRD_U, iRD_J, iRD_M, iRD_A, iRD_F,
    input   [4:0]   iRS1_R, iRS1_I, iRS1_S, iRS1_B, iRS1_M, iRS1_A, iRS1_F,
    input   [4:0]   iRS2_R, iRS2_I, iRS2_S, iRS2_B, iRS2_M, iRS2_A, iRS2_F,
    input   [4:0]   iRS3_F,

    output  [31:0]  oALU_IN1_R, oALU_IN1_I, oALU_IN1_S, oALU_IN1_B, oALU_IN1_M, oALU_IN1_A, oALU_IN1_F, 
    output  [31:0]  oALU_IN2_R, oALU_IN2_I, oALU_IN2_S, oALU_IN2_B, oALU_IN2_M, oALU_IN2_A, oALU_IN2_F,
    output  [31:0]  oALU_IN3_F,

    input   [31:0]  iALU_OUT_R, iALU_OUT_I, iALU_OUT_S, iALU_OUT_U, iALU_OUT_J, iALU_OUT_M, iALU_OUT_A, iALU_OUT_F,


    /* rv32c */
    input   [4:0]   iRD_CR, iRD_CI, iRD_CIW, iRD_CL, iRD_CS, iRD_CB, iRD_CJ,
    input   [4:0]   iRS1_CR, iRS1_CI, iRS1_CSS, iRS1_CS, 
    input   [4:0]   iRS2_CR, iRS2_CI, iRS2_CSS, iRS2_CS,
    input   [4:0]   iRS_CIW, iRS_CL, iRS_CB,

    output  [31:0]  oALU_IN1_CR, oALU_IN1_CI, oALU_IN1_CSS, oALU_IN1_CS, 
    output  [31:0]  oALU_IN2_CR, oALU_IN2_CI, oALU_IN2_CSS, oALU_IN2_CS, 
    output  [31:0]  oALU_IN_CIW, oALU_IN_CL, oALU_IN_CB, 
        
    input   [31:0]  iALU_OUT_CR, iALU_OUT_CI, iALU_OUT_CIW, iALU_OUT_CL, 
    input   [31:0]  iALU_OUT_CS, iALU_OUT_CB, iALU_OUT_CJ,


    output  [4:0]   oRD, oRS1, oRS2, oRS3,
    input   [31:0]  iALU_IN1, iALU_IN2, iALU_IN3,
    output  [31:0]  oALU_OUT
);

    /* mux opcode r m */
    wire   OPCODE_R_M;
    assign OPCODE_R_M = opcode_r_m_module.opcode_r_m(iIR);


    /* f opcode */
    reg    F_OPCODE;
    always @(posedge iCLK) begin
        case (OPCODE)
            7'b0000111, 7'b0100111, 7'b1000011, 7'b1000111, 7'b1001011, 7'b1001111, 7'b1010011: 
                F_OPCODE = 1'b1;
            default: F_OPCODE = 1'b0;
        endcase
    end


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR_C);


    assign oRD          =   (iIR[1:0] == 2'b11) ? 
                                ((OPCODE == 7'b0110011) ? 
                                    ((OPCODE_R_M == 1'b0) ? iRD_R                                                        : 
                                     (OPCODE_R_M == 1'b1) ? iRD_M                                                        :
                                     5'h0)                                                                               :
                                 (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iRD_I      :
                                 (OPCODE == 7'b0100011) ? iRD_S                                                          :
                                 (OPCODE == 7'b0110111) || (OPCODE == 7'b0010111) ? iRD_U                                :
                                 (OPCODE == 7'b1101111) ? iRD_J                                                          :
                                 (OPCODE == 7'b0101111) ? iRD_A                                                          :
                                 (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iRD_F                                    :  
                                 5'h0)                                                                                   :
                            (iIR_C[1:0] != 2'b11) ?
                                ((C_MUX == 3'b000) ? iRD_CR                                                              :
                                 (C_MUX == 3'b001) ? iRD_CI                                                              :
                                 (C_MUX == 3'b011) ? iRD_CIW                                                             :
                                 (C_MUX == 3'b100) ? iRD_CL                                                              :
                                 (C_MUX == 3'b101) ? iRD_CS                                                              :
                                 (C_MUX == 3'b110) ? iRD_CB                                                              :
                                 (C_MUX == 3'b111) ? iRD_CJ                                                              :
                                 5'h0)                                                                                   :
                            5'h0;

    assign oRS1         =   (iIR[1:0] == 2'b11) ?
                                ((OPCODE == 7'b0110011) ?
                                    ((OPCODE_R_M == 1'b0) ? iRS1_R                                                      : 
                                     (OPCODE_R_M == 1'b1) ? iRS1_M                                                      :
                                     5'h0)                                                                              :
                                 (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iRS1_I    :
                                 (OPCODE == 7'b0100011) ? iRS1_S                                                        :
                                 (OPCODE == 7'b1100011) ? iRS1_B                                                        :
                                 (OPCODE == 7'b0101111) ? iRS1_A                                                        :
                                 (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iRS1_F                                  : 
                                 5'h0)                                                                                  :
                            (iIR_C[1:0] != 2'b11) ?
                                ((C_MUX == 3'b000) ? iRS1_CR                                                            :
                                 (C_MUX == 3'b001) ? iRS1_CI                                                            :
                                 (C_MUX == 3'b010) ? iRS1_CSS                                                           :
                                 (C_MUX == 3'b011) ? iRS_CIW                                                            :
                                 (C_MUX == 3'b100) ? iRS_CL                                                             :
                                 (C_MUX == 3'b101) ? iRS1_CS                                                            :
                                 (C_MUX == 3'b110) ? iRS_CB                                                             :
                                 5'h0)                                                                                  :
                            5'h0;

    assign oRS2         =   (iIR[1:0] == 2'b11) ?
                                ((OPCODE == 7'b0110011) ? 
                                    ((OPCODE_R_M == 1'b0) ? iRS2_R                                                      : 
                                     (OPCODE_R_M == 1'b1) ? iRS2_M                                                      :
                                     5'h0)                                                                              :
                                 (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iRS2_I    :
                                 (OPCODE == 7'b0100011) ? iRS2_S                                                        :
                                 (OPCODE == 7'b1100011) ? iRS2_B                                                        :
                                 (OPCODE == 7'b0101111) ? iRS2_A                                                        :
                                 (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iRS2_F                                  :
                                 5'h0)                                                                                  :
                            (iIR_C[1:0] != 2'b11) ?
                                ((C_MUX == 3'b000) ? iRS2_CR                                                            :
                                 (C_MUX == 3'b001) ? iRS2_CI                                                            :
                                 (C_MUX == 3'b010) ? iRS2_CSS                                                           :
                                 (C_MUX == 3'b101) ? iRS2_CS                                                            :
                                 5'h0)                                                                                  :
                            5'h0;

    assign oRS3         =   ((iIR[1:0] == 2'b11) && (F_OPCODE == 1'b1)) ? iRS3_F : 5'h0;

    assign oALU_OUT     =   (iIR[1:0] == 2'b11) ?
                                ((OPCODE == 7'b0110011) ?
                                    ((OPCODE_R_M == 1'b0) ? iALU_OUT_R                                                   : 
                                     (OPCODE_R_M == 1'b1) ? iALU_OUT_M                                                   : 
                                     5'h0)                                                                               :
                                 (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iALU_OUT_I :
                                 (OPCODE == 7'b0100011) ? iALU_OUT_S                                                     :
                                 (OPCODE == 7'b0110111) || (OPCODE == 7'b0010111) ? iALU_OUT_U                           :
                                 (OPCODE == 7'b1101111) ? iALU_OUT_J                                                     :
                                 (OPCODE == 7'b0101111) ? iALU_OUT_A                                                     :
                                 (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iALU_OUT_F                               :
                                 5'h0)                                                                                   :   
                            (iIR_C[1:0] != 2'b11) ?
                                ((C_MUX == 3'b000) ? iALU_OUT_CR                                                         :
                                 (C_MUX == 3'b001) ? iALU_OUT_CI                                                         :
                                 (C_MUX == 3'b011) ? iALU_OUT_CIW                                                        :
                                 (C_MUX == 3'b100) ? iALU_OUT_CL                                                         :
                                 (C_MUX == 3'b101) ? iALU_OUT_CS                                                         :
                                 (C_MUX == 3'b110) ? iALU_OUT_CB                                                         :
                                 (C_MUX == 3'b111) ? iALU_OUT_CJ                                                         :
                                 5'h0)                                                                                   :
                            5'h0;                     

    assign oALU_IN1_R   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b0))) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_I   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111))) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_S   =   ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0100011)) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_B   =   ((iIR[1:0] == 2'b11) && (OPCODE == 7'b1100011)) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_M   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b1))) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_A   =   ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0101111)) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_F   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0000111) || (F_OPCODE == 1'b1))) ? iALU_IN1 : 32'h0;

    assign oALU_IN2_R   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b0))) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_I   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111))) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_S   =   ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0100011)) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_B   =   ((iIR[1:0] == 2'b11) && (OPCODE == 7'b1100011)) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_M   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b1))) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_A   =   ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0101111)) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_F   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0000111) || (F_OPCODE == 1'b1))) ? iALU_IN2 : 32'h0;

    assign oALU_IN3_F   =   ((iIR[1:0] == 2'b11) && ((OPCODE == 7'b0000111) || (F_OPCODE == 1'b1))) ? iALU_IN3 : 32'h0;

    /* rv32c */
    assign oALU_IN1_CR  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b000)) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_CI  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b001)) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_CSS =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b010)) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_CS  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b101)) ? iALU_IN1 : 32'h0;

    assign oALU_IN2_CR  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b000)) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_CI  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b001)) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_CSS =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b010)) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_CS  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b101)) ? iALU_IN2 : 32'h0;

    assign oALU_IN_CIW  =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b011)) ? iALU_IN1 : 32'h0;
    assign oALU_IN_CL   =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b100)) ? iALU_IN1 : 32'h0;
    assign oALU_IN_CB   =   ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b110)) ? iALU_IN1 : 32'h0;

endmodule