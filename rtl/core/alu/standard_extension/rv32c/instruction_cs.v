
module instruction_cs (
    input           iCLK,
    input   [15:0]  iIR,

    input   [31:0]  iRS1, iRS2,
    output  [4:0]   oRS1, oRS2, oRD,
    output  [31:0]  oALU_OUT,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    output  [31:0]  oRAM_DATA
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [5:0]   IMM;
    wire    [7:0]   FUNC8;
    wire    [31:0]  RAM_ADDR, RAM_DATA;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);  


    assign OP           = iIR[1:0];

    assign oRD          = 5'h8 + iIR[9:7];
    assign oRS1         = 5'h8 + iIR[9:7];
    assign oRS2         = 5'h8 + iIR[4:2];
    assign IMM          = {iIR[5], iIR[12:10], iIR[6], 2'b00};
    assign FUNC3        = iIR[15:13];
    assign FUNC8        = {iIR[15:10], iIR[6:5]};

    assign RAM_ADDR     = iRS1 + IMM;
    assign oRAM_ADDR    = RAM_ADDR >> 2;

    assign oRAM_CE      = 1'b1;
    assign oRAM_RD      = 1'b0;
    assign oRAM_WR      = 1'b1;

    /*
        c.sw    | Store Word | CS | 00 | 110      | sw rs2’, (4*imm)(rs1’)
        c.and   | AND        | CS | 01 | 10001111 | and rd’, rd’, rs2’
        c.or    | OR         | CS | 01 | 10001110 | or rd’, rd’, rs2’
        c.xor   | XOR        | CS | 01 | 10001101 | xor rd’, rd’, rs2’
        c.sub   | SUB        | CS | 01 | 10001100 | sub rd’, rd’, rs2’
    */ 
    
    assign oALU_OUT     = ((OP == 2'b01) && (FUNC8 == 8'b10001111)) ? iRS1 & iRS2 :         /* and */
                          ((OP == 2'b01) && (FUNC8 == 8'b10001110)) ? iRS1 | iRS2 :         /* or */
                          ((OP == 2'b01) && (FUNC8 == 8'b10001101)) ? iRS1 ^ iRS2 :         /* xor */
                          ((OP == 2'b01) && (FUNC8 == 8'b10001100)) ? iRS1 - iRS2 :         /* sub */
                          32'h0; 

    assign oRAM_DATA    = ((OP == 2'b00) && (FUNC3 == 3'b110)) ? iRS2 :                     /* store word to sp */
                          32'h0;


    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b101)) begin
    //         $display("INSTRUCTION CS -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x, oALU_OUT: 0x%x", oRD, oRS1, oRS2, oALU_OUT);
    //         $display("INSTRUCTION CS -> iRS1: 0x%x, iRS2: 0x%x", iRS1, iRS2);
    //         $display("INSTRUCTION CS -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x, oRAM_ADDR: 0x%x, oRAM_DATA: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR, oRAM_ADDR, oRAM_DATA);
    //     end
    // end


endmodule