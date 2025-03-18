module instruction_c_mux;

    /* c fmt
        | 000 | instruction type CR  |
        | 001 | instruction type CI  |
        | 010 | instruction type CSS |
        | 011 | instruction type CIW |
        | 100 | instruction type CL  |
        | 101 | instruction type CS  |
        | 110 | instruction type CB  |
        | 111 | instruction type CJ  |
    */

    function [2:0] c_mux;
        input [15:0] iIR;

        begin
            case (iIR[1:0])
                2'b00: begin
                    case (iIR[15:13])
                        3'b010: c_mux = 3'b100;
                        3'b110: c_mux = 3'b101;
                        3'b000: c_mux = 3'b011;
                    endcase
                end

                2'b01: begin
                    case (iIR[15:13])
                        3'b101, 3'b001: c_mux = 3'b111;
                        3'b110, 3'b111: c_mux = 3'b110;
                        3'b010, 3'b011, 3'b000: c_mux = 3'b001;
                    endcase

                    casez (iIR[15:10])
                        6'b100?00, 6'b100?01, 6'b100?10: c_mux = 3'b110;
                    endcase

                    casez ({iIR[15:10], iIR[6:5]})
                        8'b10001111, 8'b10001110, 8'b10001101, 8'b10001100: c_mux = 3'b101;
                    endcase
                end

                2'b10: begin
                    case (iIR[15:13])
                        3'b010, 3'b000: c_mux = 3'b001;
                        3'b110: c_mux = 3'b010;
                    endcase

                    case (iIR[15:12])
                        4'b1000, 4'b1001: c_mux = 3'b000;
                    endcase
                end
            endcase
        end
    endfunction

endmodule
