interface pcie_tl_tx_if (
    input wire clk,
);

    // AXI Interface signals
    AXI_AW_CH.slave aw_ch;
    AXI_W_CH.slave  w_ch;
    AXI_B_CH.slave  b_ch;

    // TLP Header Array input
    logic [PCIe_PKG::tlp_memory_header] tlp_hdr_arr_i;

    // Data Link Layer Interface
    logic tlp_valid_o;
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0] tlp_o;
    logic tlp_ready_i;



endinterface
