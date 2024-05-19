module PCIE_TL_TX
(
    input  wire                             clk,
    input  wire                             rst_n,

    // Software Interface (Responder)
    AXI_AW_CH.slave                         aw_ch,                         
    AXI_W_CH.slave                          w_ch,
    AXI_B_CH.slave                          b_ch,

    // Input TLP Header Array
    input  PCIe_PKG::tlp_memory_header      tlp_hdr_arr_i,

    // Data Link Layer Interface
    output logic                            tlp_valid_o,
    output logic [223:0]                    tlp_o,
    input  wire                             tlp_ready_i
);

    // Internal signals (TLP Header & TLP Data)
    logic [127:0]                           tlp_data, tlp_data_n;
    PCIe_PKG::tlp_memory_header             tlp_header, tlp_header_n;

    logic [223:0]                           tlp, tlp_n;
    logic                                   tlp_valid, tlp_valid_n;

    // VC FIFO signals
    wire                        vc0_fifo_full, vc0_fifo_empty;
    wire                        vc1_fifo_full, vc1_fifo_empty;
    reg                         vc0_fifo_wren, vc0_fifo_rden;
    reg                         vc1_fifo_wren, vc1_fifo_rden;
    wire    [223:0]             vc0_fifo_rdata;
    wire    [223:0]             vc1_fifo_rdata;
    reg     [223:0]             vc0_fifo_wdata;
    reg     [223:0]             vc1_fifo_wdata;


    // TLP Packing Logic  
    typedef enum logic [1:0] {
        S_IDLE,
        S_PACKETIZE,
        S_WRITE_FIFO
    } state_t;

    state_t state, state_n;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            tlp_data    <= 128'd0;
            tlp_header  <= '0;
            tlp         <= '0;
            tlp_valid   <= 1'b0;
        end else begin
            state       <= state_n;
            tlp_data    <= tlp_data_n;
            tlp_header  <= tlp_header_n;
            tlp         <= tlp_n;
            tlp_valid   <= tlp_valid_n;
        end
    end

    always_comb begin
        // Default values
        state_n         = state;
        tlp_data_n      = tlp_data;
        tlp_header_n    = tlp_header;
        tlp_n           = tlp;
        tlp_valid_n     = tlp_valid;
        vc0_fifo_wren   = 1'b0;
        vc1_fifo_wren   = 1'b0;

        aw_ch.ready     = 1'b0;
        w_ch.ready      = 1'b0;

        case (state)
            S_IDLE: begin
                aw_ch.ready = 1'b1;
                w_ch.ready  = 1'b1;
                if (w_ch.valid && aw_ch.valid) begin
                    state_n = S_PACKETIZE;
                end
            end
            S_PACKETIZE: begin
                // TLP Header creation based on inputs
                tlp_header_n = tlp_hdr_arr_i;
                tlp_data_n = w_ch.data;

                // Combine header and data into one TLP packet
                tlp_n = {tlp_header_n, tlp_data_n};
                tlp_valid_n = 1'b1;

                state_n = S_WRITE_FIFO;
            end
            S_WRITE_FIFO: begin     
                if (tlp_header.tc[0] == 1'b0) begin
                    // Even TC, write to VC0 FIFO
                    if (!vc0_fifo_full) begin
                        vc0_fifo_wren = 1'b1;
                        vc0_fifo_wdata = tlp;
                    end
                end else begin
                    // Odd TC, write to VC1 FIFO
                    if (!vc1_fifo_full) begin
                        vc1_fifo_wren = 1'b1;
                        vc1_fifo_wdata = tlp;
                    end
                end
                // Clear valid signal
                tlp_valid_n = 1'b0;
                state_n = S_IDLE;
            end
        endcase
    end                            

    // Instantiate FIFOs
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
        .vc0_rden(vc0_fifo_rden),
        .vc1_rden(vc1_fifo_rden),
        .tlp_valid_o(tlp_valid_o),
        .tlp_o(tlp_o)
    );

endmodule
