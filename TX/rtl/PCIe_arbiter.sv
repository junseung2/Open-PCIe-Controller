module arbiter
(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  vc0_empty,
    input  wire [223:0]          vc0_data,
    input  wire                  vc1_empty,
    input  wire [223:0]          vc1_data,
    output logic [223:0]         tlp_o,
    output logic                 tlp_valid_o,
    output logic                 rd_en_vc0,
    output logic                 rd_en_vc1
);

    logic select_vc0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            select_vc0 <= 1'b0;
            tlp_valid_o <= 1'b0;
            tlp_o <= 224'd0;
            rd_en_vc0 <= 1'b0;
            rd_en_vc1 <= 1'b0;
        end else begin
            if (select_vc0) begin
                if (!vc0_empty) begin
                    tlp_o <= vc0_data;
                    tlp_valid_o <= 1'b1;
                    rd_en_vc0 <= 1'b1;
                    rd_en_vc1 <= 1'b0;
                end else if (!vc1_empty) begin
                    tlp_o <= vc1_data;
                    tlp_valid_o <= 1'b1;
                    rd_en_vc0 <= 1'b0;
                    rd_en_vc1 <= 1'b1;
                end else begin
                    tlp_valid_o <= 1'b0;
                    rd_en_vc0 <= 1'b0;
                    rd_en_vc1 <= 1'b0;
                end
                select_vc0 <= 1'b0; // Switch to VC1 for next arbitration
            end else begin
                if (!vc1_empty) begin
                    tlp_o <= vc1_data;
                    tlp_valid_o <= 1'b1;
                    rd_en_vc1 <= 1'b1;
                    rd_en_vc0 <= 1'b0;
                end else if (!vc0_empty) begin
                    tlp_o <= vc0_data;
                    tlp_valid_o <= 1'b1;
                    rd_en_vc1 <= 1'b0;
                    rd_en_vc0 <= 1'b1;
                end else begin
                    tlp_valid_o <= 1'b0;
                    rd_en_vc0 <= 1'b0;
                    rd_en_vc1 <= 1'b0;
                end
                select_vc0 <= 1'b1; // Switch to VC0 for next arbitration
            end
        end
    end

endmodule
