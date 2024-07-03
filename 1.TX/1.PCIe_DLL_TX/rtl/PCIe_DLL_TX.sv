//////////////////////////////////////////////////////////////////////////////////
// Company: Sungkyunkwan University
// Author:  Junseung Lee 
// E-mail:  junseung0728@naver.com

// Project Name: Simple PCIe Controller 
// Design Name:  PCIe Data Link Layer
// Module Name:  PCIE_DLL_TX
//////////////////////////////////////////////////////////////////////////////////

module PCIE_DLL_TX
(
    input  wire                                             clk,
    input  wire                                             rst_n,
    
    // Transaction Layer Interface
    input  wire                                             tlp_valid_i,    // TLP valid input from Transaction Layer
    input  wire [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]     tlp_i,          // TLP input from Transaction Layer
    output logic                                            tlp_ready_o,    // TLP ready output to Transaction Layer

    // Physical Layer Interface 
    output logic                                            tlp_valid_o,    // TLP valid output to Physical Layer
    output logic [PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:0]   tlp_o,          // TLP output to Physical Layer (with seq and CRC)
    input  wire                                             tlp_ready_i,    // TLP ready input from Physical Layer

    // DLLP from RX Interface
    input  PCIe_PKG::dllp_packet                            dllp_in,        // DLLP packet input from RX
    input  logic                                            dllp_valid_i,    // DLLP valid input

    // Blocking tlps during retry
    input  logic                                            tlp_blocking_i 
);

    import uvm_pkg::*; 
    import PCIe_PKG::*;
    // Sequence number
    logic [11:0]                                            seq_num, seq_num_n; // Sequence number and next sequence number

    logic [31:0]                                            crc;                // CRC value

    // Retry Buffer (FIFO)
    logic [267:0]                                           retry_buffer[0:4095];               // Depth of 4096 for retry buffer
    logic [11:0]                                            wr_ptr, rd_ptr;                     // Write and read pointers
    logic                                                   retry_empty, retry_full;            // Flags to indicate if the retry buffer is empty or full
    logic [11:0]                                            next_wr_ptr, next_rd_ptr;           // Next state for write and read pointers
    logic                                                   next_retry_empty, next_retry_full;  // Next state for retry buffer flags

    // CRC32 generator instance
    crc32_generator crc_gen (
        .data_i(tlp_i),
        .crc_o(crc)
    );

    /* Fill the code here */





    

endmodule
