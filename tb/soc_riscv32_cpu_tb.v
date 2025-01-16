`include "rtl/soc/soc_riscv32_cpu.v"

module soc_riscv32_cpu_tb;
    reg iCLK, iRST;

    reg [1:0] MODE;
    reg [7:0] SW;

    wire [31:0] REG32;

    integer i;

    initial begin
        iCLK = 0;
        iRST = 0;
        MODE = 2'h0;
        SW = 8'h0;

        for (i = 0; i < 40; i = i + 1) begin
            #5 iCLK = 0;
            #5 iCLK = 1;
        end
    end

    soc_riscv32_cpu u1(
        .iCLK(iCLK), .iRST(iRST),
        .iMODE(MODE), .iSW(SW),
        .oREG32(REG32)
    );

endmodule