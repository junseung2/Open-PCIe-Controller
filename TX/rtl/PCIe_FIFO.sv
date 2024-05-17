module vc_fifo
#(
    parameter DATA_WIDTH = 224,
    parameter DEPTH = 16
)
(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    input  wire                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                 empty,
    output logic                 full
);

    // Internal signals
    logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    logic [3:0]            wr_ptr, rd_ptr;

    // Write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Status logic
    always_comb begin
        empty = (wr_ptr == rd_ptr);
        full = ((wr_ptr + 1) == rd_ptr);
    end

endmodule
