`include "rtl/core/register_file/x_register_file.v"
`include "rtl/core/register_file/f_register_file.v"
`include "rtl/core/alu/alu.v"
`include "rtl/soc/ram/ram_mux.v"
`include "rtl/core/alu/opcode_r_m.v"
`include "rtl/core/alu/standard_extension/rv32c/instruction_c_mux.v"

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
    reg             RAM_WR, RAM_RD, C_BUFFER;

    /* register file */
    wire    [4:0]   X_RD, X_RS1, X_RS2, X_RS3;                      /* xrf */
    wire    [31:0]  X_ALU_IN1, X_ALU_IN2, X_ALU_IN3, X_ALU_OUT;
    wire    [4:0]   F_RD, F_RS1, F_RS2, F_RS3;                      /* frf */
    wire    [31:0]  F_ALU_IN1, F_ALU_IN2, F_ALU_IN3, F_ALU_OUT;

    /* branch */
    wire    [31:0]  BR_B, BR_J, BR_I;

    /* rom */
    wire            ROM_CE, ROM_RD, oRAM_WR;
    wire    [1:0]   OP;
    wire    [6:0]   OPCODE;
    wire    [15:0]  IR_C;
    wire    [31:0]  CURRENT_INSTRUCTION, IR, BR;

    assign ROM_CE = 1;
    assign ROM_RD = 1;

    assign oROM_ADDR            = (PC >> 2);
    assign CURRENT_INSTRUCTION  = iROM_DATA;

    /* 32-bit */
    assign IR                   = (CURRENT_INSTRUCTION[1:0] == 2'b11) ? CURRENT_INSTRUCTION                         : 32'h0;
    assign OPCODE               = (CURRENT_INSTRUCTION[1:0] == 2'b11) ? IR[6:0]                                     : 6'h0;
    /* 16-bit */
    assign IR_C                 = (CURRENT_INSTRUCTION[1:0] != 2'b11) ? 
                                  (C_BUFFER ? CURRENT_INSTRUCTION[31:16] : CURRENT_INSTRUCTION[15:0])               : 16'hx;
    assign OP                   = (CURRENT_INSTRUCTION[1:0] != 2'b11) ? IR_C[1:0]                                   : 2'b11;


    /* ram */
    wire            RAM_CE_I, RAM_RD_I, RAM_WR_I;           /* instrucion i */
    wire    [31:0]  RAM_DATA_WR_I, RAM_DATA_RD_I;
    wire    [7:0]   RAM_ADDR_I;
    wire            RAM_CE_S, RAM_RD_S, RAM_WR_S;           /* instrucion s */
    wire    [31:0]  RAM_DATA_WR_S, RAM_DATA_RD_S;
    wire    [7:0]   RAM_ADDR_S;
    wire            RAM_CE_A, RAM_RD_A, RAM_WR_A;           /* extension a */
    wire    [31:0]  RAM_DATA_WR_A, RAM_DATA_RD_A;
    wire    [7:0]   RAM_ADDR_A;
    wire            RAM_CE_F, RAM_RD_F, RAM_WR_F;           /* extension f */
    wire    [31:0]  RAM_DATA_WR_F, RAM_DATA_RD_F;
    wire    [7:0]   RAM_ADDR_F;
    /* ram rv32c */
    wire            RAM_CE_CI, RAM_RD_CI, RAM_WR_CI;        /* extension ci */
    wire    [31:0]  RAM_DATA_RD_CI;
    wire    [7:0]   RAM_ADDR_CI;
    wire            RAM_CE_CSS, RAM_RD_CSS, RAM_WR_CSS;     /* extension css */
    wire    [31:0]  RAM_DATA_WR_CSS;
    wire    [7:0]   RAM_ADDR_CSS;
    wire            RAM_CE_CL, RAM_RD_CL, RAM_WR_CL;        /* extension cl */
    wire    [31:0]  RAM_DATA_RD_CL;
    wire    [7:0]   RAM_ADDR_CL;
    wire            RAM_CE_CS, RAM_RD_CS, RAM_WR_CS;        /* extension cs */
    wire    [31:0]  RAM_DATA_WR_CS;
    wire    [7:0]   RAM_ADDR_CS;

    assign oRAM_WR = RAM_WR;
	assign oRAM_RD = RAM_RD;

    /* mux opcode r m*/
    reg   OPCODE_R_M;

    /* mux instruction c*/
    reg     [2:0]   C_MUX;

    x_register_file u1 (
        .iCLK(iCLK), .iRST(iRST),

        .iRD(X_RD), .iRS1(X_RS1), .iRS2(X_RS2), .iRS3(X_RS3),
        .oALU_IN1(X_ALU_IN1), .oALU_IN2(X_ALU_IN2), .oALU_IN3(X_ALU_IN3), .iALU_OUT(X_ALU_OUT)
    );

    f_register_file u2 (
        .iCLK(iCLK), .iRST(iRST),

        .iRD(F_RD), .iRS1(F_RS1), .iRS2(F_RS2), .iRS3(F_RS3),
        .oALU_IN1(F_ALU_IN1), .oALU_IN2(F_ALU_IN2), .oALU_IN3(F_ALU_IN3), .iALU_OUT(F_ALU_OUT)
    );
        
    alu u3 (
        .iCLK(iCLK), .iRST(iRST), 
        .PC(PC), .OPCODE(OPCODE), .IR_C(IR_C), .IR(IR),

        .X_ALU_IN1(X_ALU_IN1), .X_ALU_IN2(X_ALU_IN2), .X_ALU_OUT(X_ALU_OUT), 
        .F_ALU_IN1(F_ALU_IN1), .F_ALU_IN2(F_ALU_IN2), .F_ALU_IN3(F_ALU_IN3), .F_ALU_OUT(F_ALU_OUT), 
        
        .BR_B(BR_B), .BR_J(BR_J), .BR_I(BR_I),

        .X_RD(X_RD), .X_RS1(X_RS1), .X_RS2(X_RS2),
        .F_RD(F_RD), .F_RS1(F_RS1), .F_RS2(F_RS2), .F_RS3(F_RS3),

        .RAM_CE_I(RAM_CE_I), .RAM_RD_I(RAM_RD_I), .RAM_WR_I(RAM_WR_I),
        .RAM_ADDR_I(RAM_ADDR_I), .RAM_DATA_WR_I(RAM_DATA_WR_I),

        .RAM_CE_S(RAM_CE_S), .RAM_RD_S(RAM_RD_S), .RAM_WR_S(RAM_WR_S),
        .RAM_ADDR_S(RAM_ADDR_S), .RAM_DATA_WR_S(RAM_DATA_WR_S),

        .RAM_CE_A(RAM_CE_A), .RAM_RD_A(RAM_RD_A), .RAM_WR_A(RAM_WR_A),
        .RAM_ADDR_A(RAM_ADDR_A), .RAM_DATA_WR_A(RAM_DATA_WR_A),

        .RAM_CE_F(RAM_CE_F), .RAM_RD_F(RAM_RD_F), .RAM_WR_F(RAM_WR_F),
        .RAM_ADDR_F(RAM_ADDR_F), .RAM_DATA_WR_F(RAM_DATA_WR_F),
    
        .RAM_CE_CI(RAM_CE_CI), .RAM_RD_CI(RAM_RD_CI), .RAM_WR_CI(RAM_WR_CI),
        .RAM_ADDR_CI(RAM_ADDR_CI),

        .RAM_CE_CSS(RAM_CE_CSS), .RAM_RD_CSS(RAM_RD_CSS), .RAM_WR_CSS(RAM_WR_CSS),
        .RAM_ADDR_CSS(RAM_ADDR_CSS), .RAM_DATA_WR_CSS(RAM_DATA_WR_CSS),

        .RAM_CE_CL(RAM_CE_CL), .RAM_RD_CL(RAM_RD_CL), .RAM_WR_CL(RAM_WR_CL),
        .RAM_ADDR_CL(RAM_ADDR_CL),

        .RAM_CE_CS(RAM_CE_CS), .RAM_RD_CS(RAM_RD_CS), .RAM_WR_CS(RAM_WR_CS),
        .RAM_ADDR_CS(RAM_ADDR_CS), .RAM_DATA_WR_CS(RAM_DATA_WR_CS),

        .RAM_DATA_RD_I(iRAM_DATA), .RAM_DATA_RD_S(iRAM_DATA), .RAM_DATA_RD_A(iRAM_DATA), .RAM_DATA_RD_F(iRAM_DATA),

        .RAM_DATA_RD_CI(iRAM_DATA), .RAM_DATA_RD_CL(iRAM_DATA),

        .oRAM_DATA(oRAM_DATA)
    );

    ram_mux u4 (
        .iCLK(iCLK), .OPCODE(OPCODE),
        .iIR_C(IR_C), .iIR(IR),   

        .iRAM_CE_I(RAM_CE_I), .iRAM_RD_I(RAM_RD_I), .iRAM_WR_I(RAM_WR_I),
        .iRAM_ADDR_I(RAM_ADDR_I), .iRAM_DATA_WR_I(RAM_DATA_WR_I),
        .oRAM_DATA_RD_I(RAM_DATA_RD_I),

        .iRAM_CE_S(RAM_CE_S), .iRAM_RD_S(RAM_RD_S), .iRAM_WR_S(RAM_WR_S),
        .iRAM_ADDR_S(RAM_ADDR_S), .iRAM_DATA_WR_S(RAM_DATA_WR_S),
        .oRAM_DATA_RD_S(RAM_DATA_RD_S),

        .iRAM_CE_A(RAM_CE_A), .iRAM_RD_A(RAM_RD_A), .iRAM_WR_A(RAM_WR_A),
        .iRAM_ADDR_A(RAM_ADDR_A), .iRAM_DATA_WR_A(RAM_DATA_WR_A),
        .oRAM_DATA_RD_A(RAM_DATA_RD_A),

        .iRAM_CE_F(RAM_CE_F), .iRAM_RD_F(RAM_RD_F), .iRAM_WR_F(RAM_WR_F),
        .iRAM_ADDR_F(RAM_ADDR_F), .iRAM_DATA_WR_F(RAM_DATA_WR_F),
        .oRAM_DATA_RD_F(RAM_DATA_RD_F),

        .iRAM_CE_CI(RAM_CE_CI), .iRAM_RD_CI(RAM_RD_CI), .iRAM_WR_CI(RAM_WR_CI),
        .iRAM_ADDR_CI(RAM_ADDR_CI), .oRAM_DATA_RD_CI(RAM_DATA_RD_CI),

        .iRAM_CE_CSS(RAM_CE_CSS), .iRAM_RD_CSS(RAM_RD_CSS), .iRAM_WR_CSS(RAM_WR_CSS),
        .iRAM_ADDR_CSS(RAM_ADDR_CSS), .iRAM_DATA_WR_CSS(RAM_DATA_WR_CSS),

        .iRAM_CE_CL(RAM_CE_CL), .iRAM_RD_CL(RAM_RD_CL), .iRAM_WR_CL(RAM_WR_CL),
        .iRAM_ADDR_CL(RAM_ADDR_CL), .oRAM_DATA_RD_CL(RAM_DATA_RD_CL),

        .iRAM_CE_CS(RAM_CE_CS), .iRAM_RD_CS(RAM_RD_CS), .iRAM_WR_CS(RAM_WR_CS),
        .iRAM_ADDR_CS(RAM_ADDR_CS), .iRAM_DATA_WR_CS(RAM_DATA_WR_CS),

        .oRAM_CE(oRAM_CE), .oRAM_RD(oRAM_RD), .oRAM_WR(oRAM_WR),
        .oRAM_ADDR(oRAM_ADDR), .oRAM_DATA_WR(oRAM_DATA),
        
        .iRAM_DATA_RD(iRAM_DATA)
    );

	initial begin
		i           = 0;
        PC          = 8'b00000000;
        C_BUFFER    = 0;
	end

    always @(posedge iCLK or posedge iRST) begin
        if (iRST) begin
            PC          <= 8'b0;
            i           <= 0;
            C_BUFFER    <= 0;
        end else begin
            $display();
            $display("~ CLOCK: %0d ~", i);

            /* providing c instr */
            if (CURRENT_INSTRUCTION[1:0] != 2'b11)
                C_BUFFER = ~C_BUFFER;
            else
                C_BUFFER = 0;
            end
          
            if (CURRENT_INSTRUCTION[1:0] == 2'b11) begin
                OPCODE_R_M  = opcode_r_m_module.opcode_r_m(IR);

                case (OPCODE)
                    7'b0110011:                               
                        if (OPCODE_R_M == 1'b0)             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: R", PC, IR, OPCODE);
                        else if (OPCODE_R_M == 1'b1)        $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, EXTENSION TYPE: RV32M", PC, IR, OPCODE);                  
                    7'b0010011, 7'b0000011, 7'b1100111:     $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: I", PC, IR, OPCODE);
                    7'b0100011:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: S", PC, IR, OPCODE);
                    7'b0110111, 7'b0010111:                 $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: U", PC, IR, OPCODE);
                    7'b1100011:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: B", PC, IR, OPCODE);
                    7'b1101111:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, INSTRUCTION TYPE: J", PC, IR, OPCODE);
                    7'b0101111:                             $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, EXTENSION TYPE: RV32A", PC, IR, OPCODE);
                    7'b0000111, 7'b0100111, 7'b1000011, 7'b1000111, 
                    7'b1001011, 7'b1001111, 7'b1010011:     $display("#PC: 0x%x, IR: 0x%x, OPCODE: 0x%x, EXTENSION TYPE: RV32F", PC, IR, OPCODE);
                endcase

            end else begin
                C_MUX   = instruction_c_mux.c_mux(IR_C);

                case(C_MUX)
                    3'b000: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CR", PC, IR_C, OP);
                    3'b001: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CI", PC, IR_C, OP);
                    3'b010: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CSS", PC, IR_C, OP);
                    3'b011: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CIW", PC, IR_C, OP);
                    3'b100: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CL", PC, IR_C, OP);
                    3'b101: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CS", PC, IR_C, OP);
                    3'b110: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CB", PC, IR_C, OP);
                    3'b111: $display("#PC: 0x%x, IR: 0x%x, OP: 2'b%b, EXTENSION TYPE: RV32C, INSTRUCTION TYPE: CJ", PC, IR_C, OP);
                endcase
            end

            if (OPCODE == 7'b0000011) begin
                RAM_WR = 0; RAM_RD = 1;
            end 
            else if (OPCODE == 7'b0100011) begin
                RAM_WR = 1; RAM_RD = 0;
            end
            else if ((OPCODE == 7'b0101111) || (OPCODE == 7'b0000111) || (OPCODE == 7'b0100111)) begin
                RAM_WR = 1; RAM_RD = 1;
            end

            PC  <= (OPCODE == 7'b1100011)                ? (BR_B) : 
                   (OPCODE == 7'b1101111)                ? (BR_J) :
                   (OPCODE == 7'b1100111)                ? (BR_I) :
                   (CURRENT_INSTRUCTION[1:0] == 2'b11)   ? PC + 4 :
                   (CURRENT_INSTRUCTION[1:0] != 2'b11)   ? PC + 2 :
                   0;

            i   <= i + 1;


            /* DEBUG */
            $display("CPU -> PC: 0x%x, IR: 0x%x, IR_C: 0x%x, CURRENT_INSTRUCTION: 0x%x, C_BUFFER: 1b%b", PC, IR, IR_C, CURRENT_INSTRUCTION, C_BUFFER);


        end

    assign oREG32 = X_ALU_OUT;

endmodule