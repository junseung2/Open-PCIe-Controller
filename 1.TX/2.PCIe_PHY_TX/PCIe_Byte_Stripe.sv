module PCIe_Byte_Stripe #(
    parameter DATA_WIDTH = 128,
    parameter LANE_WIDTH = 32
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [DATA_WIDTH - 1:0] data_in,
    output logic [LANE_WIDTH - 1:0] lane0,
    output logic [LANE_WIDTH - 1:0] lane1,
    output logic [LANE_WIDTH - 1:0] lane2,
    output logic [LANE_WIDTH - 1:0] lane3
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lane0 <= '0;
            lane1 <= '0;
            lane2 <= '0;
            lane3 <= '0;
        end else begin
            lane0 <= data_in[LANE_WIDTH - 1:0];
            lane1 <= data_in[2*LANE_WIDTH - 1:LANE_WIDTH];
            lane2 <= data_in[3*LANE_WIDTH - 1:2*LANE_WIDTH];
            lane3 <= data_in[DATA_WIDTH - 1:3*LANE_WIDTH];
        end
    end
endmodule
