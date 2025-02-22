module instruction_ci (
    input           iCLK,
    input   [15:0]  iIR,

    input   [31:0]  iRS1, iRS2,
    output  [4:0]   oRD, oRS1, oRS2,
    output  [31:0]  oALU_OUT,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA
);

    wire    [1:0]   OP;
    wire    [2:0]   FUNC3;
    wire    [31:0]  RAM_ADDR, RAM_DATA;


    /* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR);   


    assign oRD          = iIR[11:7];
    assign oRS1         = iIR[11:7];
    assign oRS2         = 5'h2;

    assign OP           = iIR[1:0];
    assign FUNC3        = iIR[15:13];

    assign RAM_ADDR     = iRS2 + {iIR[3:2], iIR[12], iIR[6:4], 2'b00};
    assign oRAM_ADDR    = RAM_ADDR >> 2;
    assign RAM_DATA     = iRAM_DATA;

    assign oRAM_CE      = 1'b1;
    assign oRAM_RD      = 1'b1;
    assign oRAM_WR      = 1'b0;

    /*
        c.lwsp      | Load Word from SP         | CI | 10 | 010 | lw rd, (4*imm)(sp)
        c.li        | Load Immediate            | CI | 01 | 010 | addi rd, x0, imm
        c.lui       | Load Upper Imm            | CI | 01 | 011 | lui rd, imm
        c.addi      | ADD Immediate             | CI | 01 | 000 | addi rd, rd, imm
        c.addi16sp  | ADD Imm * 16 to SP        | CI | 01 | 011 | addi sp, sp, 16*imm
        c.slli      | Shift Left Logical Imm    | CI | 10 | 000 | slli rd, rd, imm
        c.nop       | No OPeration              | CI | 01 | 000 | addi x0, x0, 0
    */  

    assign oALU_OUT = ((OP == 2'b10) && (FUNC3 == 3'b010) && (oRD != 5'h0))                     
                            ? RAM_DATA                                                                                              :   /* load word from sp */
                      ((OP == 2'b01) && (FUNC3 == 3'b010) && (oRD != 5'h0))                     
                            ? {{26{iIR[12]}}, {iIR[12], iIR[6:2]}}                                                                  :   /* load immediate */
                      ((OP == 2'b01) && (FUNC3 == 3'b011) && (oRD != 5'h0) && (oRD != 5'h2) && ({iIR[12], iIR[6:2]} != 6'h0))    
                            ? {{18{iIR[12]}}, iIR[12], iIR[6:2], 12'h0}                                                             :   /* load upper imm */
                      ((OP == 2'b01) && (FUNC3 == 3'b000) && (oRD != 5'h0) && ({iIR[12], iIR[6:2]} != 6'h0))    
                            ? iRS1 + {{26{iIR[12]}}, iIR[12], iIR[6:2]}                                                             :   /* add immediate */
                      ((OP == 2'b01) && (FUNC3 == 3'b011) && (oRD != 5'h2) && ({iIR[12], iIR[4:3], iIR[5], iIR[2], iIR[4]} != 6'h0))                     
                            ? iRS1 + ({{26{iIR[12]}}, iIR[12], iIR[4:3], iIR[5], iIR[2], iIR[4]} * 16)                              :   /* add imm * 16 to sp */
                      ((OP == 2'b10) && (FUNC3 == 3'b000) && (oRD != 5'h0))                                      
                            ? iRS1 << {iIR[12], iIR[6:2]}                                                                           :   /* shift left logical imm */
                      32'h0;


    /* DEBUG */
    always @(posedge iCLK) begin
        if ((iIR[1:0] != 2'b11) && (C_MUX == 3'b001)) begin
            $display("INSTRUCTION CI -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x, oALU_OUT: 0x%x", oRD, oRS1, oRS2, oALU_OUT);
            $display("INSTRUCTION CI -> iRS1: 0x%x, iRS2: 0x%x", iRS1, iRS2);
            $display("INSTRUCTION CI -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x, oRAM_ADDR: 0x%x, iRAM_DATA: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR, oRAM_ADDR, iRAM_DATA);
        end
    end


endmodule