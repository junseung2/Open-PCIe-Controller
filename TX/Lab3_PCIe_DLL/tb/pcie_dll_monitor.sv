class pcie_dll_monitor extends uvm_monitor;
    `uvm_component_utils(pcie_dll_monitor)

    // Virtual interface
    virtual pcie_dll_if vif;

    // Analysis port for sending observed transactions
    uvm_analysis_port#(pcie_dll_transaction) ap;

    // Constructor: Initializes the monitor with a given name
    function new(string name = "pcie_dll_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction: new

    // Build phase: Retrieves the virtual interface from the configuration database
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pcie_dll_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction: build_phase

    // Run phase: Main task to monitor DUT outputs
    virtual task run_phase(uvm_phase phase);
        forever begin
            pcie_dll_transaction txn;
            txn = pcie_dll_transaction::type_id::create("txn", this);

            // Wait for a clock edge
            @(posedge vif.clk);

            // Capture DUT outputs
            txn.tlp_valid_o     = vif.tlp_valid_o;
            txn.tlp_o           = vif.tlp_o;
            txn.tlp_ready_o     = vif.tlp_ready_o;

            // Send the transaction to the analysis port
            ap.write(txn);

            // Optionally log the transaction
            `uvm_info(get_type_name(), $sformatf(
                "Observed Transaction: tlp_valid_o = %0d, tlp_o = %0h, tlp_ready_o = %0d",
                txn.tlp_valid_o, txn.tlp_o, txn.tlp_ready_o), UVM_MEDIUM)
        end
    endtask: run_phase
endclass
