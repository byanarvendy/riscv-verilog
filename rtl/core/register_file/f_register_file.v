module f_register_file (
    input           iCLK,
    input           iRST,

    input   [4:0]   iRD,
    input   [4:0]   iRS1,
    input   [4:0]   iRS2,
    input   [4:0]   iRS3,

    output  [31:0]  oALU_IN1,
    output  [31:0]  oALU_IN2,
    output  [31:0]  oALU_IN3,
    input   [31:0]  iALU_OUT
);

    integer i;
    real regfile [0:31];
    // reg [31:0] regfile [0:31];

    localparam SF = 2.0 ** -4.0;

    assign oALU_IN1 = regfile[iRS1];
    assign oALU_IN2 = regfile[iRS2];
    assign oALU_IN3 = regfile[iRS3];

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile[i] = i * SF;
            // regfile[i] = i;
        end
    end

    always @(posedge iCLK) begin
        if (iRST) begin
            for (i = 0; i < 32; i = i + 1) begin
                regfile[i] = 32'b0;
            end
        end else begin
            regfile[iRD] = iALU_OUT;
        end

        $display("===== FLOATING POINT REGISTERS =====");
        for (i = 0; i < 32; i = i + 8) begin
            $display("#FRF: [%16.4f %16.4f %16.4f %16.4f %16.4f %16.4f %16.4f %16.4f]", regfile[i+0], regfile[i+1], regfile[i+2], regfile[i+3], regfile[i+4], regfile[i+5], regfile[i+6], regfile[i+7]);
            // $display("#FRF: [%16d %16d %16d %16d %16d %16d %16d %16d]", regfile[i+0], regfile[i+1], regfile[i+2], regfile[i+3], regfile[i+4], regfile[i+5], regfile[i+6], regfile[i+7]);
        end


        /* DEBUG */
        // $display("iRD: 0x%x, iRS1: 0x%x, iRS2: 0x%x, iRS3: 0x%x", iRD, iRS1, iRS2, iRS3);
        // $display("oALU_IN1: 0x%x, oALU_IN2: 0x%x, oALU_IN3: 0x%x, iALU_OUT: 0x%x", oALU_IN1, oALU_IN2, oALU_IN3, iALU_OUT);

    end

endmodule