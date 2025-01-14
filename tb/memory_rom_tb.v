`include "rtl/soc/rom/memory_rom.v"

module memory_rom_tb;
    reg iCLK;

    reg [7:0] iROM_ADDR;

    wire [31:0] oROM_DATA;
    reg iROM_CE, iROM_RD;

    integer i;

    task single_clock();
        begin
            #5 iCLK = ~ iCLK;
            #5 iCLK = ~ iCLK;
        end
    endtask


    initial begin
        $dumpfile("sim/memory_rom_tb.vcd");
    	$dumpvars(0, memory_rom_tb);

        iROM_CE = 1;
        iROM_RD = 1;

        for (i = 0; i < 10; i = i + 1) begin
            iROM_ADDR = i;
            single_clock();
            $display("iROM_ADDR = 0x%h, DATA = 0x%h", iROM_ADDR, oROM_DATA);
        end
    end

    memory_rom u1(
        .oROM_DATA(oROM_DATA),
        .iROM_CE(iROM_CE),
        .iROM_RD(iROM_RD),
        .iROM_ADDR(iROM_ADDR)
    );

endmodule