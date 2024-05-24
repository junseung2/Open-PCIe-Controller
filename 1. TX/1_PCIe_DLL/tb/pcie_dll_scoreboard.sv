class pcie_dll_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(pcie_dll_scoreboard)

    // Analysis imp to receive transactions from the monitor
    uvm_analysis_imp#(pcie_dll_transaction, pcie_dll_scoreboard) imp;

    // Constructor: Initializes the scoreboard with a given name
    function new(string name, uvm_component parent);
        super.new(name, parent);
        imp = new("imp", this);
    endfunction: new

    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction: build_phase

    // Write method: Receives transactions from the monitor and compares them
    virtual function void write(pcie_dll_transaction txn);
        // Implement comparison logic here
        
        // `uvm_info(get_type_name(), $sformatf(
        //     "Received Transaction: tlp_valid_o = %0d, tlp_o = %0h, tlp_ready_o = %0d",
        //     txn.tlp_valid_o, txn.tlp_o, txn.tlp_ready_o), UVM_MEDIUM)

        // // Example comparison logic (replace with actual expected results)
        // if (/* some condition based on expected values */) begin
        //     `uvm_error(get_type_name(), "Mismatch detected in transaction")
        // end else begin
        //     `uvm_info(get_type_name(), "Transaction matches expected values", UVM_HIGH)
        // end
    endfunction: write
endclass
