interface pcie_dll_if(input wire clk);

  logic                             tlp_valid_i;
  logic [223:0]                     tlp_i;
  logic                             tlp_ready_o;
  logic                             tlp_valid_o;
  logic [267:0]                     tlp_o;
  logic                             tlp_ready_i;
  PCIe_PKG::dllp_packet             dllp_in;
  logic                             dllp_valid_i;
  logic                             tlp_blocking_i;

endinterface
