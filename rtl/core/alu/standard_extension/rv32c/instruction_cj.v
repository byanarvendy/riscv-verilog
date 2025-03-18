module instruction_cj (
    input           iCLK,
    input   [15:0]  iIR,
    input   [7:0]   iPC,

    output  [4:0]   oRD,
    output  [31:0]  oALU_OUT, oPC
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [10:0]  OFFSET;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);  


    assign oRD          = 5'h1;
    assign OFFSET       = {iIR[5:3], iIR[11], iIR[2], iIR[7], iIR[6], iIR[10:9], iIR[8], iIR[12]};

    assign OP           = iIR[1:0];
    assign FUNC3        = iIR[15:13];

    /*
        c.j     | Jump          | CJ | 01 | 101 | jal x0, 2*offset
        c.jal   | Jump And Link | CJ | 01 | 001 | jal ra, 2*offset
    */

    assign oALU_OUT = ((OP == 2'b01) && (FUNC3 == 3'b001)) ? iPC + 2                    :           /* jump and link */
                      32'h0;

    assign oPC      = ((OP == 2'b01) && (FUNC3 == 3'b101)) ? iPC + OFFSET               :           /* jump */
                      ((OP == 2'b01) && (FUNC3 == 3'b001)) ? iPC + OFFSET               :           /* jump and link */
                      32'h0;


    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b111)) begin
    //         $display("INSTRUCTION CJ -> iPC: 0x%x, oRD: 0x%x, oALU_OUT: 0x%x, oPC: 0x%x,", iPC, oRD, oALU_OUT, oPC);
    //     end
    // end


endmodule