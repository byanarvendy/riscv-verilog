`include "rtl/soc/ram/memory_ram.v"

module memory_ram_tb;
    reg iCLK;

    reg [7:0] iRAM_ADDR;

    wire [31:0] oRAM_DATA;
    reg [31:0] iRAM_DATA;
    reg iRAM_CE, iRAM_RD, iRAM_WR;

    integer i;

    task single_clock();
        begin
            #20 iCLK = ~ iCLK;
            #20 iCLK = ~ iCLK;
        end
    endtask


    initial begin
        $dumpfile("sim/memory_ram_tb.vcd");
    	$dumpvars(0, memory_ram_tb);

        iRAM_CE = 1;
        iRAM_RD = 1;
        iRAM_WR = 0;

        for (i = 0; i < 15; i = i + 1) begin
            iRAM_ADDR = i;
            single_clock();
            $display("RAM_ADDRESS = 0x%h, DATA = 0x%h, READ = %b, WRITE = %b", iRAM_ADDR, oRAM_DATA, iRAM_RD, iRAM_WR);

            iRAM_WR = ~ iRAM_WR;   
            iRAM_RD = ~ iRAM_RD;

            iRAM_DATA = oRAM_DATA + 32'h00001111;      
        end
    end

    memory_ram u1(
        .oRAM_DATA(oRAM_DATA),
        .iRAM_DATA(iRAM_DATA),
        .iRAM_CE(iRAM_CE),
        .iRAM_RD(iRAM_RD),
        .iRAM_WR(iRAM_WR),
        .iRAM_ADDR(iRAM_ADDR),
        .iRAM_CLK(iRAM_WR)
    );

endmodule