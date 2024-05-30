module Deserializer #(
    parameter DATA_WIDTH = 128,
    parameter SERIAL_WIDTH = 1
) (
    input  logic             clk,
    input  logic             reset,
    input  logic [SERIAL_WIDTH-1:0] serial_data_in,
    output logic [DATA_WIDTH-1:0] parallel_data_out,
    output logic             data_valid
);

    logic [DATA_WIDTH-1:0] shift_reg;
    logic [6:0]            bit_count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 0;
            bit_count <= 0;
            data_valid <= 0;
        end else begin
            shift_reg <= {shift_reg[DATA_WIDTH-SERIAL_WIDTH-1:0], serial_data_in};
            bit_count <= bit_count + 1;
            if (bit_count == DATA_WIDTH/SERIAL_WIDTH - 1) begin
                parallel_data_out <= shift_reg;
                data_valid <= 1;
                bit_count <= 0;
            end else begin
                data_valid <= 0;
            end
        end
    end
endmodule
