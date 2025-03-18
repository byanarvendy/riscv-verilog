module instruction_cl (
    input           iCLK,
    input   [15:0]  iIR,

    input   [31:0]  iRS,
    output  [4:0]   oRS, oRD,
    output  [31:0]  oALU_OUT,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [9:0]   IMM;
    wire    [31:0]  RAM_ADDR, RAM_DATA;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);


    assign OP           = iIR[1:0];

    assign oRS          = 5'h8 + iIR[9:7];
    assign oRD          = 5'h8 + iIR[4:2];
    assign IMM          = {iIR[5], iIR[12:10], iIR[6], 2'b00};
    assign FUNC3        = iIR[15:13];

    assign RAM_ADDR     = iRS + IMM;
    assign oRAM_ADDR    = RAM_ADDR >> 2;
    assign RAM_DATA     = iRAM_DATA;

    assign oRAM_CE      = 1'b1;
    assign oRAM_RD      = 1'b1;
    assign oRAM_WR      = 1'b0;

    /*
        c.lw    | Load Word | CL | 00 | 010 | lw rd’, (4*imm)(rs1’)
    */  

    assign oALU_OUT     = ((OP == 2'b00) && (FUNC3 == 3'b010)) ? RAM_DATA :         /* load word */
                          32'h0;


    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b100)) begin
    //         $display("INSTRUCTION CL -> iRS: 0x%x, oRS: 0x%x, oRD: 0x%x, oALU_OUT: 0x%x", iRS, oRS, oRD, oALU_OUT);
    //         $display("INSTRUCTION CL -> oALU_OUT: 0x%x, IMM: 0x%x, oRAM_ADDR: 0x%x, RAM_DATA: 0x%x", oALU_OUT, IMM, oRAM_ADDR, RAM_DATA);
    //         $display("INSTRUCTION CL -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR);
    //     end
    // end
    

endmodule