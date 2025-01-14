module memory_ram (
    output  [31:0]  oRAM_DATA,
    input   [31:0]  iRAM_DATA,

    input           iRAM_CE,
    input           iRAM_RD,
    input           iRAM_WR,

    input   [7:0]   iRAM_ADDR,
    input           iRAM_CLK, iRAM_RST
	);

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
	end

endmodule
