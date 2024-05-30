module PCIe_PHY_TX #(
    parameter DATA_WIDTH = 128
) (
    input  logic               clk,
    input  logic               reset,
    input  logic [DATA_WIDTH-1:0] tlp,
    input  logic [DATA_WIDTH-1:0] dllp,
    input  logic [DATA_WIDTH-1:0] ordered_set,
    input  logic [DATA_WIDTH-1:0] idle,
    input  logic [1:0]         sel,  // Select signal: 00 -> TLP, 01 -> DLLP, 10 -> Ordered Set, 11 -> Idle
    output logic [31:0]        lane0,
    output logic [31:0]        lane1,
    output logic [31:0]        lane2,
    output logic [31:0]        lane3
);

    // Internal signals
    logic [DATA_WIDTH-1:0] mux_out;
    logic [DATA_WIDTH-1:0] scrambled_data;
    logic [DATA_WIDTH+2-1:0] sync_head_data;

    // Instantiating the MUX
    PCIe_Mux #(
        .DATA_WIDTH(DATA_WIDTH)
    ) mux_inst (
        .clk(clk),
        .reset(reset),
        .tlp(tlp),
        .dllp(dllp),
        .ordered_set(ordered_set),
        .idle(idle),
        .sel(sel),
        .data_out(mux_out)
    );

    // Instantiating the Scrambler
    PCIe_Scrambler #(
        .DATA_WIDTH(DATA_WIDTH)
    ) scrambler_inst (
        .clk(clk),
        .reset(reset),
        .data_in(mux_out),
        .data_out(scrambled_data)
    );

    // Instantiating the Sync Header Generator
    PCIe_Sync_Head_Gen #(
        .DATA_WIDTH(DATA_WIDTH)
    ) sync_head_gen_inst (
        .clk(clk),
        .reset(reset),
        .sync_header(2'b10),  // Example sync header for Data Block
        .data_out(sync_head_data)
    );

    // Instantiating the Byte Striping logic
    PCIe_Byte_Stripe #(
        .DATA_WIDTH(DATA_WIDTH+2),
        .LANE_WIDTH(32)
    ) byte_stripe_inst (
        .clk(clk),
        .reset(reset),
        .data_in(sync_head_data),
        .lane0(lane0),
        .lane1(lane1),
        .lane2(lane2),
        .lane3(lane3)
    );

endmodule
