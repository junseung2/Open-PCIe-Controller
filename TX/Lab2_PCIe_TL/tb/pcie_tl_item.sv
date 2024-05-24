// pcie_tl_transaction.sv
class pcie_tl_transaction extends uvm_sequence_item;

    `uvm_object_utils(pcie_tl_transaction)

    // Randomizable fields for the transaction
    rand PCIe_PKG::tlp_memory_header tlp_header;  // TLP Header
    rand logic [PCIe_PKG::PCIe_DATA_PAYLOAD_SIZE-1:0] tlp_data;  // TLP Data

    // AXI Write Address Channel
    rand logic awvalid;
    rand logic [AXI_AW_CH::ID_WIDTH-1:0] awid;
    rand logic [AXI_AW_CH::ADDR_WIDTH-1:0] awaddr;
    rand logic [3:0] awlen;
    rand logic [2:0] awsize;
    rand logic [1:0] awburst;

    // AXI Write Data Channel
    rand logic wvalid;
    rand logic [AXI_W_CH::ID_WIDTH-1:0] wid;
    rand logic [AXI_W_CH::DATA_WIDTH-1:0] wdata;
    rand logic [AXI_W_CH::DATA_WIDTH/8-1:0] wstrb;
    rand logic wlast;

    // Constructor
    function new(string name = "pcie_tl_transaction");
        super.new(name);
    endfunction: new

    // Constraints for valid AXI write transaction
    constraint axi_write_c {
        awvalid == 1'b1;
        wvalid == 1'b1;
        wlast == 1'b1;
    }

endclass
