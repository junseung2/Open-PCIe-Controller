class pcie_tl_transaction extends uvm_sequence_item;

    `uvm_object_utils(pcie_tl_transaction)

    // Randomizable fields for the transaction
    rand logic fc_valid; 
    
    rand logic tlp_valid;
    rand logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0] tlp;
    // AXI Write Data Channel
    rand logic rready;

    
    logic rvalid;
    logic [127:0] rdata;
    logic tlp_ready;
    PCIe_PKG::tlp_memory_header tlp_hdr_arr;



    // Constructor
    function new(string name = "pcie_tl_transaction");
        super.new(name);
    endfunction: new


    constraint rready_c {
        rready == 1;
    }

    constraint fc_valid_c {
        fc_valid == 1;
    }

    constraint tlp_valid_c {
        tlp_valid == 1;
    }

endclass
