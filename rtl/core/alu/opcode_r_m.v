module opcode_r_m_module;

    function opcode_r_m;
        input [31:0] iIR;

        begin
            /* r base */
            if ((iIR[14:12] == 3'h0 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h0 && iIR[31:25] == 7'h20) ||
                (iIR[14:12] == 3'h4 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h6 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h7 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h1 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h5 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h5 && iIR[31:25] == 7'h20) ||
                (iIR[14:12] == 3'h2 && iIR[31:25] == 7'h00) ||
                (iIR[14:12] == 3'h3 && iIR[31:25] == 7'h00)) 
            begin
                opcode_r_m = 1'b0;
            end

            /* m multiply */
            else if ((iIR[14:12] == 3'h0 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h1 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h2 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h3 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h4 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h5 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h6 && iIR[31:25] == 7'h01) ||
                     (iIR[14:12] == 3'h7 && iIR[31:25] == 7'h01)) 
            begin
                opcode_r_m = 1'b1;
            end
        end
    endfunction

endmodule