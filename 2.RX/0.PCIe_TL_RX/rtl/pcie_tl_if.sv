interface pcie_tl_if (
    input wire clk
);

    import PCIe_PKG::*;

    logic fc_valid_i; 

    // AXI Interface signals
    AXI_AW_CH aw_ch(.clk(clk));
    AXI_W_CH  w_ch(.clk(clk));
    AXI_B_CH  b_ch(.clk(clk));

    // TLP Header Array input
    PCIe_PKG::tlp_memory_header           tlp_hdr_arr_i;

    // Data Link Layer Interface
    logic tlp_valid_o;
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0] tlp_o;
    logic tlp_ready_i;

endinterface
