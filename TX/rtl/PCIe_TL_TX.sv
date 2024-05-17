`include "PCIe_PKG.svh"
`include "vc_fifo.sv"
`include "arbiter.sv"

module PCIE_TL_TX
(
    input  wire                    clk,
    input  wire                    rst_n,

    // AXI Write Address Channel
    AXI_AW_CH aw_ch,
    // AXI Write Data Channel
    AXI_W_CH  w_ch,
    // AXI Read Address Channel
    AXI_AR_CH ar_ch,

    // TLP Header Array (Input)
    input  wire [PCIe_PKG::tlp_memory_header] tlp_hdr_arr_i,

    // PCIe TLP Interface - TX
    output logic                   tlp_valid_o,
    output logic [223:0]           tlp_o,
    input  wire                    tlp_ready_i
);

    // Internal signals
    logic [127:0]                  tlp_data;
    PCIe_PKG::tlp_memory_header    tlp_header;

    // VC FIFO signals
    logic [223:0]                  vc0_data, vc1_data;
    logic                          vc0_wr_en, vc1_wr_en;
    logic                          vc0_rd_en, vc1_rd_en;
    logic                          vc0_empty, vc0_full;
    logic                          vc1_empty, vc1_full;

    // TLP Header Configuration
    always_comb begin
        tlp_header = tlp_hdr_arr_i;
        // Additional fields configuration for read requests
        if (ar_ch.arvalid) begin
            tlp_header.length       = ar_ch.arlen + 1;
            tlp_header.address      = ar_ch.araddr[31:2];
            tlp_header.requester_id = ar_ch.arid;
        end
        // Additional fields configuration for write requests
        if (aw_ch.awvalid) begin
            tlp_header.length       = aw_ch.awlen + 1;
            tlp_header.address      = aw_ch.awaddr[31:2];
            tlp_header.requester_id = aw_ch.awid;
        end
    end

    // AXI Read Transaction Handling (TX)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ar_ch.arready <= 1'b0;
        end else begin
            // Handle AXI read address channel
            if (ar_ch.arvalid && !ar_ch.arready) begin
                ar_ch.arready <= 1'b1;

                // Use provided TLP header values
                tlp_data <= 128'b0;
                // Route TLP to the appropriate VC based on tc value
                if (tlp_header.tc % 2 == 0) begin
                    // Write to VC0
                    vc0_wr_en <= 1'b1;
                    vc1_wr_en <= 1'b0;
                end else begin
                    // Write to VC1
                    vc0_wr_en <= 1'b0;
                    vc1_wr_en <= 1'b1;
                end
            end else begin
                ar_ch.arready <= 1'b0;
                vc0_wr_en <= 1'b0;
                vc1_wr_en <= 1'b0;
            end
        end
    end

    // AXI Write Transaction Handling (TX)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            aw_ch.awready <= 1'b0;
            w_ch.wready   <= 1'b0;
        end else begin
            // Handle AXI write address channel
            if (aw_ch.awvalid && !aw_ch.awready) begin
                aw_ch.awready <= 1'b1;
            end else begin
                aw_ch.awready <= 1'b0;
            end

            // Handle AXI write data channel
            if (w_ch.wvalid && !w_ch.wready) begin
                w_ch.wready <= 1'b1;
                // Append data to TLP
                tlp_data <= w_ch.wdata;
                // Route TLP to the appropriate VC based on tc value
                if (tlp_header.tc % 2 == 0) begin
                    // Write to VC0
                    vc0_wr_en <= 1'b1;
                    vc1_wr_en <= 1'b0;
                end else begin
                    // Write to VC1
                    vc0_wr_en <= 1'b0;
                    vc1_wr_en <= 1'b1;
                end
            end else begin
                w_ch.wready <= 1'b0;
                vc0_wr_en <= 1'b0;
                vc1_wr_en <= 1'b0;
            end
        end
    end

    // Instantiate VC0 and VC1
    vc_fifo #(.DATA_WIDTH(224), .DEPTH(16)) vc0 (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(vc0_wr_en),
        .wr_data({tlp_header, tlp_data}),
        .rd_en(vc0_rd_en),
        .rd_data(vc0_data),
        .empty(vc0_empty),
        .full(vc0_full)
    );

    vc_fifo #(.DATA_WIDTH(224), .DEPTH(16)) vc1 (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(vc1_wr_en),
        .wr_data({tlp_header, tlp_data}),
        .rd_en(vc1_rd_en),
        .rd_data(vc1_data),
        .empty(vc1_empty),
        .full(vc1_full)
    );

    // Instantiate Arbiter
    arbiter arb (
        .clk(clk),
        .rst_n(rst_n),
        .vc0_empty(vc0_empty),
        .vc0_data(vc0_data),
        .vc1_empty(vc1_empty),
        .vc1_data(vc1_data),
        .tlp_o(tlp_o),
        .tlp_valid_o(tlp_valid_o),
        .rd_en_vc0(vc0_rd_en),
        .rd_en_vc1(vc1_rd_en)
    );

endmodule
