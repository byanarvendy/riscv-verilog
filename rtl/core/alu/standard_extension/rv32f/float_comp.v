module float_comp;

    function [4:0] max;
        input [4:0] iVALUE1, iVALUE2;
        begin
            if (iVALUE1 > iVALUE2)
                max = iVALUE1;
            else
                max = iVALUE2;
        end
    endfunction
    
    function [4:0] min;
        input [4:0] iVALUE1, iVALUE2;
        begin
            if (iVALUE1 < iVALUE2)
                min = iVALUE1;
            else
                min = iVALUE2;
        end
    endfunction

    function [31:0] f32_to_s32;
        input [31:0] f32;
        reg sign;
        reg [7:0] exponent;
        reg [23:0] fraction;
        reg [31:0] result;
        begin
            sign = f32[31];
            exponent = f32[30:23];
            fraction = {1'b1, f32[22:0]};
            
            if (exponent == 8'b00000000) begin
                result = 0;
            end else begin
                result = fraction >> (127 - exponent);
            end

            if (sign == 1) begin
                result = ~result + 1;
            end

            f32_to_s32 = result;
        end
    endfunction

    function [31:0] f32_to_u32;
        input [31:0] f32;
        reg sign;
        reg [7:0] exponent;
        reg [23:0] fraction;
        reg [31:0] result;
        begin
            sign = f32[31];
            exponent = f32[30:23];
            fraction = {1'b1, f32[22:0]};
            
            if (exponent == 8'b00000000) begin
                result = 0;
            end else begin
                result = fraction >> (127 - exponent);
            end
            f32_to_u32 = result;
        end
    endfunction

endmodule