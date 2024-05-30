module PCIe_Scrambler #(
    parameter DATA_WIDTH = 128
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [DATA_WIDTH - 1:0] data_in,
    output logic [DATA_WIDTH - 1:0] data_out
);
    logic [23:0] lfsr;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 24'hFFFFFF;
        end else begin
            lfsr <= {lfsr[22:0], lfsr[23] ^ lfsr[21] ^ lfsr[16] ^ lfsr[8] ^ lfsr[5] ^ lfsr[2] ^ 1'b1};
        end
    end

    always_comb begin
        data_out = data_in ^ {lfsr, lfsr[23:16]};  // 확장된 LFSR 값을 사용하여 데이터 스크램블링
    end
endmodule
