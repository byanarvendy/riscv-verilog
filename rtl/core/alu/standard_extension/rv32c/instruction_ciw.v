module instruction_ciw (
    input           iCLK,
    input   [15:0]  iIR,

    input   [31:0]  iRS,
    output  [4:0]   oRS, oRD,
    output  [31:0]  oALU_OUT
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [9:0]   IMM;
    wire    [31:0]  RAM_ADDR, RAM_DATA;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);  


    assign OP           = iIR[1:0];

    assign oRS          = 5'h2;
    assign oRD          = 5'h8 + iIR[4:2];
    assign IMM          = {iIR[10:7], iIR[12:11], iIR[5], iIR[4], 2'b00};
    assign FUNC3        = iIR[15:13];

    /*
        c.addi4spn  | ADD Imm * 4 + SP | CIW | 00 | 000 | addi rd’, sp, 4*imm
    */  

    assign oALU_OUT     = ((OP == 2'b0) && (FUNC3 == 3'b000) && (IMM != 6'h0)) ? iRS + IMM :            /* add imm * 16 + sp */
                          32'h0;


    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b011)) begin
    //         $display("INSTRUCTION CIW -> iRS: 0x%x, oRS: 0x%x, oRD: 0x%x, oALU_OUT: 0x%x", iRS, oRS, oRD, oALU_OUT);
    //     end
    // end


endmodule