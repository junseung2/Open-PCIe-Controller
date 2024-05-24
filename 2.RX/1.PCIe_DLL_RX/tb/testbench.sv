module top;

    import uvm_pkg::*; 
    import pcie_dll_test_pkg::*;

    // Clock and reset generation
    reg clk = 0;
    reg rst_n = 1;

    initial begin
        clk = 1'b0;
        forever #10 clk = !clk; 
    end

    // Reset generation
    initial begin
        rst_n = 1'b0; // active low reset
        repeat (1) @(posedge clk); // after 1 clock cycles
        rst_n = 1'b1; // release the reset
    end

    // Interface instantiation
    pcie_dll_if intf(clk);

    // DUT instantiation
    PCIE_DLL_RX dut (
        .clk(intf.clk),
        .rst_n(rst_n),
        .tlp_valid_i(intf.tlp_valid_i),
        .tlp_i(intf.tlp_i),
        .tlp_ready_o(intf.tlp_ready_o),
        .tlp_valid_o(intf.tlp_valid_o),
        .tlp_o(intf.tlp_o),
        .tlp_ready_i(intf.tlp_ready_i),
        .dllp_o(intf.dllp_o),
        .dllp_fc_o(intf.dllp_fc_o)
    );

    // UVM configuration and test start
    initial begin
        uvm_config_db#(virtual pcie_dll_if)::set(uvm_root::get(), "*", "vif", intf);
        run_test("pcie_dll_test");
    end

endmodule
