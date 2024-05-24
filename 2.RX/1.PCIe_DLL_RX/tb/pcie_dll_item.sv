class pcie_dll_transaction extends uvm_sequence_item;

    rand bit                                            tlp_valid_i;
    rand bit [PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:0]   tlp_i;
    rand bit                                            tlp_ready_i;

    bit                                                 tlp_ready_o;
    bit                                                 tlp_valid_o;
    bit [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]         tlp_o;
    
    PCIe_PKG::dllp_packet                               dllp_o;
    PCIe_PKG::dllp_fc_packet                            dllp_fc_o;

    `uvm_object_utils(pcie_dll_transaction)

    function new(string name = "pcie_dll_transaction");
        super.new(name);
    endfunction

    constraint tlp_c{
        tlp_valid_i == 1'b1;
        tlp_ready_i == 1'b1;
    }
endclass
