// pcie_tl_driver.sv
class pcie_tl_driver extends uvm_driver #(pcie_tl_transaction);
    `uvm_component_utils(pcie_tl_driver)

    // Virtual interface handle
    virtual pcie_tl_if vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pcie_tl_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not set")
        end
    endfunction

    // Run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            // Get the next transaction from the sequencer
            pcie_tl_transaction tr;
            seq_item_port.get_next_item(tr);

            // Drive the TLP header and data to the DUT
            drive_tlp(tr);

            // Item done
            seq_item_port.item_done();
        end
    endtask

    // Drive TLP transaction to the DUT
    task drive_tlp(pcie_tl_transaction tr);
        // Drive the AXI read address channel
        vif.r_ch.rready     = tr.rready;

        // Drive the flow control 
        vif.fc_valid_i      = tr.fc_valid;

        // Drive the TLP 
        vif.tlp_i           = tr.tlp;
        vif.tlp_valid_i     = tr.tlp_valid;

        @(posedge vif.clk);
    endtask
endclass
