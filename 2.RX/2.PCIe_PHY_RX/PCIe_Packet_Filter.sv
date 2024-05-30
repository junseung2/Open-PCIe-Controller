module Packet_Filtering #(
    parameter DATA_WIDTH = 128
) (
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] tlp_out,
    output logic [DATA_WIDTH-1:0] dllp_out,
    output logic tlp_valid,
    output logic dllp_valid
);

    // Define some constants for Ordered Set and Idle detection
    localparam [7:0] ORDERED_SET = 8'hBC;
    localparam [7:0] IDLE = 8'h7C;

    always_comb begin
        if (data_in[7:0] == ORDERED_SET || data_in[7:0] == IDLE) begin
            tlp_out = '0;
            dllp_out = '0;
            tlp_valid = 0;
            dllp_valid = 0;
        end else begin
            // Check if it's a TLP or DLLP based on some custom logic
            if (/* TLP detection logic */) begin
                tlp_out = data_in;
                dllp_out = '0;
                tlp_valid = 1;
                dllp_valid = 0;
            end else if (/* DLLP detection logic */) begin
                tlp_out = '0;
                dllp_out = data_in;
                tlp_valid = 0;
                dllp_valid = 1;
            end else begin
                tlp_out = '0;
                dllp_out = '0;
                tlp_valid = 0;
                dllp_valid = 0;
            end
        end
    end
endmodule
