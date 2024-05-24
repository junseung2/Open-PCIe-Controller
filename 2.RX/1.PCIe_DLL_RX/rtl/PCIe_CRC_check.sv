module crc32_checker
(
    input  wire [PCIe_PKG::PCIe_TL_TLP_PACKET_SIZE-1:0] data_i,
    input  wire [31:0]                                  crc_i,
    output logic                                        crc_valid_o
);

    // 예제 다항식: 0x04C11DB7
    logic [31:0] crc;
    integer i;

    always_comb begin
        crc = 32'hFFFFFFFF;
        for (i = 0; i < 224; i = i + 1) begin
            if ((crc[31] ^ data_i[i]) == 1'b1) begin
                crc = {crc[30:0], 1'b0} ^ 32'h04C11DB7;
            end else begin
                crc = {crc[30:0], 1'b0};
            end
        end
        // 계산된 CRC와 수신된 CRC 비교
        crc_valid_o = (crc == crc_i);
    end
endmodule