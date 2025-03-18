
module ram_mux (
	input			iCLK,
    input   [6:0]   OPCODE,    
	input   [15:0]  iIR_C,
    input   [31:0]  iIR,


	input 			iRAM_CE_I, iRAM_RD_I, iRAM_WR_I,
	input 	[7:0]	iRAM_ADDR_I, 
	input 	[31:0]  iRAM_DATA_WR_I,
	output	[31:0]	oRAM_DATA_RD_I,

	input 			iRAM_CE_S, iRAM_RD_S, iRAM_WR_S,
	input 	[7:0]	iRAM_ADDR_S, 
	input 	[31:0]  iRAM_DATA_WR_S,
	output	[31:0]	oRAM_DATA_RD_S,

	input 			iRAM_CE_A, iRAM_RD_A, iRAM_WR_A,
	input 	[7:0]	iRAM_ADDR_A, 
	input 	[31:0]  iRAM_DATA_WR_A,
	output	[31:0]	oRAM_DATA_RD_A,

	input 			iRAM_CE_F, iRAM_RD_F, iRAM_WR_F,
	input 	[7:0]	iRAM_ADDR_F, 
	input 	[31:0]  iRAM_DATA_WR_F,
	output	[31:0]	oRAM_DATA_RD_F,

	input 			iRAM_CE_CI, iRAM_RD_CI, iRAM_WR_CI,
	input 	[7:0]	iRAM_ADDR_CI,
	output	[31:0]	oRAM_DATA_RD_CI,

	input 			iRAM_CE_CSS, iRAM_RD_CSS, iRAM_WR_CSS,
	input 	[7:0]	iRAM_ADDR_CSS, 
	input 	[31:0]  iRAM_DATA_WR_CSS,

	input 			iRAM_CE_CL, iRAM_RD_CL, iRAM_WR_CL,
	input 	[7:0]	iRAM_ADDR_CL,
	output	[31:0]	oRAM_DATA_RD_CL,

	input 			iRAM_CE_CS, iRAM_RD_CS, iRAM_WR_CS,
	input 	[7:0]	iRAM_ADDR_CS, 
	input 	[31:0]  iRAM_DATA_WR_CS,

	output			oRAM_CE, oRAM_RD, oRAM_WR,
	output	[7:0]	oRAM_ADDR, 
	output	[31:0] 	oRAM_DATA_WR,
	input	[31:0]	iRAM_DATA_RD
);

	/* c fmt */
    wire [2:0]  C_MUX;
    assign C_MUX = instruction_c_mux.c_mux(iIR_C);


	assign oRAM_CE 			= (iIR[1:0] == 2'b11) ? 
							  	((OPCODE == 7'b0000011) ? iRAM_CE_I       							:
					             (OPCODE == 7'b0100011) ? iRAM_CE_S       							:
							     (OPCODE == 7'b0101111) ? iRAM_CE_A       							:
							     (OPCODE == 7'b0000111) || (OPCODE == 7'b0100111) ? iRAM_CE_F 		:
					   		     1'b0) 																: 
							  (iIR_C[1:0] != 2'b11) ?
							  	((C_MUX == 3'b001) ? iRAM_CE_CI										:
								 (C_MUX == 3'b010) ? iRAM_CE_CSS									:
								 (C_MUX == 3'b100) ? iRAM_CE_CL                                     :
                                 (C_MUX == 3'b101) ? iRAM_CE_CS                                     :
					   		     1'b0) 								  								:
							  1'b0;  

	assign oRAM_RD 			= (iIR[1:0] == 2'b11) ? 
							  	((OPCODE == 7'b0000011) ? iRAM_RD_I       							:
					             (OPCODE == 7'b0100011) ? iRAM_RD_S       							:
							     (OPCODE == 7'b0101111) ? iRAM_RD_A       							:
							     (OPCODE == 7'b0000111) || (OPCODE == 7'b0100111) ? iRAM_RD_F 		:
					   		     1'b0) 																: 
							  (iIR_C[1:0] != 2'b11) ?
							  	((C_MUX == 3'b001) ? iRAM_RD_CI										:
								 (C_MUX == 3'b010) ? iRAM_RD_CSS									:
								 (C_MUX == 3'b100) ? iRAM_RD_CL                                     :
                                 (C_MUX == 3'b101) ? iRAM_RD_CS                                     :
					   		     1'b0) 								  								:
							  1'b0;    
							        
	assign oRAM_WR 			= (iIR[1:0] == 2'b11) ? 
							  	((OPCODE == 7'b0000011) ? iRAM_WR_I       							:
					             (OPCODE == 7'b0100011) ? iRAM_WR_S       							:
							     (OPCODE == 7'b0101111) ? iRAM_WR_A       							:
							     (OPCODE == 7'b0000111) || (OPCODE == 7'b0100111) ? iRAM_WR_F 		:
					   		     1'b0) 																: 
							  (iIR_C[1:0] != 2'b11) ?
							  	((C_MUX == 3'b001) ? iRAM_WR_CI										:
								 (C_MUX == 3'b010) ? iRAM_WR_CSS									:
								 (C_MUX == 3'b100) ? iRAM_WR_CL                                     :
                                 (C_MUX == 3'b101) ? iRAM_WR_CS                                     :
					   		     1'b0) 								  								:
							  1'b0;  

	assign oRAM_ADDR 		= (iIR[1:0] == 2'b11) ? 
							  	((OPCODE == 7'b0000011) ? iRAM_ADDR_I       					   	:
					             (OPCODE == 7'b0100011) ? iRAM_ADDR_S       					   	:
							     (OPCODE == 7'b0101111) ? iRAM_ADDR_A       					   	:
							     (OPCODE == 7'b0000111) || (OPCODE == 7'b0100111) ? iRAM_ADDR_F    	:
					   		     8'h0) 																: 
							  (iIR_C[1:0] != 2'b11) ?
							  	((C_MUX == 3'b001) ? iRAM_ADDR_CI								    :
								 (C_MUX == 3'b010) ? iRAM_ADDR_CSS									:
								 (C_MUX == 3'b100) ? iRAM_ADDR_CL                                   :
                                 (C_MUX == 3'b101) ? iRAM_ADDR_CS                                   :
					   		     8'h0) 								  								:
							  8'h0;     

	assign oRAM_DATA_WR 	= (iIR[1:0] == 2'b11) ? 
							  	((OPCODE == 7'b0100011) ? iRAM_DATA_WR_S  							: 
							     (OPCODE == 7'b0101111) ? iRAM_DATA_WR_A  							: 
							     (OPCODE == 7'b0100111) ? iRAM_DATA_WR_F 							:
					   		     32'h0) 															: 
							  (iIR_C[1:0] != 2'b11) ?
							  	((C_MUX == 3'b010) ? iRAM_DATA_WR_CSS								:
                                 (C_MUX == 3'b101) ? iRAM_DATA_WR_CS                                :
					   		     32'h0) 								  							:
							  32'h0;
	
	assign oRAM_DATA_RD_I	= ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0000011)) ? iRAM_DATA_RD : 32'h0;
	assign oRAM_DATA_RD_S	= ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0100011)) ? iRAM_DATA_RD : 32'h0;
	assign oRAM_DATA_RD_A	= ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0101111)) ? iRAM_DATA_RD : 32'h0;
	assign oRAM_DATA_RD_F	= ((iIR[1:0] == 2'b11) && (OPCODE == 7'b0000111)) || (OPCODE == 7'b0100111) ? iRAM_DATA_RD : 32'h0;

	assign oRAM_DATA_RD_CI	= ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b001)) ? iRAM_DATA_RD : 32'h0;
	assign oRAM_DATA_RD_CL	= ((iIR_C[1:0] != 2'b11) && (C_MUX == 3'b100)) ? iRAM_DATA_RD : 32'h0;


	/* DEBUG */
	// always @(posedge iCLK) begin
	// 	$display("RAM MUX -> oRAM_CE: 0x%x, oRAM_RD: 0x%x, oRAM_WR: 0x%x", oRAM_CE, oRAM_RD, oRAM_WR);
	// 	$display("RAM MUX -> oRAM_ADDR: 0x%x, oRAM_DATA_WR: 0x%x, iRAM_DATA_RD: 0x%x", oRAM_ADDR, oRAM_DATA_WR, iRAM_DATA_RD);
	// end


endmodule


