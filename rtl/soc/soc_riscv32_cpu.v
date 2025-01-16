`include "rtl/core/riscv32_cpu.v"
`include "rtl/soc/rom/memory_rom.v"
`include "rtl/soc/ram/memory_ram.v"

module soc_riscv32_cpu (
    input           iCLK,
    input           iRST,

    input   [1:0]   iMODE,
    input   [7:0]   iSW,

    output  [31:0]  oREG32
);

    wire            ROM_CE, ROM_RD, RAM_CE, RAM_RD, RAM_WR;
    reg     [7:0]   ROM_ADDRESS_COUNTER;
    wire    [7:0]   RAM_ADDRESS, ROM_ADDRESS;
    wire    [31:0]  ROM_DATA, RAM_READ_DATA, RAM_WRITE_DATA;

    assign ROM_CE = 1;
    assign ROM_RD = 1;

    initial begin
        ROM_ADDRESS_COUNTER = 8'b0;
    end

    memory_rom u1 (
        .iROM_ADDR(ROM_ADDRESS), .oROM_DATA(ROM_DATA),
        .iROM_RD(ROM_RD), .iROM_CE(ROM_CE)
    );

    memory_ram u2 (
        .iRAM_CLK(iCLK), .iRAM_RST(iRST),

        .iRAM_CE(RAM_CE), .iRAM_RD(RAM_RD), .iRAM_WR(RAM_WR),
        .iRAM_ADDR(RAM_ADDRESS),

        .oRAM_DATA(RAM_READ_DATA), .iRAM_DATA(RAM_WRITE_DATA)
    );

    riscv32_cpu u3(
        .iCLK(iCLK), .iRST(iRST),

        .oROM_CE(ROM_CE), .oROM_RD(ROM_RD),
        .oROM_ADDR(ROM_ADDRESS), .iROM_DATA(ROM_DATA),

        .oRAM_CE(RAM_CE), .oRAM_RD(RAM_RD), .oRAM_WR(RAM_WR),

        .iRAM_DATA(RAM_READ_DATA),
        .oRAM_ADDR(RAM_ADDRESS), .oRAM_DATA(RAM_WRITE_DATA),      

        .iMODE(iMODE), .iSW(iSW),
        .oREG32(oREG32)
    );

    always @(posedge iCLK) begin
        if (iRST) begin
            // ROM_ADDRESS_COUNTER <= 8'b0;
        end else begin
            // ROM_ADDRESS_COUNTER <= ROM_ADDRESS_COUNTER + 1;
            // $display("ROM_ADDRESS_COUNTER: 0x%x", ROM_ADDRESS_COUNTER);
        end

        // $display("ROMS_CE: 0x%x, ROM_RD: 0x%x", ROM_CE, ROM_RD);
    end

    // assign ROM_ADDRESS = ROM_ADDRESS_COUNTER;

endmodule
