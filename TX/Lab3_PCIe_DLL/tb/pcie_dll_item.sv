class pcie_dll_transaction extends uvm_sequence_item;

    `uvm_object_utils(pcie_dll_transaction)

    // Randomizable fields for the transaction
    rand bit                                            tlp_valid; 
    rand bit [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]    tlp; 
    rand bit                                            tlp_ready; 
    rand bit PCIe_PKG::dllp_packet                      dllp;
    rand bit                                            dllp_valid; 

    // Output fields (not randomized)
    bit                                                 tlp_ready_o;
    bit                                                 tlp_valid_o;
    bit [PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:0]        tlp_o; 

    // Constructor
    function new(string name = "pcie_dll_transaction");
        super.new(name);
    endfunction

endclass
