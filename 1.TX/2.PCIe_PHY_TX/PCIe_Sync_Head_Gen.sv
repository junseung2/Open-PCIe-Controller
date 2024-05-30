module PCIe_Sync_Head_Gen #(
    parameter DATA_WIDTH = 128
) (
    input  logic              clk,
    input  logic              reset,
    input  logic [1:0]        sync_header,
    output logic [DATA_WIDTH + 2 - 1:0] data_out
);
    logic [DATA_WIDTH - 1:0] data_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            data_reg <= '0;
        end else begin
            data_reg <= {data_reg[DATA_WIDTH - 3:0], sync_header};  // Append the sync header
        end
    end

    assign data_out = {sync_header, data_reg};  // Add the sync header to the output data

endmodule