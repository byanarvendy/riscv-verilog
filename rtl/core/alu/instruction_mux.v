module instruction_mux(
    input           iCLK,
    input   [6:0]   OPCODE,
    input   [31:0]  iIR,

    input   [4:0]   iRD_R, iRD_I, iRD_S, iRD_U, iRD_J, iRD_M, iRD_A, iRD_F,
    input   [4:0]   iRS1_R, iRS1_I, iRS1_S, iRS1_B, iRS1_M, iRS1_A, iRS1_F,
    input   [4:0]   iRS2_R, iRS2_I, iRS2_S, iRS2_B, iRS2_M, iRS2_A, iRS2_F,
    input   [4:0]   iRS3_F,

    output  [31:0]  oALU_IN1_R, oALU_IN1_I, oALU_IN1_S, oALU_IN1_B, oALU_IN1_M, oALU_IN1_A, oALU_IN1_F, 
    output  [31:0]  oALU_IN2_R, oALU_IN2_I, oALU_IN2_S, oALU_IN2_B, oALU_IN2_M, oALU_IN2_A, oALU_IN2_F,
    output  [31:0]  oALU_IN3_F,

    input   [31:0]  iALU_OUT_R, iALU_OUT_I, iALU_OUT_S, iALU_OUT_U, iALU_OUT_J, iALU_OUT_M, iALU_OUT_A, iALU_OUT_F,

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


    assign oRD          =  (OPCODE == 7'b0110011) ? 
                                ((OPCODE_R_M == 1'b0) ? iRD_R                                                       : 
                                 (OPCODE_R_M == 1'b1) ? iRD_M                                                       :
                                 5'h0)                                                                              :
                           (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iRD_I       :
                           (OPCODE == 7'b0100011) ? iRD_S                                                           :
                           (OPCODE == 7'b0110111) || (OPCODE == 7'b0010111) ? iRD_U                                 :
                           (OPCODE == 7'b1101111) ? iRD_J                                                           :
                           (OPCODE == 7'b0101111) ? iRD_A                                                           :
                           (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iRD_F                                     :  
                           5'h0;

    assign oRS1         = (OPCODE == 7'b0110011) ?
                                ((OPCODE_R_M == 1'b0) ? iRS1_R                                                      : 
                                 (OPCODE_R_M == 1'b1) ? iRS1_M                                                      :
                                 5'h0)                                                                              :
                          (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iRS1_I       :
                          (OPCODE == 7'b0100011) ? iRS1_S                                                           :
                          (OPCODE == 7'b1100011) ? iRS1_B                                                           :
                          (OPCODE == 7'b0101111) ? iRS1_A                                                           :
                          (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iRS1_F                                     : 
                          5'h0;

    assign oRS2         = (OPCODE == 7'b0110011) ? 
                                ((OPCODE_R_M == 1'b0) ? iRS2_R                                                      : 
                                 (OPCODE_R_M == 1'b1) ? iRS2_M                                                      :
                                 5'h0)                                                                              :
                          (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iRS2_I       :
                          (OPCODE == 7'b0100011) ? iRS2_S                                                           :
                          (OPCODE == 7'b1100011) ? iRS2_B                                                           :
                          (OPCODE == 7'b0101111) ? iRS2_A                                                           :
                          (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iRS2_F                                     :
                          5'h0;

    assign oRS3         = (F_OPCODE == 1'b1) ? iRS3_F : 5'h0;

    assign oALU_OUT     = (OPCODE == 7'b0110011) ?
                                ((OPCODE_R_M == 1'b0) ? iALU_OUT_R                                                  : 
                                 (OPCODE_R_M == 1'b1) ? iALU_OUT_M                                                  : 
                                 5'h0)                                                                              :
                          (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iALU_OUT_I   :
                          (OPCODE == 7'b0100011) ? iALU_OUT_S                                                       :
                          (OPCODE == 7'b0110111) || (OPCODE == 7'b0010111) ? iALU_OUT_U                             :
                          (OPCODE == 7'b1101111) ? iALU_OUT_J                                                       :
                          (OPCODE == 7'b0101111) ? iALU_OUT_A                                                       :
                          (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iALU_OUT_F                                 :
                          5'h0;

    assign oALU_IN1_R   = (OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b0) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_I   = (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_S   = (OPCODE == 7'b0100011) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_B   = (OPCODE == 7'b1100011) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_M   = (OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b1) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_A   = (OPCODE == 7'b0101111) ? iALU_IN1 : 32'h0;
    assign oALU_IN1_F   = (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iALU_IN1 : 32'h0;

    assign oALU_IN2_R   = (OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b0) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_I   = (OPCODE == 7'b0010011) || (OPCODE == 7'b0000011) || (OPCODE == 7'b1100111) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_S   = (OPCODE == 7'b0100011) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_B   = (OPCODE == 7'b1100011) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_M   = (OPCODE == 7'b0110011) && (OPCODE_R_M == 1'b1) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_A   = (OPCODE == 7'b0101111) ? iALU_IN2 : 32'h0;
    assign oALU_IN2_F   = (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iALU_IN2 : 32'h0;

    assign oALU_IN3_F   = (OPCODE == 7'b0000111) || (F_OPCODE == 1'b1) ? iALU_IN3 : 32'h0;

endmodule