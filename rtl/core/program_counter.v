module program_counter (
    input           iCLK,        
    input           iRST,        
    input   [7:0]   iBR_ADDR,   
    input           iBR_ENABLE, 
    output  [7:0]   oPC         
);

    reg [7:0] PC;

    always @(posedge iCLK or posedge iRST) begin
        if (iRST) begin
            PC <= 8'b0;
        end else if (iBR_ENABLE) begin
            PC <= iBR_ADDR;
        end else begin
            PC <= PC + 4;
        end
    end

    assign oPC = PC;

endmodule
