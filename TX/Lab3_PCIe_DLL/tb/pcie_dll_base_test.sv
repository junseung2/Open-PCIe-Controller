class pcie_dll_test extends uvm_test;

    `uvm_component_utils(pcie_dll_test)

    // Environment and virtual interface
    pcie_dll_env            env;
    pcie_dll_sequence       seq;

    virtual pcie_dll_if     vif;

    // Constructor
    function new(string name = "pcie_dll_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve the virtual interface from the UVM testbench
        if (!uvm_config_db#(virtual pcie_dll_if)::get(null, "*", "vif", vif)) begin
            `uvm_fatal("VIF_NOT_FOUND", "Virtual interface not found in configuration database");
        end

        // Create the environment
        env = pcie_dll_env::type_id::create("env", this);
    endfunction: build_phase

    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction: connect_phase

    // Run test sequence
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this, "Starting Run Phase");

        // Create and start the primary test sequence
        seq = pcie_dll_sequence::type_id::create("seq");
        uvm_config_db#(virtual pcie_dll_if)::set(this, "env.agent.sequencer", "vif", vif);

        seq.start(env.agent.sequencer);

        phase.drop_objection(this, "Main Run Complete");
    endtask: run_phase

endclass
