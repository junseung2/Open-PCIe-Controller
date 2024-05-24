class pcie_dll_driver extends uvm_driver #(pcie_dll_transaction);

    `uvm_component_utils(pcie_dll_driver)

    // Virtual interface reference
    virtual pcie_dll_if vif;

    // Constructor
    function new(string name = "pcie_dll_driver", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    // Connect the virtual interface
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual pcie_dll_if)::get(this, "", "vif", vif);
    endfunction: build_phase

    // Validating vif 
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase); 

        if(vif == null) begin
            `uvm_fatal(get_type_name(), "Virtual Interface ERROR! Interface for Driver not set");
        end
    endfunction: end_of_elaboration_phase

    // Driving function
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            pcie_dll_transaction txn;
            seq_item_port.get_next_item(txn);
            drive_transaction(txn);
            seq_item_port.item_done();
        end
    endtask: run_phase

    // Function to apply the transaction to the DUT via the interface
    protected virtual task drive_transaction(pcie_dll_transaction txn);
        // Apply transaction properties to the interface signals
        vif.tlp_valid_i     = txn.tlp_valid_i;
        vif.tlp_i           = txn.tlp_i;
        vif.tlp_ready_i     = txn.tlp_ready_i;

        // Ensure timing by waiting for a clock edge if needed
        @(posedge vif.clk);
        
    endtask: drive_transaction

endclass
