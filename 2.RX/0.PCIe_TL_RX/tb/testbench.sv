module top;

    import uvm_pkg::*; 
    import pcie_tl_test_pkg::*;

    // Clock and reset generation
    reg clk = 0;
    reg rst_n = 1;

    initial begin
        clk = 1'b0;
        forever #10 clk = !clk; // 50 MHz clock
    end

    // Reset generation
    initial begin
        rst_n = 1'b0; // active low reset
        repeat (2) @(posedge clk); // after 2 clock cycles
        rst_n = 1'b1; // release the reset
    end

    // Interface instantiation
    pcie_tl_if intf(clk);

    // DUT instantiation
    PCIe_TL_RX dut (
        .clk(intf.clk),
        .rst_n(rst_n),
        .fc_valid_i(intf.fc_valid_i),
        .ar_ch(intf.ar_ch),
        .r_ch(intf.r_ch),
        .tlp_valid_i(intf.tlp_valid_i),
        .tlp_i(intf.tlp_i),
        .tlp_ready_o(intf.tlp_ready_o),
        .tlp_hdr_arr_o(intf.tlp_hdr_arr_o)
    );

    // UVM configuration and test start
    initial begin
        uvm_config_db#(virtual pcie_tl_if)::set(uvm_root::get(), "*", "vif", intf);
        run_test("pcie_tl_test");
    end

endmodule
