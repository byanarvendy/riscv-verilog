
module ram_mux (
    input   [6:0]   OPCODE,

	input 			iRAM_CE_I, iRAM_RD_I, iRAM_WR_I,
	input 	[7:0]	iRAM_ADDR_I, 
	input 	[31:0]  iRAM_DATA_WR_I,
	output	[31:0]	oRAM_DATA_RD_I,

	input 			iRAM_CE_S, iRAM_RD_S, iRAM_WR_S,
	input 	[7:0]	iRAM_ADDR_S, 
	input 	[31:0]  iRAM_DATA_WR_S,
	output	[31:0]	oRAM_DATA_RD_S,

	output			oRAM_CE, oRAM_RD, oRAM_WR,
	output	[7:0]	oRAM_ADDR, 
	output	[31:0] 	oRAM_DATA_WR,
	input	[31:0]	iRAM_DATA_RD
);

	assign oRAM_CE 			= (OPCODE == 7'b0000011) ? iRAM_CE_I       :
					          (OPCODE == 7'b0100011) ? iRAM_CE_S       :
					   		  1'b0;     
     
	assign oRAM_RD 			= (OPCODE == 7'b0000011) ? iRAM_RD_I       :
					          (OPCODE == 7'b0100011) ? iRAM_RD_S       :
					   		  1'b0;     
							        
	assign oRAM_WR 			= (OPCODE == 7'b0000011) ? iRAM_WR_I       :
					          (OPCODE == 7'b0100011) ? iRAM_WR_S       :
					   		  1'b0;   
   
	assign oRAM_ADDR 		= (OPCODE == 7'b0000011) ? iRAM_ADDR_I     :
					          (OPCODE == 7'b0100011) ? iRAM_ADDR_S     :
							  8'h0;
	
	assign oRAM_DATA_WR 	= (OPCODE == 7'b0100011) ? iRAM_DATA_WR_S  : 32'h0;
	
	assign oRAM_DATA_RD_I	= (OPCODE == 7'b0000011) ? iRAM_DATA_RD    : 32'h0;
	assign oRAM_DATA_RD_S	= (OPCODE == 7'b0100011) ? iRAM_DATA_RD    : 32'h0;

endmodule

