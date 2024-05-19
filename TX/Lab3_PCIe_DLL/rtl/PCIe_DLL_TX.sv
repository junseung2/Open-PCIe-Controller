`include "PCIe_PKG.sv"
`include "crc32_generator.sv"
`include "crc16_generator.sv"

module PCIE_DLL_TX
(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Transaction Layer Interface
    input  wire                     tlp_valid_i,
    input  wire [223:0]             tlp_i,
    output logic                    tlp_ready_o,

    // Physical Layer Interface 
    output logic                    tlp_valid_o,
    output logic [267:0]            tlp_o,  // 224 bits for TLP + 12 bits for sequence number + 32 bits for CRC
    input  wire                     tlp_ready_i,

    // DLLP from RX Interface
    input  PCIe_PKG::dllp_packet    dllp_in,
    input  logic                    dllp_valid_i
);

    // Sequence number
    logic [11:0]                    seq_num, seq_num_n;
    logic [235:0]                   tlp_with_seq;
    logic [31:0]                    crc;

    // Temporary TLP with sequence and CRC
    logic [267:0]                   tlp;

    // Retry Buffer (FIFO)
    logic [267:0]                   retry_buffer[0:4095]; // Depth of 4096
    logic [11:0]                    wr_ptr, rd_ptr;
    logic [11:0]                    wr_ptr_n, rd_ptr_n;
    logic                           retry_empty, retry_full;
    logic                           retry_empty_n, retry_full_n;

    // CRC32 generator instance
    crc32_generator crc_gen (
        .data_i(tlp_i),
        .crc_o(crc)
    );

    // Sequence number logic
    always_comb begin
        if (tlp_valid_i && tlp_ready_o) begin
            seq_num_n               = (seq_num == 12'd4095) ? 12'd0 : seq_num + 12'd1;
        end else begin
            seq_num_n               = seq_num;
        end
    end

    // Next state logic for retry buffer pointers and flags
    always_comb begin
        wr_ptr_n                    = wr_ptr;
        rd_ptr_n                    = rd_ptr;
        retry_empty_n               = retry_empty;
        retry_full_n                = retry_full;

        if (tlp_valid_i && tlp_ready_o && !retry_full) begin
            wr_ptr_n                = (wr_ptr == 12'd4095) ? 12'd0 : wr_ptr + 12'd1;
            retry_empty_n           = 1'b0;
            if ((wr_ptr == rd_ptr - 12'd1) || (wr_ptr == 12'd4095 && rd_ptr == 12'd0)) begin
                retry_full_n        = 1'b1;
            end
        end else if (!retry_empty && tlp_ready_i) begin
            rd_ptr_n                = (rd_ptr == 12'd4095) ? 12'd0 : rd_ptr + 12'd1;
            retry_full_n            = 1'b0;
            if (rd_ptr_n == wr_ptr) begin
                retry_empty_n       = 1'b1;
            end
        end
    end

    // Sequence number and CRC assignment, and Retry Buffer handling
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seq_num                 <= 12'd0;
            wr_ptr                  <= 12'd0;
            rd_ptr                  <= 12'd0;
            retry_empty             <= 1'b1;
            retry_full              <= 1'b0;
            tlp_valid_o             <= 1'b0;
            tlp                     <= 268'd0;
            tlp_o                   <= 268'd0;
            tlp_ready_o             <= 1'b1;
        end else begin
            seq_num                 <= seq_num_n;
            wr_ptr                  <= wr_ptr_n;
            rd_ptr                  <= rd_ptr_n;
            retry_empty             <= retry_empty_n;
            retry_full              <= retry_full_n;

            if (dllp_valid_i) begin
                if (dllp_in.ack_or_nak == 8'h00) begin // ACK
                    // Update read pointer based on ACKed sequence number
                    rd_ptr_n            <= dllp_in.seq_num + 12'd1;
                    if (rd_ptr_n == wr_ptr) begin
                        retry_empty_n   <= 1'b1;
                    end
                    retry_full_n        <= 1'b0;
                end 
                else if (dllp_in.ack_or_nak == 8'h10) begin // NAK
                    // Retransmit TLP from retry buffer
                    tlp_o               <= retry_buffer[dllp_in.seq_num];
                    tlp_valid_o         <= 1'b1;
                end
            end else begin
                if (tlp_valid_i && tlp_ready_o && !retry_full) begin
                    // Append sequence number and CRC to TLP
                    tlp_with_seq            <= {seq_num, tlp_i};
                    tlp                     <= {tlp_with_seq, crc};

                    // Store in retry buffer
                    retry_buffer[wr_ptr]    <= tlp;

                    // Indicate TLP is valid for transmission
                    tlp_valid_o             <= 1'b1;
                end else if (tlp_ready_i && !retry_empty) begin
                    // Output next TLP from the retry buffer if Physical Layer is ready
                    tlp_o                   <= retry_buffer[rd_ptr];
                    tlp_valid_o             <= 1'b1;
                    rd_ptr                  <= rd_ptr_n;
                    retry_full              <= 1'b0;
                    if (rd_ptr_n == wr_ptr) begin
                        retry_empty         <= 1'b1;
                    end
                end else begin
                    tlp_valid_o             <= 1'b0;
                end
            end
            // Update tlp_ready_o based on the retry buffer state
            tlp_ready_o                     <= !retry_full;
        end
    end
endmodule
