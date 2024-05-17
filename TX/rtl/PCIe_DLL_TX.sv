`include "PCIe_PKG.sv"
`include "crc32_generator.sv"
`include "crc16_generator.sv"

module PCIE_DLL_TX
(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Input from Transaction Layer
    input  wire                     tlp_valid_i,
    input  wire [223:0]             tlp_i,

    // Input from Physical Layer for ACK/NAK DLLP
    input  wire                     dllp_valid_i,
    input  wire PCIe_PKG::dllp_packet dllp_i,

    // Output to Physical Layer
    output logic                    tlp_valid_o,
    output logic [267:0]            tlp_o  // 236 bits for TLP with sequence number + 32 bits for CRC
);

    // Sequence number
    logic [11:0]                    seq_num, seq_num_n;
    logic [235:0]                   tlp_with_seq;
    logic [31:0]                    crc;

    // Retry Buffer (FIFO)
    logic [267:0]                   retry_buffer[0:15]; // Example depth of 16
    logic [3:0]                     wr_ptr, rd_ptr;
    logic                           retry_empty, retry_full;

    // CRC32 generator instance
    crc32_generator crc_gen (
        .data_i(tlp_i),
        .crc_o(crc)
    );

    // Sequence number logic
    always_comb begin
        if (tlp_valid_i) begin
            seq_num_n = (seq_num == 12'd4095) ? 12'd0 : seq_num + 12'd1;
        end else begin
            seq_num_n = seq_num;
        end
    end

    // Sequence number and CRC assignment, and Retry Buffer handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seq_num <= 12'd0;
            wr_ptr <= 4'd0;
            rd_ptr <= 4'd0;
            retry_empty <= 1'b1;
            retry_full <= 1'b0;
            tlp_valid_o <= 1'b0;
            tlp_o <= 268'd0;
        end else begin
            seq_num <= seq_num_n;

            if (tlp_valid_i && !retry_full) begin
                tlp_with_seq <= {seq_num, tlp_i}; // Append sequence number to TLP
                tlp_o <= {tlp_with_seq, crc}; // Append CRC to TLP with sequence number and CRC
                retry_buffer[wr_ptr] <= tlp_o; // Store in retry buffer

                wr_ptr <= wr_ptr + 4'd1;
                retry_empty <= 1'b0;
                if (wr_ptr == 4'd15)
                    retry_full <= 1'b1;

                tlp_valid_o <= 1'b1;
            end else begin
                tlp_valid_o <= 1'b0;
            end

            // Handle ACK/NAK DLLP
            if (dllp_valid_i) begin
                if (dllp_i.ack_or_nak == 8'h00) begin // ACK DLLP
                    // Remove acknowledged TLPs from retry buffer
                    for (integer i = 0; i < 16; i = i + 1) begin
                        if (retry_buffer[i][267:256] <= dllp_i.seq_num) begin
                            retry_buffer[i] <= 268'd0; // Invalidate entry
                        end
                    end
                end else if (dllp_i.ack_or_nak == 8'h10) begin // NAK DLLP
                    // Retransmit TLP with the specified sequence number
                    for (integer i = 0; i < 16; i = i + 1) begin
                        if (retry_buffer[i][267:256] == dllp_i.seq_num) begin
                            tlp_o <= retry_buffer[i];
                            tlp_valid_o <= 1'b1;
                            break;
                        end
                    end
                end
            end
        end
    end
endmodule
