module memory_ram (
    output  [31:0]  oRAM_DATA,
    input   [31:0]  iRAM_DATA,

    input           iRAM_CE,
    input           iRAM_RD,
    input           iRAM_WR,

    input   [7:0]   iRAM_ADDR,
    input           iRAM_CLK, iRAM_RST
);

	integer i;
	reg [31:0] mem [0:255];

	assign oRAM_DATA = (iRAM_CE && iRAM_RD) ? mem[iRAM_ADDR] : 32'h00000000;

	initial begin
		$readmemh("rtl/soc/ram/memory_ram_init.hex", mem, 0, 255);
	end

	always @(posedge iRAM_CLK  or negedge iRAM_RST) begin
		if (iRAM_WR) begin
			mem[iRAM_ADDR] = iRAM_DATA;
			// $writememh("rtl/soc/ram/memory_ram_init.hex", mem);
		end

		$display("===== MEMORY RAM =====");
        for (i = 0; i < 32; i = i + 8) begin
            $display("#RAM: [%16d %16d %16d %16d %16d %16d %16d %16d]", mem[i+0], mem[i+1], mem[i+2], mem[i+3], mem[i+4], mem[i+5], mem[i+6], mem[i+7]);
        end
		
	end

endmodule
