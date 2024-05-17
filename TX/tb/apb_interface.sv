interface APB(
    input logic clk,
    input logic rst_n
);
    logic psel_i;
    logic penable_i;
    logic pwrite_i;
    logic [11:0] paddr_i;
    logic [31:0] pwdata_i;
    logic [31:0] prdata_o;
    logic pready_o;
    logic pslverr_o;

    // APB write task
    task apb_write(input logic [11:0] addr, input logic [31:0] data);
        @(negedge clk);
        psel_i <= 1;
        penable_i <= 0;
        pwrite_i <= 1;
        paddr_i <= addr;
        pwdata_i <= data;
        @(negedge clk);
        penable_i <= 1;
        @(negedge clk);
        psel_i <= 0;
        penable_i <= 0;
        pwrite_i <= 0;
    endtask

    // APB read task
    task apb_read(input logic [11:0] addr, output logic [31:0] data);
        @(negedge clk);
        psel_i <= 1;
        penable_i <= 0;
        pwrite_i <= 0;
        paddr_i <= addr;
        @(negedge clk);
        penable_i <= 1;
        @(negedge clk);
        data <= prdata_o;
        psel_i <= 0;
        penable_i <= 0;
    endtask

endinterface
