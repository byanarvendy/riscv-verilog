module instruction_b (
    input           iCLK,
    input   [31:0]  iIR,
    input   [7:0]   iPC,

    input   [31:0]  iREG_OUT1,
    input   [31:0]  iREG_OUT2,

    output  [4:0]   oRS1,
    output  [4:0]   oRS2,
    output  [31:0]  oPCBR
);

	wire    [2:0]   func3;
	wire    [31:0]  alu_in1, alu_in2, alu_out;

    wire signed	[31:0] imm;

	assign func3    = iIR[14:12];
	assign oRS1     = iIR[19:15];
	assign oRS2     = iIR[24:20];

	assign imm      = {{19{iIR[31]}}, iIR[31], iIR[7], iIR[30:25], iIR[11:8], 1'b0};
	
	assign alu_in1  = iREG_OUT1;
	assign alu_in2  = iREG_OUT2;

    assign alu_out  = (func3 == 3'h0) ? (alu_in1 == alu_in2 ? iPC + imm : iPC + 4) :        /* beq */
                      (func3 == 3'h1) ? (alu_in1 != alu_in2 ? iPC + imm : iPC + 4) :        /* bne */
                      (func3 == 3'h4) ? (alu_in1 <  alu_in2 ? iPC + imm : iPC + 4) :        /* blt */
                      (func3 == 3'h5) ? (alu_in1 >= alu_in2 ? iPC + imm : iPC + 4) :        /* bge */
                      (func3 == 3'h6) ? (alu_in1 <  alu_in2 ? iPC + imm : iPC + 4) :        /* bltu */
                      (func3 == 3'h7) ? (alu_in1 >= alu_in2 ? iPC + imm : iPC + 4) :        /* bgeu */
                      32'h0;

	assign oPCBR    = alu_out;


    /* DEBUG */
    always @(posedge iCLK) begin
        if (iIR[6:0] == 7'b1100011) begin
            $display("INSTRUCTION B -> oRS1: 0x%x, oRS2: 0x%x, oPCBR: 0x%x", oRS1, oRS2, oPCBR);
            $display("INSTRUCTION B -> iREG_OUT1: 0x%x, iREG_OUT2: 0x%x", iREG_OUT1, iREG_OUT2);
        end
    end

    
endmodule