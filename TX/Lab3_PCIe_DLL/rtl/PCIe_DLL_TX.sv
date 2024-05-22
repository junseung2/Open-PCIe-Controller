//////////////////////////////////////////////////////////////////////////////////
// Company: Sungkyunkwan University
// Author:  Junseung Lee 
// E-mail:  junseung0728#naver.com

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

    // Sequence number and CRC assignment, and Retry Buffer handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            seq_num                     <= 12'd0;
            wr_ptr                      <= 12'd0;
            rd_ptr                      <= 12'd0;
            retry_empty                 <= 1'b1;
            retry_full                  <= 1'b0;
        end else begin
            // Update sequence number, write/read pointers, and buffer flags
            seq_num                     <= seq_num_n;
            wr_ptr                      <= next_wr_ptr;
            rd_ptr                      <= next_rd_ptr;
            retry_empty                 <= next_retry_empty;
            retry_full                  <= next_retry_full;
        end
    end

    // Sequence number logic: update on valid TLP input
    always_comb begin
        if (dllp_valid_i && dllp_in.ack_or_nak == 8'h10) begin
            seq_num_n                   = seq_num - 12'd1;
        end
        else if (tlp_valid_i && tlp_ready_o) begin
            seq_num_n                   = (seq_num == 12'd4095) ? 12'd0 : seq_num + 12'd1;
        end 
        else begin
            seq_num_n                   = seq_num;
        end
    end

    always_comb begin
    // Default values for next state logic
    next_wr_ptr                         = wr_ptr;
    next_rd_ptr                         = rd_ptr;
    next_retry_empty                    = retry_empty;
    next_retry_full                     = retry_full;

    // Default values for TLP signals
    tlp_o                               = 268'd0;
    tlp_valid_o                         = 1'b0;
    tlp_ready_o                         = !retry_full;

    // DLLP Handling
    if (dllp_valid_i) begin
        if (dllp_in.ack_or_nak == 8'h00) begin // ACK
            // Update read pointer based on ACKed sequence number
            next_rd_ptr                 = dllp_in.seq_num + 12'd1;
            if (next_rd_ptr == wr_ptr) begin
                next_retry_empty        = 1'b1;
            end
            next_retry_full             = 1'b0;

            // Store in retry buffer
            retry_buffer[wr_ptr]        = {seq_num, tlp_i, crc};
            
            tlp_valid_o                 = 1'b1;
            tlp_o                       = {seq_num, tlp_i, crc};
            $display("Transmitting TLP: seq_num=%0d, tlp=%0h", seq_num, {seq_num, tlp_i, crc});

        end else if (dllp_in.ack_or_nak == 8'h10) begin // NAK
            // Retransmit TLP from retry buffer
            tlp_o                       = retry_buffer[dllp_in.seq_num];
            tlp_valid_o                 = 1'b1;
            $display("NAK received: Retransmitting TLP seq_num=%0d, tlp=%0h", dllp_in.seq_num, retry_buffer[dllp_in.seq_num]);
        end
    end else begin
        if (tlp_valid_i && tlp_ready_o && !tlp_blocking_i) begin
            // Append sequence number and CRC to TLP

            retry_buffer[wr_ptr]        = {seq_num, tlp_i, crc};    // Store in retry buffer
            
            tlp_valid_o                 = 1'b1;
            tlp_o                       = {seq_num, tlp_i, crc};
            $display("Transmitting TLP: seq_num=%0d, tlp=%0h", seq_num, {seq_num, tlp_i, crc});

            // Update write pointer and buffer full/empty flags
            next_wr_ptr                 = (wr_ptr == 12'd4095) ? 12'd0 : wr_ptr + 12'd1;
            next_retry_empty            = 1'b0;
            if ((wr_ptr == rd_ptr - 12'd1) || (wr_ptr == 12'd4095 && rd_ptr == 12'd0)) begin
                next_retry_full         = 1'b1;
            end
        end
    end
    end

endmodule
