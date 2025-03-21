module instruction_j (
    input           iCLK,
    input   [31:0]  iIR,
    input   [7:0]   iPC,

    output  [4:0]   oRD,
    output  [31:0]  oREG_IN,
    output  [31:0]  oPCBR
);

    wire        [6:0]   opcode;
    wire        [31:0]  imm;
    wire        [31:0]  jump;

    assign opcode   = iIR[6:0];
    assign oRD      = iIR[11:7];

    assign imm      = {{11{iIR[31]}}, iIR[31], iIR[19:12], iIR[20], iIR[30:21], 1'b0};

    assign oREG_IN  = iPC + 4;
    assign oPCBR    = iPC+ imm;

    
    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if (opcode== 7'b1101111) begin
    //         $display("INSTRUCTION J -> iPC: 0x%x, oRD: 0x%x, oREG_IN: 0x%x, oPCBR: 0x%x", iPC, oRD, oREG_IN, oPCBR);
    //     end
    // end


endmodule
