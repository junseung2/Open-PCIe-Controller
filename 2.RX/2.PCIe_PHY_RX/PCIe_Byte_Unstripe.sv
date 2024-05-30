module Byte_Unstriping #(
    parameter DATA_WIDTH = 128,
    parameter LANE_COUNT = 4
) (
    input  logic [DATA_WIDTH-1:0] lane_data [LANE_COUNT-1:0],
    output logic [DATA_WIDTH*LANE_COUNT-1:0] data_out
);
    always_comb begin
        for (int i = 0; i < LANE_COUNT; i++) begin
            data_out[i*DATA_WIDTH +: DATA_WIDTH] = lane_data[i];
        end
    end
endmodule
