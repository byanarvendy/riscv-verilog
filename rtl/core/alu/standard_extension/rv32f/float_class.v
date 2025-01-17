module float_class;

    function [9:0] classify;
        input [31:0] rs1;
        reg [7:0] exp;
        reg [22:0] frac;
        reg sign;
        begin
            sign = rs1[31];
            exp = rs1[30:23];
            frac = rs1[22:0];
            
            classify = 10'b0;

            if (exp == 8'b11111111) begin
                if (frac == 23'b0) begin            /* infinity */
                    if (sign == 1'b0)
                        classify[7] = 1'b1;             /* +infinity */
                    else
                        classify[0] = 1'b1;             /* -infinity */
                end else begin                      /* NaN */
                    if (frac[22] == 1'b1)
                        classify[8] = 1'b1;             /* signaling NaN */
                    else
                        classify[9] = 1'b1;             /* quiet NaN */
                end
            end else if (exp == 8'b00000000) begin  /* check for subnormal or zero */
                if (frac == 23'b0) begin                /* zero */
                    if (sign == 1'b0)
                        classify[4] = 1'b1;                 /* +0 */
                    else
                        classify[3] = 1'b1;                 /* −0 */
                end else begin                          /* subnormal */
                    if (sign == 1'b0)
                        classify[5] = 1'b1;                 /* positive subnormal */
                    else
                        classify[2] = 1'b1;                 /* negative subnormal */
                end
            end else begin                          /* normal number */
                if (sign == 1'b0)
                    classify[6] = 1'b1;                 /* positive normal number */
                else
                    classify[1] = 1'b1;                 /* egative normal number */
            end
        end
    endfunction

endmodule