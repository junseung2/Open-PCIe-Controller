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
        repeat (1) @(posedge clk); // after 2 clock cycles
        rst_n = 1'b1; // release the reset
    end

    // Interface instantiation
    pcie_tl_if intf(clk);

    // DUT instantiation
    PCIE_TL_TX dut (
        .clk(intf.clk),
        .rst_n(rst_n),
        .fc_valid_i(intf.fc_valid_i),
        .aw_ch(intf.aw_ch),
        .w_ch(intf.w_ch),
        .b_ch(intf.b_ch),
        .tlp_hdr_arr_i(intf.tlp_hdr_arr_i),
        .tlp_valid_o(intf.tlp_valid_o),
        .tlp_o(intf.tlp_o),
        .tlp_ready_i(intf.tlp_ready_i)
    );

    // UVM configuration and test start
    initial begin
        uvm_config_db#(virtual pcie_tl_if)::set(uvm_root::get(), "*", "vif", intf);
        run_test("pcie_tl_test");
    end

endmodule
