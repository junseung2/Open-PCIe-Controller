class pcie_tl_env extends uvm_env;

    `uvm_component_utils(pcie_tl_env)

    // Members
    pcie_tl_agent                  agent;
    pcie_tl_scoreboard             scoreboard;

    // Constructor
    function new(string name = "pcie_tl_env", uvm_component parent);
        super.new(name, parent);
    endfunction: new

    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create agent
        agent = pcie_tl_agent::type_id::create("agent", this);
        if (!agent) begin
            `uvm_error("ENV_BUILD", "Failed to create agent");
        end

        // Create scoreboard
        scoreboard = pcie_tl_scoreboard::type_id::create("scoreboard", this);
        if (!scoreboard) begin
            `uvm_error("ENV_BUILD", "Failed to create scoreboard");
        end
    endfunction: build_phase

    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect the monitor's analysis port to the scoreboard's analysis import
        agent.mon_an_port.connect(scoreboard.imp);
    endfunction: connect_phase
endclass
