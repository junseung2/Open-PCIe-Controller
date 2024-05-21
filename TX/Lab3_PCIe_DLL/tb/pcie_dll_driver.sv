class pcie_dll_driver extends uvm_driver<pcie_dll_transaction>;
    `uvm_component_utils(pcie_dll_driver)

    // Virtual interface
    virtual pcie_dll_if vif;

    // Constructor: Initializes the driver with a given name
    function new(string name = "pcie_dll_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    // Build phase: Retrieves the virtual interface from the configuration database
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pcie_dll_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction: build_phase

    // Run phase: Main task to drive transactions to the DUT
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pcie_dll_transaction txn;
            
            // Get the next transaction from the sequencer
            seq_item_port.get_next_item(txn);

            // Apply the transaction to the DUT via the virtual interface
            vif.tlp_valid_i     <= txn.tlp_valid;
            vif.tlp_i           <= txn.tlp;
            vif.tlp_ready_i     <= txn.tlp_ready;
            vif.dllp_in         <= txn.dllp;
            vif.dllp_valid_i    <= txn.dllp_valid;

            // Wait for a clock edge
            @(posedge vif.clk);

            // Mark the transaction as done
            seq_item_port.item_done();
        end
    endtask: run_phase
endclass
