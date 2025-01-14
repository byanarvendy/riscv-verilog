module instruction_i (
    input           iCLK,
    input   [31:0]  iIR,
    input   [31:0]  iREG_OUT1,
    input   [31:0]  iREG_OUT2,
    input   [7:0]   iPC,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA,

    output  [4:0]   oRD,
    output  [4:0]   oRS1,
    output  [4:0]   oRS2,
    output  [31:0]  oREG_IN,
    output  [31:0]  oPC
);

    wire    [2:0]   func3;
    wire    [6:0]   opcode;
    wire    [11:0]  imm;
    wire    [31:0]  alu_in1, alu_in2, alu_out;
    wire    [31:0]  ram_address, ram_data;
    wire    [7:0]   ram_data_byte;
    wire    [15:0]  ram_data_half;

    assign opcode       = iIR[6:0];
    assign oRD          = iIR[11:7];
    assign oRS1         = iIR[19:15];
    assign oRS2         = 5'h00;
    assign imm          = iIR[31:20];
    assign func3        = iIR[14:12];

    assign alu_in1      = iREG_OUT1;
    assign alu_in2      = imm;

    /* ram */
    assign ram_address  = alu_in1 + alu_in2;
    assign oRAM_ADDR    = ram_address >> 2;
    assign ram_data     = iRAM_DATA;

    assign ram_data_byte = (ram_address[1:0] == 2'b00) ? ram_data[7:0]   :
                           (ram_address[1:0] == 2'b01) ? ram_data[15:8]  :
                           (ram_address[1:0] == 2'b10) ? ram_data[23:16] :
                           (ram_address[1:0] == 2'b11) ? ram_data[31:24] :
                           8'h00;

    assign ram_data_half = (ram_address[1] == 1'b0) ? ram_data[15:0]  :
                           (ram_address[1] == 1'b1) ? ram_data[31:16] :
                           16'h0000;

    assign alu_out = (opcode == 7'b0010011) ?                                                   /* I1: immediate operations */
                        ((func3 == 3'h0) ? alu_in1 + alu_in2                                    :       /* add immediate */
                         (func3 == 3'h4) ? alu_in1 ^ alu_in2                                    :       /* xor immediate */
                         (func3 == 3'h6) ? alu_in1 | alu_in2                                    :       /* or immediate */
                         (func3 == 3'h7) ? alu_in1 & alu_in2                                    :       /* and immediate */
                         (func3 == 3'h1) ? alu_in1 << alu_in2[4:0]                              :       /* shift left logical immediate */
                         (func3 == 3'h5 && alu_in2[11:5] == 7'h00) ? alu_in1 >> alu_in2[4:0]    :       /* shift right logical */
                         (func3 == 3'h5 && alu_in2[11:5] == 7'h20) ? alu_in1 >>> alu_in2[4:0]   :       /* shift right arithmetic */
                         (func3 == 3'h2) ? ($signed(alu_in1) < $signed(alu_in2[4:0]) ? 1 : 0)   :       /* set less than, signed */
                         (func3 == 3'h3) ? (alu_in1 < alu_in2[4:0] ? 1 : 0)                     :       /* set less than, unsigned */
                         32'h00000000) :

                     (opcode == 7'b0000011) ?                                                   /* I2: load operations */
                        ((func3 == 3'h0) ? $signed(ram_data_byte)                               :       /* load byte */
                         (func3 == 3'h1) ? $signed(ram_data_half)                               :       /* load half */
                         (func3 == 3'h2) ? ram_data                                             :       /* load word */
                         (func3 == 3'h4) ? ram_data_byte                                        :       /* load byte (unsigned) */
                         (func3 == 3'h5) ? ram_data_half                                        :       /* load half (unsigned) */
                         32'h00000000) :

                     (opcode == 7'b1100111) ?                                                   /* I3: jump and link register */
                        ((func3 == 3'h0) ? alu_in1 + alu_in2 : 32'h00000000) :
                         32'h00000000;

    assign oREG_IN  = (opcode == 7'b1100111 && func3 == 3'h0) ? iPC + 4 : alu_out;
    assign oPC      = (opcode == 7'b1100111 && func3 == 3'h0) ? alu_in1 + alu_in2 : 32'h00000000;

    assign oRAM_CE = (opcode == 7'b0000011) ? 1'b1 : 1'b0;
    assign oRAM_RD = (opcode == 7'b0000011) ? 1'b1 : 1'b0;

    // always @(posedge iCLK) begin
    //     if(iIR[6:0] == 7'b0010011) begin
    //     	$display("INSRUCTION TYPE I1 -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x", oRD, oRS1, oRS2);
	// 	    $display("INSRUCTION TYPE I1 -> alu_in1: 0x%x, alu_in2: 0x%x, alu_out: 0x%x", alu_in1, alu_in2, alu_out);
    //     end
    //     if(iIR[6:0] == 7'b0000011) begin
    //         $display("INSRUCTION TYPE I2 -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x, oRAM_ADDR: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR, oRAM_ADDR);
    //     	$display("INSRUCTION TYPE I2 -> oRD: 0x%x, oRS1: 0x%x, oRS2: 0x%x, func3: 0x%x, ram_data: 0x%x", oRD, oRS1, oRS2, func3, ram_data);
	// 	    $display("INSRUCTION TYPE I2 -> alu_in1: 0x%x, alu_in2: 0x%x, alu_out: 0x%x", alu_in1, alu_in2, alu_out);
    //     end

    // 	if(iIR[6:0] == 7'b1100111) begin
    //     	$display("INSRUCTION TYPE I3 -> oRD: 0x%x, oRS1: 0x%x", oRD, oRS1);
	// 	    $display("INSRUCTION TYPE I3 -> oRD: 0x%x, oRS1: 0x%x, alu_in1: 0x%x, alu_in2: 0x%x, oREG_IN: 0x%x, ipc: 0x%x, opc: 0x%x", oRD, oRS1, alu_in1, alu_in2, oREG_IN, iPC, oPC);
    //     end
    // end

endmodule
