module float_conv;

    function [31:0] s32_to_f32;
        reg sign;
        reg [31:0] result;
        input [31:0] s32;
        begin
            sign = s32[31];

            if (s32 == 0) begin
                result = 32'b0;
            end else begin
                result = $realtobits(s32);
            end

            s32_to_f32 = result;
        end
    endfunction

    function [31:0] u32_to_f32;
        input [31:0] u32;
        reg [31:0] result;
        begin
            if (u32 == 0) begin
                result = 32'b0;
            end else begin
                result = $realtobits(u32);
            end

            u32_to_f32 = result;
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