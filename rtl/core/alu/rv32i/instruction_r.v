module instruction_r (
    input           iCLK,
    input   [31:0]  iIR,
    input   [31:0]  iALU_IN1,
    input   [31:0]  iALU_IN2,
    output  [4:0]   oRD,
    output  [4:0]   oRS1,
    output  [4:0]   oRS2,
    output  [31:0]  oALU_OUT
);

    wire    [2:0]   func3;
    wire    [6:0]   func7;
    wire    [9:0]   func37;
    wire    [31:0]  alu_in1, alu_in2, alu_out;


    /* mux opcode r m */
    wire   OPCODE_R_M;
    assign OPCODE_R_M = opcode_r_m_module.opcode_r_m(iIR);


    assign oRD      = iIR[11:7];
    assign oRS1     = iIR[19:15];
    assign oRS2     = iIR[24:20];
    assign func3    = iIR[14:12];
    assign func7    = iIR[31:25];

    assign alu_in1  = iALU_IN1;
    assign alu_in2  = iALU_IN2;

    assign func37   = {func3, func7};

    assign alu_out  = (func37 == {3'h0, 7'h00}) ? alu_in1 + alu_in2                             :       /* add */
                      (func37 == {3'h0, 7'h20}) ? alu_in1 - alu_in2                             :       /* sub */
                      (func37 == {3'h4, 7'h00}) ? alu_in1 ^ alu_in2                             :       /* xor */
                      (func37 == {3'h6, 7'h00}) ? alu_in1 | alu_in2                             :       /* or */
                      (func37 == {3'h7, 7'h00}) ? alu_in1 & alu_in2                             :       /* and */
                      (func37 == {3'h1, 7'h00}) ? alu_in1 << alu_in2                            :       /* shift left logical */
                      (func37 == {3'h5, 7'h00}) ? alu_in1 >> alu_in2                            :       /* shift right logical */
                      (func37 == {3'h5, 7'h20}) ? alu_in1 >>> alu_in2                           :       /* shift right arithmetic */
                      (func37 == {3'h2, 7'h00}) ? $signed(alu_in1) < $signed(alu_in2) ? 1 : 0   :       /* set less than, signed */
                      (func37 == {3'h3, 7'h00}) ? alu_in1 < alu_in2 ? 1 : 0                     :       /* set less than, unsigned */
                      32'h00000000;
                   
    assign oALU_OUT = alu_out;


    /* DEBUG */
    // always @(posedge iCLK) begin
    //     if ((iIR[6:0] == 7'b0110011) && (OPCODE_R_M == 1'b0)) begin
    //         $display("INSTRUCTION R -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x, oALU_OUT: 0x%x", oRD, oRS1, oRS2, oALU_OUT);
    //         $display("INSTRUCTION R -> iALU_IN1: 0x%x, iALU_IN2: 0x%x", iALU_IN1, iALU_IN2);
    //     end
    // end


endmodule