`include "rtl/core/alu/standard_extension/rv32f/float_comp.v"
`include "rtl/core/alu/standard_extension/rv32f/float_conv.v"
`include "rtl/core/alu/standard_extension/rv32f/float_class.v"

module rv32f_floating (
    input           iCLK,
    input   [31:0]  iIR,
    
    input   [31:0]  iALU_IN1, iX_ALU_IN1,
    input   [31:0]  iALU_IN2,
    input   [31:0]  iALU_IN3,

    output  [4:0]   oRD, oX_RD,
    output  [4:0]   oRS1, oX_RS1,
    output  [4:0]   oRS2,
    output  [4:0]   oRS3,
    output  [31:0]  oALU_OUT, oX_ALU_OUT,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,

    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA,
    output  [31:0]  oRAM_DATA
);  

    wire    [2:0]   RM;
    wire    [4:0]   OFFSET5;
    wire    [6:0]   OPCODE, OFFSET7;
    wire    [11:0]  OFFSET12;
    wire    [31:0]  RAM_ADDRESS, RAM_DATA;

    /* f opcode */
    reg    F_OPCODE;
    always @(posedge iCLK) begin
        case (OPCODE)
            7'b0000111, 7'b0100111, 7'b1000011, 7'b1000111, 7'b1001011, 7'b1001111, 7'b1010011: 
                F_OPCODE = 1'b1;
            default: F_OPCODE = 1'b0;
        endcase
    end

    assign oRD          = iIR[11:7];
    assign oRS1         = iIR[19:15];
    assign oRS2         = iIR[24:20];
    assign oRS3         = iIR[24:20];
    assign RM           = iIR[14:12];

    /* xrf */
    assign oX_RD          = ((OPCODE == 7'b1010011) && ((OFFSET7 == 7'b1100000)   || 
                                                      (OFFSET7 == 7'b1110000)   || 
                                                      (OFFSET7 == 7'b1010000)))  ? iIR[11:7] : 5'h0;
    assign oX_RS1       = ((OPCODE == 7'b0000111) || 
                           (OPCODE == 7'b0100111) || 
                           ((OPCODE == 7'b1010011) && ((OFFSET7 == 7'b1101000) || (OFFSET7 == 7'b1111000)))) ? 
                           iIR[19:15] : 5'h0;

    assign OPCODE       = iIR[6:0];
    assign OFFSET12     = iIR[31:20];
    assign OFFSET7      = iIR[31:25];
    assign OFFSET5      = oRD;

    /* ram */
    assign RAM_ADDRESS  = (OPCODE == 7'b0000111) ? iX_ALU_IN1 + OFFSET12 :
                          (OPCODE == 7'b0100111) ? iX_ALU_IN1 + OFFSET7  :
                          32'h0;
    assign oRAM_ADDR    = RAM_ADDRESS >> 2;
    assign RAM_DATA     = iRAM_DATA;

    assign oRAM_WR      = 1'b1;
    assign oRAM_RD      = 1'b1;
    assign oRAM_CE      = 1'b1;

    assign oALU_OUT     = /* singe-precision load */
                          (OPCODE == 7'b0000111)                ? RAM_DATA                                          :       /* float load word */

                          /* single-precision floating-point computational */
                          (OPCODE == 7'b1000011)                ? iALU_IN1 * iALU_IN2 + iALU_IN3                    :       /* float flused mul-add */
                          (OPCODE == 7'b1000111)                ? iALU_IN1 * iALU_IN2 - iALU_IN3                    :       /* float flused mul-sub */
                          (OPCODE == 7'b1001011)                ? ~(iALU_IN1 * iALU_IN2) + iALU_IN3                 :       /* float neg flused mul-add */
                          (OPCODE == 7'b1001111)                ? ~(iALU_IN1 * iALU_IN2) - iALU_IN3                 :       /* float neg flused mul-sub */
                          (OPCODE == 7'b1010011)                ? 
                                ((OFFSET7 == 7'b0000000)        ? iALU_IN1 + iALU_IN2                               :       /* float add */
                                 (OFFSET7 == 7'b0000100)        ? iALU_IN1 - iALU_IN2                               :       /* float sub */
                                 (OFFSET7 == 7'b0001000)        ? iALU_IN1 * iALU_IN2                               :       /* float mul */
                                 (OFFSET7 == 7'b0001100)        ? iALU_IN1 / iALU_IN2                               :       /* float div */
                                 (OFFSET7 == 7'b0101100)        ? $sqrt(iALU_IN1)                                   :       /* float square root */
                                 (OFFSET7 == 7'b0010100)        ?
                                    ((RM == 3'b000)             ? float_comp.min(iALU_IN1, iALU_IN2)                :       /* float minimum */
                                     (RM == 3'b001)             ? float_comp.max(iALU_IN1, iALU_IN2)                :       /* float maximum */
                                     32'h0)                                                                         :

                                 /* single-precision floating-point conversion and move */
                                 (OFFSET7 == 7'b0010000)        ?
                                    ((RM == 3'b000)             ? {iALU_IN2[31], iALU_IN1[30:0]}                    :       /* float sign injection */
                                     (RM == 3'b001)             ? {~iALU_IN2[31], iALU_IN1[30:0]}                   :       /* float sign neg injection */
                                     (RM == 3'b010)             ? {(iALU_IN1[31] ^ iALU_IN2[31]), iALU_IN1[30:0]}   :       /* float sign xor injection */
                                     32'h0)                                                                         :
                                 (OFFSET7 == 7'b1101000)        ?
                                    ((iIR[24:20] == 5'b00000)   ? float_conv.s32_to_f32(iX_ALU_IN1)                 :       /* float conv from sign int */
                                     (iIR[24:20] == 5'b00001)   ? float_conv.u32_to_f32(iX_ALU_IN1)                 :       /* float conv from unsign int */
                                     32'h0)                                                                         :
                                 (OFFSET7 == 7'b1111000)        ? iX_ALU_IN1[31:0]                                  :       /* move int to float */
                                 32'h0)                                                                             :
                          32'h0;

    assign oX_ALU_OUT   = /* single-precision floating-point computational */
                          (OPCODE == 7'b1010011)                ? 
                                (/* single-precision floating-point conversion and move */
                                 (OFFSET7 == 7'b1100000)        ? 
                                    ((iIR[24:20] == 5'b00000)   ? float_conv.f32_to_s32(iALU_IN1)                   :       /* float conv to int */
                                     (iIR[24:20] == 5'b00001)   ? float_conv.f32_to_u32(iALU_IN1)                   :       /* float conv to int */
                                     32'h0)                                                                         :
                                 (OFFSET7 == 7'b1110000)        ?
                                    ((RM == 3'b000)             ? $signed(iALU_IN1)                                 :       /* move float to int */
                                     (RM == 3'b001)             ? float_class.classify(iALU_IN1)                    :       /* float calssify */
                                     32'h0)                                                                         :
                                 (OFFSET7 == 7'b1010000)        ?
                                    ((RM == 3'b010)             ? (iALU_IN1 == iALU_IN2) ? 1 : 0                    :       /* float equality */
                                     (RM == 3'b001)             ? (iALU_IN1 < iALU_IN2)  ? 1 : 0                    :       /* float less than */
                                     (RM == 3'b000)             ? (iALU_IN1 <= iALU_IN2) ? 1 : 0                    :       /* float less equal */
                                     32'h0)                                                                         :
                                 32'h0)                                                                             :
                          32'h0;

    /* singe-precision store */
    assign oRAM_DATA    = (OPCODE == 7'b0100111) ? iALU_IN2 : 32'h0;                                                        /* float store word */


    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if ((OPCODE == 7'b0000111) || (F_OPCODE == 1'b1)) begin
    //         $display("INSTRUCTION F -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x, oRS3: 0x%x, oALU_OUT: 0x%x", oRD, oRS1, oRS2, oRS3, oALU_OUT);
    //         $display("INSTRUCTION F -> iALU_IN1: %16.4f, iALU_IN2: %16.4f, iALU_IN3: %16.4f", iALU_IN1, iALU_IN2, iALU_IN3);
    //         $display("INSTRUCTION F -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x, oRAM_ADDR: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR, oRAM_ADDR);
    //         $display("INSTRUCTION F -> iRAM_DATA: 0x%x, oRAM_DATA: 0x%x", iRAM_DATA, oRAM_DATA);
    //     end
    // end


endmodule