interface pcie_dll_if(input wire clk);

    logic                                           tlp_valid_i;
    logic [PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:0]  tlp_i;
    logic                                           tlp_ready_o;
    logic                                           tlp_valid_o;
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]   tlp_o;
    logic                                           tlp_ready_i;
    PCIe_PKG::dllp_packet                           dllp_o;
    PCIe_PKG::dllp_fc_packet                        dllp_fc_o;

endinterface
