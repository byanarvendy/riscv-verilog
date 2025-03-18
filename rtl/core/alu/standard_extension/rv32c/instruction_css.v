
module instruction_css (
    input           iCLK,
    input   [15:0]  iIR,

    input   [31:0]  iRS1, iRS2,
    output  [4:0]   oRS1, oRS2,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    output  [31:0]  oRAM_DATA
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [5:0]   IMM;
    wire    [31:0]  RAM_ADDR, RAM_DATA;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);  


    assign OP           = iIR[1:0];

    assign oRS1         = 5'h2;
    assign oRS2         = iIR[6:2];
    assign IMM          = {iIR[8:7], iIR[12:9], 2'b00};
    assign FUNC3        = iIR[15:13];

    assign RAM_ADDR     = iRS1 + IMM;
    assign oRAM_ADDR    = RAM_ADDR >> 2;

    assign oRAM_CE      = 1'b1;
    assign oRAM_RD      = 1'b0;
    assign oRAM_WR      = 1'b1;

    /*
        c.swsp  | Store Word to SP | CSS | 10 | 110 | sw rs2, (4*imm)(sp)
    */  

    assign oRAM_DATA    = ((OP == 2'b10) && (FUNC3 == 3'b110)) ? iRS2 :         /* store word to sp */
                          32'h0;


    /* DEBUG */
    always @(posedge iCLK) begin
        if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b010)) begin
            $display("INSTRUCTION CSS -> oRS1: 0x%x, oRS2: 0x%x", oRS1, oRS2);
            $display("INSTRUCTION CSS -> iRS1: 0x%x, iRS2: 0x%x", iRS1, iRS2);
            $display("INSTRUCTION CSS -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x, oRAM_ADDR: 0x%x, oRAM_DATA: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR, oRAM_ADDR, oRAM_DATA);
        end
    end


endmodule