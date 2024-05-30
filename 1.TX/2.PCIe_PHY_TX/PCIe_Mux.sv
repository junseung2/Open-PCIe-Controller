module PCIe_Mux #(
    parameter DATA_WIDTH = 128
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [DATA_WIDTH - 1:0] tlp,
    input  logic [DATA_WIDTH - 1:0] dllp,
    input  logic [DATA_WIDTH - 1:0] ordered_set,
    input  logic [DATA_WIDTH - 1:0] idle,
    input  logic [1:0]        sel,  // Select signal: 00 -> TLP, 01 -> DLLP, 10 -> Ordered Set, 11 -> Idle
    output logic [DATA_WIDTH - 1:0] data_out
);

    always_comb begin
        case (sel)
            2'b00: data_out = tlp;
            2'b01: data_out = dllp;
            2'b10: data_out = ordered_set;
            2'b11: data_out = idle;
            default: data_out = idle; // 기본값으로 Idle 설정
        endcase
    end
endmodule
