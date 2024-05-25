interface pcie_tl_if (input wire clk);

    import PCIe_PKG::*;

    logic fc_valid_i; 

    // AXI Interface signals
    AXI_AR_CH ar_ch(.clk(clk));
    AXI_R_CH  r_ch(.clk(clk));

    logic                                           tlp_valid_i;
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]   tlp_i;
    logic                                           tlp_ready_o;
    
    PCIe_PKG::tlp_memory_header               tlp_hdr_arr_o; 

endinterface
