module PCIe_Serializer #(
    parameter DATA_WIDTH = 128
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [DATA_WIDTH - 1:0] data_in,
    output logic              data_out
);
    logic [DATA_WIDTH - 1:0] shift_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= '0;
        end else begin
            shift_reg <= {shift_reg[DATA_WIDTH - 2:0], data_in[DATA_WIDTH - 1]};
        end
    end

    assign data_out = shift_reg[DATA_WIDTH - 1];
endmodule
