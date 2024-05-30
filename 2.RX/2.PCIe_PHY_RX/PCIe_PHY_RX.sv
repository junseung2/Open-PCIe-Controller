module PCIe_PHY_RX #(
    parameter DATA_WIDTH = 128,
    parameter LANE_COUNT = 4
) (
    input  logic clk,
    input  logic reset,
    input  logic [LANE_COUNT-1:0] serial_data_in,
    output logic [DATA_WIDTH*LANE_COUNT-1:0] tlp_out,
    output logic [DATA_WIDTH*LANE_COUNT-1:0] dllp_out,
    output logic tlp_valid,
    output logic dllp_valid
);

    // Intermediate signals
    logic [DATA_WIDTH-1:0] deserializer_data [LANE_COUNT-1:0];
    logic deserializer_valid [LANE_COUNT-1:0];
    logic [DATA_WIDTH-1:0] descrambled_data [LANE_COUNT-1:0];
    logic [DATA_WIDTH*LANE_COUNT-1:0] unstriped_data;

    // Instantiate Deserializers
    genvar i;
    generate
        for (i = 0; i < LANE_COUNT; i++) begin
            Deserializer #(.DATA_WIDTH(DATA_WIDTH), .SERIAL_WIDTH(1)) deserializer (
                .clk(clk),
                .reset(reset),
                .serial_data_in(serial_data_in[i]),
                .parallel_data_out(deserializer_data[i]),
                .data_valid(deserializer_valid[i])
            );
        end
    endgenerate

    // Instantiate Descramblers
    generate
        for (i = 0; i < LANE_COUNT; i++) begin
            Descrambler #(.DATA_WIDTH(DATA_WIDTH)) descrambler (
                .clk(clk),
                .reset(reset),
                .data_in(deserializer_data[i]),
                .data_out(descrambled_data[i])
            );
        end
    endgenerate

    // Instantiate Byte Un-striping
    Byte_Unstriping #(.DATA_WIDTH(DATA_WIDTH), .LANE_COUNT(LANE_COUNT)) byte_unstriping (
        .lane_data(descrambled_data),
        .data_out(unstriped_data)
    );

    // Instantiate Packet Filtering
    Packet_Filtering #(.DATA_WIDTH(DATA_WIDTH)) packet_filtering (
        .data_in(unstriped_data),
        .tlp_out(tlp_out),
        .dllp_out(dllp_out),
        .tlp_valid(tlp_valid),
        .dllp_valid(dllp_valid)
    );

endmodule
