module crc32_generator
(
    input  wire [223:0] data_i,
    output logic [31:0] crc_o
);

    // Example polynomial: 0x04C11DB7
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
        crc_o = crc;
    end

endmodule
