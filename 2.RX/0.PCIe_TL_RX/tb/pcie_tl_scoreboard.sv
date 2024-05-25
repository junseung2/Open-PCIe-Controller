class pcie_tl_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(pcie_tl_scoreboard)

    // Analysis imp to receive transactions from the monitor
    uvm_analysis_imp#(pcie_tl_transaction, pcie_tl_scoreboard) imp;

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
    virtual function void write(pcie_tl_transaction txn);
      
    endfunction: write
endclass
