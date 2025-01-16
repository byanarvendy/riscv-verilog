`include "rtl/core/register_file.v"
`include "rtl/core/alu/alu.v"
`include "rtl/soc/ram/ram_mux.v"
`include "rtl/core/alu/opcode_r_m.v"

module riscv32_cpu (
    input           iRST,
    input           iCLK,

    /* rom */
    output          oROM_CE, oROM_RD,
    output  [7:0]   oROM_ADDR,
    input   [31:0]  iROM_DATA,

    /* ram */
    output          oRAM_CE, oRAM_RD, oRAM_WR,
    output  [31:0]  oRAM_DATA,
    output  [7:0]   oRAM_ADDR,
    input   [31:0]  iRAM_DATA,

    input   [1:0]   iMODE,
    input   [7:0]   iSW,
    output  [31:0]  oREG32
);

    integer i;

    reg     [7:0]   PC, iRAM_ADDR;
    reg             RAM_WR, RAM_RD;

    /* register file */
    wire    [4:0]   RD, RS1, RS2;
    wire    [31:0]  ALU_IN1, ALU_IN2, ALU_OUT;

    /* branch */
    wire    [31:0]  BR_B, BR_J, BR_I;

    /* rom */
    wire            ROM_CE, ROM_RD, oRAM_WR;
    wire    [31:0]  iROM_DATA, IR, BR;
    wire    [6:0]   OPCODE;

    assign ROM_CE = 1;
    assign ROM_RD = 1;

    assign OPCODE       = iROM_DATA[6:0];
    assign oROM_ADDR    = (PC >> 2);
    assign IR           = iROM_DATA;

    /* ram */
    wire            RAM_CE_I, RAM_RD_I, RAM_WR_I;       /* instrucion i */
    wire    [31:0]  RAM_DATA_WR_I, RAM_DATA_RD_I;
    wire    [7:0]   RAM_ADDR_I;
    wire            RAM_CE_S, RAM_RD_S, RAM_WR_S;       /* instrucion s */
    wire    [31:0]  RAM_DATA_WR_S, RAM_DATA_RD_S;
    wire    [7:0]   RAM_ADDR_S;
    wire            RAM_CE_A, RAM_RD_A, RAM_WR_A;       /* extension a */
    wire    [31:0]  RAM_DATA_WR_A, RAM_DATA_RD_A;
    wire    [7:0]   RAM_ADDR_A;

    assign oRAM_WR = RAM_WR;
	assign oRAM_RD = RAM_RD;

    /* mux opcode r m*/
    wire   opcode_r_m;
    assign opcode_r_m = opcode_r_m_module.opcode_r_m(IR);

    register_file u1 (
        .iCLK(iCLK), .iRST(iRST),

        .iRD(RD), .iRS1(RS1), .iRS2(RS2),
        .oALU_IN1(ALU_IN1), .oALU_IN2(ALU_IN2), .iALU_OUT(ALU_OUT)
    );
        
    alu u2 (
        .iCLK(iCLK), .iRST(iRST), .OPCODE(OPCODE), .IR(iROM_DATA),

        .ALU_IN1(ALU_IN1), .ALU_IN2(ALU_IN2), .PC(PC),
        .ALU_OUT(ALU_OUT), .BR_B(BR_B), .BR_J(BR_J), .BR_I(BR_I),

        .RD(RD), .RS1(RS1), .RS2(RS2),

        .RAM_CE_I(RAM_CE_I), .RAM_RD_I(RAM_RD_I), .RAM_WR_I(RAM_WR_I),
        .RAM_ADDR_I(RAM_ADDR_I), .RAM_DATA_WR_I(RAM_DATA_WR_I),

        .RAM_CE_S(RAM_CE_S), .RAM_RD_S(RAM_RD_S), .RAM_WR_S(RAM_WR_S),
        .RAM_ADDR_S(RAM_ADDR_S), .RAM_DATA_WR_S(RAM_DATA_WR_S),

        .RAM_CE_A(RAM_CE_A), .RAM_RD_A(RAM_RD_A), .RAM_WR_A(RAM_WR_A),
        .RAM_ADDR_A(RAM_ADDR_A), .RAM_DATA_WR_A(RAM_DATA_WR_A),

        .RAM_DATA_RD_I(iRAM_DATA), .RAM_DATA_RD_S(iRAM_DATA), .RAM_DATA_RD_A(iRAM_DATA),
        .oRAM_DATA(oRAM_DATA)
    );

    ram_mux u3 (
        .OPCODE(OPCODE),

        .iRAM_CE_I(RAM_CE_I), .iRAM_RD_I(RAM_RD_I), .iRAM_WR_I(RAM_WR_I),
        .iRAM_ADDR_I(RAM_ADDR_I), .iRAM_DATA_WR_I(RAM_DATA_WR_I),
        .oRAM_DATA_RD_I(RAM_DATA_RD_I),

        .iRAM_CE_S(RAM_CE_S), .iRAM_RD_S(RAM_RD_S), .iRAM_WR_S(RAM_WR_S),
        .iRAM_ADDR_S(RAM_ADDR_S), .iRAM_DATA_WR_S(RAM_DATA_WR_S),
        .oRAM_DATA_RD_S(RAM_DATA_RD_S),

        .iRAM_CE_A(RAM_CE_A), .iRAM_RD_A(RAM_RD_A), .iRAM_WR_A(RAM_WR_A),
        .iRAM_ADDR_A(RAM_ADDR_A), .iRAM_DATA_WR_A(RAM_DATA_WR_A),
        .oRAM_DATA_RD_A(RAM_DATA_RD_A),

        .oRAM_CE(oRAM_CE), .oRAM_RD(oRAM_RD), .oRAM_WR(oRAM_WR),
        .oRAM_ADDR(oRAM_ADDR), .oRAM_DATA_WR(oRAM_DATA),
        
        .iRAM_DATA_RD(iRAM_DATA)
    );

	initial begin
		i   = 0;
        PC  = 8'b00000000;
	end

    always @(posedge iCLK or posedge iRST) begin
        if (iRST) begin
            PC <= 8'b0;
            i  <= 0;
        end else begin
            $display("#clock: %0d", i);
            
            case (OPCODE)
                7'b0110011:                               
                    if (opcode_r_m == 1'b0)             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: R", PC, IR, OPCODE);
                    else if (opcode_r_m == 1'b1)        $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, EXTENSION TYPE: RV32M", PC, IR, OPCODE);                  
                7'b0010011, 7'b0000011, 7'b1100111:     $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: I", PC, IR, OPCODE);
                7'b0100011:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: S", PC, IR, OPCODE);
                7'b0110111, 7'b0010111:                 $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: U", PC, IR, OPCODE);
                7'b1100011:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: B", PC, IR, OPCODE);
                7'b1101111:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: J", PC, IR, OPCODE);
                7'b0101111:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, EXTENSION TYPE: RV32A", PC, IR, OPCODE);  
            endcase

            if (OPCODE == 7'b0000011) begin
                RAM_WR = 0; RAM_RD = 1;
            end 
            else if (OPCODE == 7'b0100011) begin
                RAM_WR = 1; RAM_RD = 0;
            end
            else if (OPCODE == 7'b0101111) begin
                RAM_WR = 1; RAM_RD = 1;
            end

            PC <= (OPCODE == 7'b1100011) ? (BR_B) : 
                  (OPCODE == 7'b1101111) ? (BR_J) :
                  (OPCODE == 7'b1100111) ? (BR_I) :
                  PC + 4;

            i <= i + 1;
        end
    end

    assign oREG32 = ALU_OUT;

endmodule