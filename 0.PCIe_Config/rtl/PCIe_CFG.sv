//////////////////////////////////////////////////////////////////////////////////
// Company: Sungkyunkwan University
// Author:  Junseung Lee 
// E-mail:  junseung0728@naver.com

// Project Name: Simple PCIe Controller 
// Design Name:  PCIe Configuration
// Module Name:  PCIe_CFG
//////////////////////////////////////////////////////////////////////////////////

module PCIe_CFG
(
    input   wire                clk,
    input   wire                rst_n,  // _n means active low

    // AMBA APB interface
    input   wire                psel_i,
    input   wire                penable_i,
    input   wire    [11:0]      paddr_i,
    input   wire                pwrite_i,
    input   wire    [31:0]      pwdata_i,
    output  reg                 pready_o,
    output  reg     [31:0]      prdata_o,
    output  reg                 pslverr_o
);

    // Configuration registers
    reg [15:0]                  vendor_id;
    reg [15:0]                  device_id;
    reg [15:0]                  status;
    reg [15:0]                  command;
    reg [23:0]                  class_code;
    reg [7:0]                   rev_id;
    reg [7:0]                   bist;
    reg [7:0]                   header_type;
    reg [7:0]                   latency_timer;
    reg [7:0]                   cache_line_size;
    reg [31:0]                  bar[5:0];
    reg [31:0]                  cardbus_cis;
    reg [15:0]                  subsystem_vendor_id;
    reg [15:0]                  subsystem_device_id;
    reg [31:0]                  exp_rom_base;
    reg [7:0]                   capabilities_pointer;
    reg [23:0]                  reserved_0;
    reg [31:0]                  reserved_1;
    reg [7:0]                   max_lat;
    reg [7:0]                   max_gnt;
    reg [7:0]                   int_pin;
    reg [7:0]                   int_line;
    reg [31:0]                  special_pcie_ip;

    //----------------------------------------------------------
    // Write
    //----------------------------------------------------------
    wire wren = psel_i & penable_i & pwrite_i;

    always @(posedge clk) begin
        if (!rst_n) begin
            vendor_id                   <= 16'd0;
            device_id                   <= 16'd0;
            status                      <= 16'd0;
            command                     <= 16'd0;
            class_code                  <= 24'd0;
            rev_id                      <= 8'd0;
            bist                        <= 8'd0;
            header_type                 <= 8'd0;
            latency_timer               <= 8'd0;
            cache_line_size             <= 8'd0;
            bar[0]                      <= 32'd0;
            bar[1]                      <= 32'd0;
            bar[2]                      <= 32'd0;
            bar[3]                      <= 32'd0;
            bar[4]                      <= 32'd0;
            bar[5]                      <= 32'd0;
            cardbus_cis                 <= 32'd0;
            subsystem_vendor_id         <= 16'd0;
            subsystem_device_id         <= 16'd0;
            exp_rom_base                <= 32'd0;
            capabilities_pointer        <= 8'd0;
            reserved_0                  <= 24'd0;
            reserved_1                  <= 32'd0;
            max_lat                     <= 8'd0;
            max_gnt                     <= 8'd0;
            int_pin                     <= 8'd0;
            int_line                    <= 8'd0;
            special_pcie_ip             <= 32'd0;
        end
        else if (wren) begin
            case (paddr_i)
                12'h00: begin
                    vendor_id           <= pwdata_i[15:0];
                    device_id           <= pwdata_i[31:16];
                end
                12'h04: begin
                    status              <= pwdata_i[31:16];
                    command             <= pwdata_i[15:0];
                end
                12'h08: begin
                    class_code          <= pwdata_i[31:8];
                    rev_id              <= pwdata_i[7:0];
                end
                12'h0C: begin
                    bist                <= pwdata_i[31:24];
                    header_type         <= pwdata_i[23:16];
                    latency_timer       <= pwdata_i[15:8];
                    cache_line_size     <= pwdata_i[7:0];
                end
                12'h10: bar[0]          <= pwdata_i;
                12'h14: bar[1]          <= pwdata_i;
                12'h18: bar[2]          <= pwdata_i;
                12'h1C: bar[3]          <= pwdata_i;
                12'h20: bar[4]          <= pwdata_i;
                12'h24: bar[5]          <= pwdata_i;
                12'h28: cardbus_cis     <= pwdata_i;
                12'h2C: begin
                    subsystem_device_id <= pwdata_i[31:16];
                    subsystem_vendor_id <= pwdata_i[15:0];
                end
                12'h30: exp_rom_base    <= pwdata_i;
                12'h34: begin
                    capabilities_pointer<= pwdata_i[7:0];
                    reserved_0          <= pwdata_i[31:8];
                end
                12'h38: reserved_1      <= pwdata_i;;
                12'h3C: begin
                    max_lat             <= pwdata_i[31:24];
                    max_gnt             <= pwdata_i[23:16];
                    int_pin             <= pwdata_i[15:8];
                    int_line            <= pwdata_i[7:0];
                end
                12'h40: special_pcie_ip <= pwdata_i;
            endcase
        end
    end

    //----------------------------------------------------------
    // Read
    //----------------------------------------------------------
    reg [31:0] rdata;

    always @(posedge clk) begin
        if (!rst_n) begin
            rdata                       <= 32'd0;
        end
        else if (psel_i & !penable_i & !pwrite_i) begin
            case (paddr_i)
                12'h00: rdata           <= {device_id, vendor_id};
                12'h04: rdata           <= {status, command};
                12'h08: rdata           <= {class_code, rev_id};
                12'h0C: rdata           <= {bist, header_type, latency_timer, cache_line_size};
                12'h10: rdata           <= bar[0];
                12'h14: rdata           <= bar[1];
                12'h18: rdata           <= bar[2];
                12'h1C: rdata           <= bar[3];
                12'h20: rdata           <= bar[4];
                12'h24: rdata           <= bar[5];
                12'h28: rdata           <= cardbus_cis;
                12'h2C: rdata           <= {subsystem_device_id, subsystem_vendor_id};
                12'h30: rdata           <= exp_rom_base;
                12'h34: rdata           <= {reserved, capabilities_pointer};
                12'h38: rdata           <= 32'd0; // Reserved
                12'h3C: rdata           <= {max_lat, max_gnt, int_pin, int_line};
                12'h40: rdata           <= special_pcie_ip;
                default: rdata          <= 32'd0;
            endcase
        end
    end

    // Output assignments
    assign pready_o = 1'b1;
    assign prdata_o = rdata;
    assign pslverr_o = 1'b0;

endmodule
