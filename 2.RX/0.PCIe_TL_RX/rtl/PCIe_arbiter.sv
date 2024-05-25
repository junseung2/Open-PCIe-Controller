module PCIe_arbiter (
    input  wire             clk,
    input  wire             rst_n,

    input  wire             vc0_empty,
    input  wire [223:0]     vc0_rdata,
    input  wire             vc1_empty,
    input  wire [223:0]     vc1_rdata,

    input  wire             tlp_ready_i,
    input  wire             fc_valid_i,     // Flow control valid input

    output reg              vc0_rden,
    output reg              vc1_rden,
    
    output reg              tlp_valid_o,
    output reg [223:0]      tlp_o
);

    reg arbiter_select, arbiter_select_n;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            arbiter_select <= 1'b0;
        end else begin
            arbiter_select <= arbiter_select_n;
        end
    end

    always_comb begin
        vc0_rden = 1'b0;
        vc1_rden = 1'b0;
        tlp_valid_o = 1'b0;
        tlp_o = 224'd0;

        if (tlp_ready_i && fc_valid_i) begin
            if (arbiter_select) begin
                if (!vc0_empty) begin
                    vc0_rden = 1'b1;
                    tlp_valid_o = 1'b1;
                    tlp_o = vc0_rdata;
                end else if (!vc1_empty) begin
                    vc1_rden = 1'b1;
                    tlp_valid_o = 1'b1;
                    tlp_o = vc1_rdata;
                end
            end else begin
                if (!vc1_empty) begin
                    vc1_rden = 1'b1;
                    tlp_valid_o = 1'b1;
                    tlp_o = vc1_rdata;
                end else if (!vc0_empty) begin
                    vc0_rden = 1'b1;
                    tlp_valid_o = 1'b1;
                    tlp_o = vc0_rdata;
                end
            end

            // Toggle arbiter_select
            if (tlp_valid_o && tlp_ready_i) begin
                arbiter_select_n = ~arbiter_select;
            end else begin
                arbiter_select_n = arbiter_select;
            end
        end else begin
            arbiter_select_n = arbiter_select;
        end
    end

endmodule
