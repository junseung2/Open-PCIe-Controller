// pcie_tl_driver.sv
class pcie_tl_driver extends uvm_driver #(pcie_tl_transaction);
    `uvm_component_utils(pcie_tl_driver)

    // Virtual interface handle
    virtual pcie_tl_tx_if vif;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pcie_tl_tx_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not set")
        end
    endfunction

    // Run phase
    task run_phase(uvm_phase phase);
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
        // Drive the AXI write address channel
        vif.aw_ch.awvalid <= tr.awvalid;
        vif.aw_ch.awid <= tr.awid;
        vif.aw_ch.awaddr <= tr.awaddr;
        vif.aw_ch.awlen <= tr.awlen;
        vif.aw_ch.awsize <= tr.awsize;
        vif.aw_ch.awburst <= tr.awburst;
        @(posedge vif.clk);
        vif.aw_ch.awvalid <= 1'b0;

        // Drive the AXI write data channel
        vif.w_ch.wvalid <= tr.wvalid;
        vif.w_ch.wid <= tr.wid;
        vif.w_ch.wdata <= tr.wdata;
        vif.w_ch.wstrb <= tr.wstrb;
        vif.w_ch.wlast <= tr.wlast;
        @(posedge vif.clk);
        vif.w_ch.wvalid <= 1'b0;

        // Drive the TLP header
        vif.tlp_hdr_arr_i <= tr.tlp_header;
        vif.tlp_ready_i <= 1'b1;
        @(posedge vif.clk);
        vif.tlp_ready_i <= 1'b0;
    endtask
endclass
