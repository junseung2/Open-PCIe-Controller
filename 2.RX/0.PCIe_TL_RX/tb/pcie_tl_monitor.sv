class pcie_tl_monitor extends uvm_monitor;
    `uvm_component_utils(pcie_tl_monitor)

    // Virtual interface
    virtual pcie_tl_if vif;

    // Analysis port for sending observed transactions
    uvm_analysis_port#(pcie_tl_transaction) ap;

    // Constructor: Initializes the monitor with a given name
    function new(string name = "pcie_tl_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction: new

    // Build phase: Retrieves the virtual interface from the configuration database
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pcie_tl_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found");
    endfunction: build_phase

    // Run phase: Main task to monitor DUT outputs
    virtual task run_phase(uvm_phase phase);
        // super.run_phase(phase);
        #(10);
        forever begin
            pcie_tl_transaction txn ;
            txn = pcie_tl_transaction::type_id::create("txn",this);

            // Capture DUT outputs
            txn.tlp_valid     = vif.tlp_valid_o;
            txn.tlp           = vif.tlp_o;

            // if(txn.tlp_vali)
            // Send the transaction to the analysis port
            ap.write(txn);

            // Optionally log the transaction
            `uvm_info(get_type_name(), $sformatf(
                "Observed Transaction\n: tlp_valid_o = %0d\n, tlp_o = %0h\n",
                txn.tlp_valid, txn.tlp), UVM_MEDIUM)
            
            @(posedge vif.clk);
        end

    endtask: run_phase
endclass
