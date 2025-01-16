module rv32a_atomic (
    input           iCLK,
    input   [31:0]  iIR,
    input   [31:0]  iALU_IN1,
    input   [31:0]  iALU_IN2,
    output  [4:0]   oRD,
    output  [4:0]   oRS1,
    output  [4:0]   oRS2,
    output  [31:0]  oALU_OUT,

    output          oRAM_CE,
    output          oRAM_RD,
    output          oRAM_WR,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA,
    output  [31:0]  oRAM_DATA
);
    reg rd_ram;

    wire            aq, rl;
    wire    [2:0]   func3;
    wire    [4:0]   func5;
    wire    [6:0]   func35;
    wire    [31:0]  alu_in1, alu_in2, alu_out;
    wire    [31:0]  ram_address, ram_data;

    assign oRD          = iIR[11:7];
    assign oRS1         = iIR[19:15];
    assign oRS2         = iIR[24:20];
    assign func3        = iIR[14:12];
    assign func5        = iIR[31:27];

    assign alu_in1      = iALU_IN1;
    assign alu_in2      = iALU_IN2;

    assign func35       = {func3, func5};

    /* ram */
    assign ram_address  = alu_in1;
    assign oRAM_ADDR    = ram_address >> 2;
    assign ram_data     = iRAM_DATA;

    assign oRAM_WR      = 1'b1;
    assign oRAM_RD      = 1'b1;
    assign oRAM_CE      = 1'b1;

    /* reserve ram */
    reg     [31:0]  res_address;
    reg             reserved;

    always @(posedge iCLK) begin
        if (func5 == 5'h02) begin 
            res_address <= ram_address;
            reserved    <= 1'b1;
        end 
        else if (func5 == 5'h03) begin
            if (reserved && (res_address == ram_address)) begin
                reserved <= 1'b0;
            end
        end
    end
    /* ===== */

    assign alu_out      = (func35 == {3'h2, 5'h02}) ? ram_data                                              :       /* load reserved */
                          (func35 == {3'h2, 5'h03}) ? ((reserved && (res_address == ram_address)) ? 0 : 1)  :       /* store conditional */
                          (func35 == {3'h2, 5'h01}) ? ram_data                                              :       /* atomic swap */
                          (func35 == {3'h2, 5'h00}) ? ram_data + alu_in2                                    :       /* atomic add */
                          (func35 == {3'h2, 5'h0C}) ? ram_data & alu_in2                                    :       /* atomic and */
                          (func35 == {3'h2, 5'h0A}) ? ram_data | alu_in2                                    :       /* atomic or */
                          (func35 == {3'h2, 5'h04}) ? ram_data ^ alu_in2                                    :       /* atomic xor */
                          (func35 == {3'h2, 5'h14}) ? (ram_data > alu_in2) ? ram_data : alu_in2             :       /* atomic max */
                          (func35 == {3'h2, 5'h10}) ? (ram_data < alu_in2) ? ram_data : alu_in2             :       /* atomic min */
                          32'h00000000;

    assign oRAM_DATA    = (rd_ram == 1'b1) ? alu_out                            : 
                          (reserved && (res_address == ram_address)) ? alu_in2  :
                          32'h00000000;

    assign oALU_OUT     = alu_out;

    always @(posedge iCLK) begin
        case (func5)
            5'h01, 5'h00, 5'h0C, 5'h0A, 5'h04, 5'h14, 5'h10: rd_ram = 1'b1;
            default: rd_ram = 1'b0;
        endcase
    end

endmodule