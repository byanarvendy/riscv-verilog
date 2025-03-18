module instruction_s (
    input           iCLK,
    input   [31:0]  iIR,
    input   [31:0]  iREG_OUT1,
    input   [31:0]  iREG_OUT2,
    output  [4:0]   oRD,
    output  [4:0]   oRS1,
    output  [4:0]   oRS2,
    output  [31:0]  oREG_IN,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA,
    output  [31:0]  oRAM_DATA
);

    wire    [2:0]   func3;
    wire    [11:0]  imm;
    wire    [31:0]  alu_in1, alu_in2, alu_out, ram_address, ram_data_rd;
    wire    [31:0]  ram_data_byte_wr, ram_data_half_wr, ram_data_word_wr;
    wire    [15:0]  ram_data_half;

    wire            ram_wr;

    assign oRD          = 5'h00;
    assign oRS1         = iIR[19:15];
    assign oRS2         = iIR[24:20];

    assign imm          = {iIR[31:25], iIR[11:7]};
    assign func3        = iIR[14:12];

    assign alu_in1      = iREG_OUT1;
    assign alu_in2      = iREG_OUT2;

    assign oRAM_WR      = 1'b1;
    assign oRAM_CE      = 1'b1;

    assign ram_address  = alu_in1 + imm;
    assign oRAM_ADDR    = ram_address >> 2;

    assign ram_data_rd  = iRAM_DATA;

    assign ram_data_byte_wr = (ram_address[1:0] == 2'b00) ? (alu_in2[7:0]           | (ram_data_rd & 32'hffffff00)) :
                              (ram_address[1:0] == 2'b01) ? ((alu_in2[7:0] << 8)    | (ram_data_rd & 32'hffff00ff)) :
                              (ram_address[1:0] == 2'b10) ? ((alu_in2[7:0] << 16)   | (ram_data_rd & 32'hff00ffff)) :
                              (ram_address[1:0] == 2'b11) ? ((alu_in2[7:0] << 24)   | (ram_data_rd & 32'h00ffffff)) :
                              32'h00;
    
    assign ram_data_half_wr = (ram_address[1] == 1'b0) ? ((alu_in2[15:0])           | (ram_data_rd & 32'hffff0000)) :
                              (ram_address[1] == 1'b1) ? ((alu_in2[15:0] << 16)     | (ram_data_rd & 32'h0000ffff)) :
                              32'h00;

    assign ram_data_word_wr = alu_in2;

    assign oRAM_DATA    = (func3 == 3'h0) ? ram_data_byte_wr :       /* store byte */
                          (func3 == 3'h1) ? ram_data_half_wr :       /* store half */
                          (func3 == 3'h2) ? ram_data_word_wr :       /* store word */
                          32'h00000000;

    assign oREG_IN      = 32'h00;
    

    /* DEBUG */
    always @(posedge iCLK) begin
        if (iIR[6:0] == 7'b0100011) begin
            $display("INSTRUCTION S -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x, oREG_IN: 0x%x", oRD, oRS1, oRS2, oREG_IN);
            $display("INSTRUCTION S -> iREG_OUT1: 0x%x, iREG_OUT2: 0x%x", iREG_OUT1, iREG_OUT2);
            $display("INSTRUCTION S -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x, oRAM_ADDR: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR, oRAM_ADDR);
            $display("INSTRUCTION S -> iRAM_DATA: 0x%x, oRAM_DATA: 0x%x", iRAM_DATA, oRAM_DATA);
        end
    end


endmodule
