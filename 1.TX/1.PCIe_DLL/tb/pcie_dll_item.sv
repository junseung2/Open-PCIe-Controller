class pcie_dll_transaction extends uvm_sequence_item;

    `uvm_object_utils(pcie_dll_transaction)

    // Randomizable fields for the transaction
    rand bit                                            tlp_valid; 
    rand bit [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]    tlp; 
    rand bit                                            tlp_ready; 
    rand PCIe_PKG::dllp_packet                          dllp;
    rand bit                                            dllp_valid; 
    rand bit                                            tlp_blocking;

    // Output fields (not randomized)
    bit                                                 tlp_ready_o;
    bit                                                 tlp_valid_o;
    bit [PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:0]        tlp_o; 

    // Constructor
    function new(string name = "pcie_dll_transaction");
        super.new(name);
    endfunction: new

    constraint tlp_c{
        tlp_valid == 1'b1;
        tlp_ready == 1'b1;
    }

    // Constraint for dllp
    constraint dllp_c {
        // ack_or_nak can be either 00000000 or 00010000
        dllp.ack_or_nak inside {8'b00000000, 8'b00010000};
        // dllp.ack_or_nak == 8'b00000000;

        // reserved must be 12'b0
        dllp.reserved == 12'b0;

        // crc16 must be 16'b0 now
        dllp.crc1   == 16'b0;
    }

    // Constraint for tlp_blocking_i based on dllp.ack_or_nak
    constraint tlp_blocking_c {
        if ((dllp.ack_or_nak == 8'b00010000) && (dllp_valid ==1'b1)) {
            tlp_blocking == 1;
        } else {
            tlp_blocking == 0;
        }
    }

endclass
