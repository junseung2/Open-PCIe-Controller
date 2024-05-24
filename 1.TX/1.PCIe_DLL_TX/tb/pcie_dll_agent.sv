class pcie_dll_agent extends uvm_agent;

    // Virtual interface
    virtual pcie_dll_if                             vif;

    // UVM agent components
    pcie_dll_driver                                 driver;
    pcie_dll_monitor                                monitor;
    uvm_sequencer #(pcie_dll_transaction)           sequencer;

    // Analysis port for broadcasting transactions to other components
    uvm_analysis_port #(pcie_dll_transaction)       mon_an_port;

    // Configuration to run the agent in passive mode (monitor-only)
    bit is_active = 1;  // Default is active

    // UVM macro for factory registration and type identification
    `uvm_component_utils_begin(pcie_dll_agent)
        `uvm_field_int(is_active, UVM_ALL_ON)
    `uvm_component_utils_end

    // Constructor
    function new(string name = "pcie_dll_agent", uvm_component parent);
        super.new(name, parent);
        mon_an_port = new("mon_an_port", this);
    endfunction: new

    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Fetch the virtual interface from the configuration database
        if (!uvm_config_db#(virtual pcie_dll_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
        end

        // Instantiate components based on the mode
        if (is_active) begin
            sequencer = uvm_sequencer#(pcie_dll_transaction)::type_id::create("sequencer", this);
            driver = pcie_dll_driver::type_id::create("driver", this);
        end
        
        monitor = pcie_dll_monitor::type_id::create("monitor", this);
    endfunction: build_phase

    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active && driver != null) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
        monitor.ap.connect(this.mon_an_port);  // Connect monitor's analysis port to agent's analysis port
    endfunction: connect_phase

endclass
