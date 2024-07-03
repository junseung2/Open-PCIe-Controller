//////////////////////////////////////////////////////////////////////////////////
// Company: Sungkyunkwan University
// Author:  Junseung Lee 
// E-mail:  junseung0728@naver.com

// Project Name: Simple PCIe Controller 
// Design Name:  PCIe Data Link Layer
// Module Name:  PCIe_DLL_RX
//////////////////////////////////////////////////////////////////////////////////

module PCIE_DLL_RX
(
    input  wire                                             clk,
    input  wire                                             rst_n,

    // Physical Layer Interface
    input  wire                                             tlp_valid_i,    // 물리 계층에서의 TLP 유효 입력
    input  wire [PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:0]    tlp_i,          // 물리 계층에서의 TLP 입력 (seq 및 CRC 포함)
    output logic                                            tlp_ready_o,    // 물리 계층으로의 TLP 준비 출력

    // Transaction Layer Interface
    output logic                                            tlp_valid_o,    // Transaction Layer로의 TLP 유효 출력
    output logic [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0]    tlp_o,          // Transaction Layer로의 TLP 출력
    input  wire                                             tlp_ready_i,    // Transaction Layer에서의 TLP 준비 입력

    // Ack/Nak DLLP
    output PCIe_PKG::dllp_packet                            dllp_o,
    output PCIe_PKG::dllp_fc_packet                         dllp_fc_o
);

    import PCIe_PKG::*;

    // Flow Control Buffer (FIFO)
    logic                                                   fc_buffer[4095:0]; 
    logic [11:0]                                            wr_ptr, rd_ptr;         // Write and read pointers
    logic                                                   fc_empty, fc_full;      // Flags to indicate if the retry buffer is empty or full
    logic [11:0]                                            wr_ptr_n, rd_ptr_n;     // Next state for write and read pointers
    logic                                                   fc_empty_n, fc_full_n;  // Next state for retry buffer flags

    logic [11:0]                                            expected_seq_num, expected_seq_num_n;

    logic                                                   crc_valid;

    // CRC32 checker instance
    crc32_checker crc_chk (
        .data_i(tlp_i[PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-13:32]),
        .crc_i(tlp_i[31:0]),
        .crc_valid_o(crc_valid)
    );


    /* Fill the code here */




    

endmodule