module PCIE_TL_TX
(
    input  wire                             clk,            // Clock signal
    input  wire                             rst_n,          // Active-low reset signal
    input  wire                             fc_valid_i,     // Flow control valid input

    // Software Interface (Responder)
    AXI_AW_CH.slave                         aw_ch,          // AXI write address channel (slave)
    AXI_W_CH.slave                          w_ch,           // AXI write data channel (slave)
    AXI_B_CH.slave                          b_ch,           // AXI write response channel (slave)

    // Input TLP Header Array
    input  PCIe_PKG::tlp_memory_header      tlp_hdr_arr_i,  // TLP header array input

    // Data Link Layer Interface
    output logic                                            tlp_valid_o,    // TLP valid output signal
    output logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]    tlp_o,          // TLP data output
    input  wire                                             tlp_ready_i     // TLP ready input signal
);

    // Internal signals (TLP Header & TLP Data)
    logic [PCIe_PKG::PCIe_DATA_PAYLOAD_SIZE:0]          tlp_data, tlp_data_n;         // TLP data and next TLP data
    PCIe_PKG::tlp_memory_header                         tlp_header, tlp_header_n;     // TLP header and next TLP header

    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]       tlp, tlp_n;                   // TLP packet and next TLP packet
    logic                                               tlp_valid, tlp_valid_n;       // TLP valid signal and next TLP valid signal

    // VC FIFO signals
    logic                                               vc0_fifo_full, vc0_fifo_empty;    // VC0 FIFO full and empty signals
    logic                                               vc1_fifo_full, vc1_fifo_empty;    // VC1 FIFO full and empty signals
    logic                                               vc0_fifo_wren, vc0_fifo_rden;     // VC0 FIFO write enable and read enable
    logic                                               vc1_fifo_wren, vc1_fifo_rden;     // VC1 FIFO write enable and read enable
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]       vc0_fifo_rdata;                   // VC0 FIFO read data
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]       vc1_fifo_rdata;                   // VC1 FIFO read data
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]       vc0_fifo_wdata;                   // VC0 FIFO write data
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]       vc1_fifo_wdata;                   // VC1 FIFO write data

    // Sequential logic for state and TLP data update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tlp_data        <= 128'd0;
            tlp_header      <= '0;
            tlp             <= '0;
            tlp_valid       <= 1'b0;
        end else begin
            tlp_data        <= tlp_data_n;
            tlp_header      <= tlp_header_n;
            tlp             <= tlp_n;
            tlp_valid       <= tlp_valid_n;
        end
    end

    // Combinational logic for TLP packing and FIFO write enable
    always_comb begin
        // Default values
        tlp_data_n          = tlp_data;
        tlp_header_n        = tlp_header;
        tlp_n               = tlp;
        tlp_valid_n         = 1'b0;
        vc0_fifo_wren       = 1'b0;
        vc1_fifo_wren       = 1'b0;

        aw_ch.ready         = 1'b1;
        w_ch.ready          = 1'b1;

        if (w_ch.valid && aw_ch.valid && fc_valid_i) begin
            // TLP Header creation based on inputs
            tlp_header_n    = tlp_hdr_arr_i;
            tlp_data_n      = w_ch.data;

            // Combine header and data into one TLP packet
            tlp_n           = {tlp_header, tlp_data};
            tlp_valid_n     = 1'b1;

            // Write to appropriate FIFO based on TC value
            if (tlp_header.tc[0] == 1'b0) begin
                if (!vc0_fifo_full) begin
                    vc0_fifo_wren   = 1'b1;
                    vc0_fifo_wdata  = tlp;
                end
            end else begin
                if (!vc1_fifo_full) begin
                    vc1_fifo_wren   = 1'b1;
                    vc1_fifo_wdata  = tlp;
                end
            end
        end
    end

    // Instantiate VC0 FIFO
    PCIe_FIFO vc0 (
        .clk(clk),
        .rst_n(rst_n),
        .full_o(vc0_fifo_full),
        .wren_i(vc0_fifo_wren),
        .wdata_i(vc0_fifo_wdata),
        .empty_o(vc0_fifo_empty),
        .rden_i(vc0_fifo_rden),
        .rdata_o(vc0_fifo_rdata)
    );

    // Instantiate VC1 FIFO
    PCIe_FIFO vc1 (
        .clk(clk),
        .rst_n(rst_n),
        .full_o(vc1_fifo_full),
        .wren_i(vc1_fifo_wren),
        .wdata_i(vc1_fifo_wdata),
        .empty_o(vc1_fifo_empty),
        .rden_i(vc1_fifo_rden),
        .rdata_o(vc1_fifo_rdata)
    );

    // Instantiate PCIe_arbiter
    PCIe_arbiter arbiter (
        .clk(clk),
        .rst_n(rst_n),
        .vc0_empty(vc0_fifo_empty),
        .vc0_rdata(vc0_fifo_rdata),
        .vc1_empty(vc1_fifo_empty),
        .vc1_rdata(vc1_fifo_rdata),
        .tlp_ready_i(tlp_ready_i),
        .fc_valid_i(fc_valid_i),
        .vc0_rden(vc0_fifo_rden),
        .vc1_rden(vc1_fifo_rden),
        .tlp_valid_o(tlp_valid_o),
        .tlp_o(tlp_o)
    );

endmodule
