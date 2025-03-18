module instruction_cr (
    input           iCLK,
    input   [15:0]  iIR,
    input   [7:0]   iPC,

    input   [31:0]  iRS1, iRS2,   
    output  [31:0]  oALU_OUT,

    output  [4:0]   oRS1, oRS2,
    output  [4:0]   oRD,

    output  [31:0]  oPC
);

    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);

    wire    [2:0]   FUNC4;

    assign oRD      = ((FUNC4 == 4'b1001) && (oRS1 != 5'b00000) && (oRS2 == 5'b00000)) ? 5'h1 : iIR[11:7];
    assign oRS1     = iIR[11:7];
    assign oRS2     = iIR[6:2];
    assign FUNC4    = iIR[15:12];

    /*
        c.jr    | Jump Reg          | CR | 10 | 1000 | jalr x0, rs1, 0
        c.jalr  | Jump And Link Reg | CR | 10 | 1001 | jalr ra, rs1, 0
        c.mv    | MoVe              | CR | 10 | 1000 | add rd, x0, rs2
        c.add   | ADD               | CR | 10 | 1001 | add rd, rd, rs2
    */
                   
    assign oALU_OUT     = ((FUNC4 == 4'b1001) && (oRS1 != 5'b00000) && (oRS2 == 5'b00000)) ? iPC + 2        :       /* jump and link reg */
                          ((FUNC4 == 4'b1000) && (oRD != 5'b00000)  && (oRS2 != 5'b00000)) ? iRS2           :       /* move */
                          ((FUNC4 == 4'b1001) && (oRD != 5'b00000)  && (oRS2 != 5'b00000)) ? iRS1 + iRS2    :       /* add */
                          32'h0;

    assign oPC          = ((FUNC4 == 4'b1000) && (oRS1 != 5'b00000) && (oRS2 == 5'b00000))                  ||      /* jump reg */
                          ((FUNC4 == 4'b1001) && (oRS1 != 5'b00000) && (oRS2 == 5'b00000))                  ?       /* jump and link reg */
                          iRS1 : 32'h0;


    /* DEBUG */
    always @(posedge iCLK) begin
        if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b000)) begin
            $display("INSTRUCTION CR -> iRS1: 0x%x, iRS2: 0x%x, oRS1: 0x%x, oRS2: 0x%x", iRS1, iRS2, oRS1, oRS2);
            $display("INSTRUCTION CR -> oALU_OUT: 0x%x, oRD: 0x%x, oPC: 0x%x", oALU_OUT, oRD, oPC);
        end
    end
    

endmodule