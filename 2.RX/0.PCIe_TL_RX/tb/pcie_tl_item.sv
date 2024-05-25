class pcie_tl_transaction extends uvm_sequence_item;

    `uvm_object_utils(pcie_tl_transaction)

    // Randomizable fields for the transaction
    rand logic fc_valid; 
    rand PCIe_PKG::tlp_memory_header tlp_header;  // TLP Header
    
    // AXI Write Address Channel
    rand logic awvalid;

    // AXI Write Data Channel
    rand logic wvalid;
    rand logic [127:0] wdata;

    // Data Link interface 
    rand logic tlp_ready;

    // Output fields (not randomized)
    logic tlp_valid; 
    logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0] tlp;


    // Constructor
    function new(string name = "pcie_tl_transaction");
        super.new(name);
    endfunction: new

    // Constraints for tlp_header field
    constraint tlp_header_c {
        tlp_header.fmt inside {3'b000, 3'b010};
        tlp_header.type_ == 5'b00000;
    }

    constraint tlp_ready_c{
        tlp_ready == 1'b1;
    }

    constraint awvalid_c {
        awvalid == 1;
    }

    constraint wvalid_c {
        wvalid == 1;
    }

    constraint fc_valid_c {
        fc_valid == 1;
    }


endclass
