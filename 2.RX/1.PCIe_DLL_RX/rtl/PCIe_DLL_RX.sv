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


    logic                                                   crc_valid;

    // CRC32 checker instance
    crc32_checker crc_chk (
        .data_i(tlp_i[PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-13:32]),
        .crc_i(tlp_i[31:0]),
        .crc_valid_o(crc_valid)
    );


    // tlp handling logic
    always_comb begin
        tlp_ready_o         = 1'b1;
        tlp_valid_o         = 1'b0;
        tlp_o               = {PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE{1'b0}};
        dllp_o              = {PCIe_PKG::PCIe_DLLP_PACKET_SIZE{1'b0}};

        if(tlp_valid_i && tlp_ready_o) begin
            if(crc_valid) begin
                tlp_valid_o         = 1'b1;
                tlp_o               = tlp_i[PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:32];

                // Ack DLLP
                dllp_o.ack_or_nak   = 8'h00; 
                dllp_o.seq_num      = tlp_i[PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:256];
            end
            else begin
                // Nak DLLP
                dllp_o.ack_or_nak   = 8'h10;
                dllp_o.seq_num      = tlp_i[PCIe_PKG::PCIe_DLL_TLP_PACKET_SIZE-1:256];
            end
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset logic
            wr_ptr                      <= 12'd0;
            rd_ptr                      <= 12'd0;
            fc_empty                    <= 1'b1;
            fc_full                     <= 1'b0;
        end else begin
            // Update write/read pointers, and buffer flags
            wr_ptr                      <= wr_ptr_n;
            rd_ptr                      <= rd_ptr_n;
            fc_empty                    <= fc_empty_n;
            fc_full                     <= fc_full_n;
        end
    end

    // flow control handling logic
    always_comb begin
        // Default values for next state logic
        wr_ptr_n                        = wr_ptr;
        rd_ptr_n                        = rd_ptr;
        fc_empty_n                      = fc_empty;
        fc_full_n                       = fc_full;

        dllp_fc_o                       = {PCIe_PKG::PCIe_DLLP_PACKET_SIZE{1'b0}};

        // Write pointer update logic
        if (tlp_valid_i && tlp_ready_o) begin
            wr_ptr_n                    = wr_ptr + 12'd1;
        end

        // Read pointer update logic
        if (tlp_valid_o && tlp_ready_i) begin
            rd_ptr_n                    = rd_ptr + 12'd1;
        end

        // Update empty/full flags
        if (wr_ptr == rd_ptr) begin
            fc_empty_n                  = 1'b0;
        end
        if (wr_ptr - rd_ptr == 12'd4095) begin
            fc_full_n                   = 1'b1;
        end

        // DLLP Flow Control Packet Generation
        if (fc_full) begin
            dllp_fc_o.data_fc           = 12'd0;
        end else begin
            dllp_fc_o.data_fc           = wr_ptr - rd_ptr;
        end
    end

endmodule