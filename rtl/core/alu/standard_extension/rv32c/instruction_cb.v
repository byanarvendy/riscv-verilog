module instruction_cb (
    input           iCLK,
    input   [15:0]  iIR,
    input   [7:0]   iPC,

    input   [31:0]  iRS,
    output  [4:0]   oRD, oRS,
    output  [31:0]  oALU_OUT,

    output  [31:0]  oPC
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [4:0]   FUNC5;
    wire    [5:0]   IMM;
    wire    [7:0]   OFFSET;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);   


    assign oRD          = 5'h8 + iIR[9:7];
    assign oRS          = 5'h8 + iIR[9:7];
    assign IMM          = {iIR[12], iIR[6:2]};

    assign OP           = iIR[1:0];
    assign FUNC3        = iIR[15:13];
    assign FUNC5        = {iIR[15:13], iIR[11:10]};

    /*
        c.beqz      | Branch == 0             | CB | 01 | 110    | beq rs’, x0, 2*imm
        c.bnez      | Branch != 0             | CB | 01 | 111    | bne rs’, x0, 2*imm
        c.srli      | Shift Right Logical Imm | CB | 01 | 100x00 | srli rd’, rd’, imm
        c.srai      | Shift Right Arith Imm   | CB | 01 | 100x01 | srai rd’, rd’, imm
        c.andi      | AND Imm                 | CB | 01 | 100x10 | andi rd’, rd’, imm
    */  

    assign oALU_OUT = ((OP == 2'b01) && (FUNC5 == 5'b10000) && (IMM[5] != 0)) ? iRS >> IMM   :           /* shift right logical imm */
                      ((OP == 2'b01) && (FUNC5 == 5'b10001) && (IMM[5] != 0)) ? iRS >>> IMM  :           /* shift right arith imm */
                      ((OP == 2'b01) && (FUNC5 == 5'b10010)) ? iRS & {{26{IMM[5]}}, IMM}     :           /* shift right logical imm */
                      32'h0;                      

    assign oPC      = ((OP == 2'b01) && (FUNC3 == 3'b110) && (iRS == 0))
                            ? iPC + OFFSET                                                   :           /* branch == 0 */
                      ((OP == 2'b01) && (FUNC3 == 3'b111) && (iRS != 0))
                            ? iPC + OFFSET                                                   :           /* branch != 0 */
                      32'h0;


    /* DEBUG */
    always @(posedge iCLK) begin
        if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b110)) begin
            $display("INSTRUCTION CB -> iPC: 0x%x, iRS: 0x%x", iPC, iRS);
            $display("INSTRUCTION CB -> oRD: 0x%x, oRS: 0x%x, oALU_OUT: 0x%x, oPC: 0x%x", oRD, oRS, oALU_OUT, oPC);
        end
    end


endmodule