`define AXI_ADDR_WIDTH          32
`define AXI_DATA_WIDTH          128
`define AXI_ID_WIDTH            4

interface AXI_AW_CH
#(
    parameter   ADDR_WIDTH      = `AXI_ADDR_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk
);
    logic                       awvalid;    // [master] master가 valid한 write address 정보를 채널에 제공했음을 나타냄. 
    logic                       awready;    // [slave] slave가 write address 정보를 받을 준비가 됨을 나타냄. 
    logic   [ID_WIDTH-1:0]      awid;       // [master] transaction ID 식별자. 
    logic   [ADDR_WIDTH-1:0]    awaddr;     // [master] write address
    logic   [3:0]               awlen;      // [master] burst length 
    logic   [2:0]               awsize;     // [master] burst size. burst 내 데이터 전송의 크기를 지정 
    logic   [1:0]               awburst;    // [master] 버스트 유형을 지정. (fixed, increment, wrap)

    modport master (
        output awvalid,
        input  awready,
        output awid,
        output awaddr,
        output awlen,
        output awsize,
        output awburst
    );

    modport slave (
        input  awvalid,
        output awready,
        input  awid,
        input  awaddr,
        input  awlen,
        input  awsize,
        input  awburst
    );
endinterface

interface AXI_W_CH
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk
);
    logic                       wvalid;     // [master]
    logic                       wready;     // [slave]
    logic   [ID_WIDTH-1:0]      wid;        // [master] Response ID tag(AXI3에서만 지원)
    logic   [DATA_WIDTH-1:0]    wdata;      // [master] write할 실제 data 
    logic   [DATA_WIDTH/8-1:0]  wstrb;      // [master] byte enable 각 8bit마다 하나의 write strobe bit 있음. 
    logic                       wlast;      // [master] write burst에서 마지막 전송임을 나타냄. 

    modport master (
        output wvalid,
        input  wready,
        output wid,
        output wdata,
        output wstrb,
        output wlast
    );

    modport slave (
        input  wvalid,
        output wready,
        input  wid,
        input  wdata,
        input  wstrb,
        input  wlast
    );
endinterface

interface AXI_B_CH
#(
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk
);
    logic                       bvalid;     // [slave]  
    logic                       bready;     // [master] 
    logic   [ID_WIDTH-1:0]      bid;        // [slave] response ID tag
    logic   [1:0]               bresp;      // [slave] response 상태 (e.g., transaction이 성공적인지 실패인지 등을 나타냄)

    modport master (
        input  bvalid,
        output bready,
        input  bid,
        input  bresp
    );

    modport slave (
        output bvalid,
        input  bready,
        output bid,
        output bresp
    );
endinterface

interface AXI_AR_CH
#(
    parameter   ADDR_WIDTH      = `AXI_ADDR_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk
);
    logic                       arvalid;    // [master]
    logic                       arready;    // [slave]
    logic   [ID_WIDTH-1:0]      arid;       // [master] read address ID tag
    logic   [ADDR_WIDTH-1:0]    araddr;     // [master] read할 address 값
    logic   [3:0]               arlen;      // [master] burst length
    logic   [2:0]               arsize;     // [master] burst 내 각 전송의 크기
    logic   [1:0]               arburst;    // [master] burst type 정보 

    modport master (
        output arvalid,
        input  arready,
        output arid,
        output araddr,
        output arlen,
        output arsize,
        output arburst
    );

    modport slave (
        input  arvalid,
        output arready,
        input  arid,
        input  araddr,
        input  arlen,
        input  arsize,
        input  arburst
    );
endinterface

interface AXI_R_CH
#(
    parameter   DATA_WIDTH      = `AXI_DATA_WIDTH,
    parameter   ID_WIDTH        = `AXI_ID_WIDTH
 )
(
    input                       clk
);
    logic                       rvalid;     // [slave]
    logic                       rready;     // [master]
    logic   [ID_WIDTH-1:0]      rid;        // [slave]     
    logic   [DATA_WIDTH-1:0]    rdata;      // [slave] read한 실제 data 값 
    logic   [1:0]               rresp;      // [slave] read 전송의 상태 
    logic                       rlast;      // [slave] read burst에서 마지막 전송임을 나타냄. 

    modport master (
        input  rvalid,
        output rready,
        input  rid,
        input  rdata,
        input  rresp,
        input  rlast
    );

    modport slave (
        output rvalid,
        input  rready,
        output rid,
        output rdata,
        output rresp,
        output rlast
    );
endinterface

interface APB (
    input                       clk
);
    logic                       psel;       // [master] slave device가 선택되었는지 나타냄. 
    logic                       penable;    // [master] data enable (일종의 valid)
    logic   [31:0]              paddr;      // [master] 읽거나 쓸 address
    logic                       pwrite;     // [master] data 전송 방향. 1이면 data가 peripheral device에 쓰여짐. 0이면 반대로 slave에서 읽어짐.
    logic   [31:0]              pwdata;     // [master] data
    logic                       pready;     // [slave] slave(peripheral) device가 data 전송이 완료됨을 알리는 신호. 
    logic   [31:0]              prdata;     // [slave] 읽혀진 data
    logic                       pslverr;    // [slave] 오류 관련 신호. 

    // a semaphore to allow only one access at a time
    semaphore                   sema;
    initial begin
        sema                        = new(1);
    end

    // signal 방향 정의. 
    modport master (
        input           clk,
        input           pready, prdata, pslverr,                // master로 들어오는 신호들. 즉, slave단에서 master로 주는 신호들. 
        output          psel, penable, paddr, pwrite, pwdata    // master에서 slave로 주는 신호들.  
    );

    // APB 초기화. master 부분. 
    task init();
        psel                    = 1'b0;
        penable                 = 1'b0;
        paddr                   = 32'd0;
        pwrite                  = 1'b0;
        pwdata                  = 32'd0;
    endtask

    // 주어진 주소(addr)에 data를 쓰는 작업 수행. 
    // semaphore를 사용하여 동시 접근 방지. APB protocol에 따른 write operation 
    // APB Write Operation
    // psel=1로 설정하는 동시에, paddr에 write할 addr, pdata에 write할 data 전송. write이므로, pwrite=1.  
    task automatic write(input int addr,
                         input int data);
        // during a write, another threads cannot access APB
        sema.get(1);
        #1
        // IDLE to Setup 
        psel                    = 1'b1;
        penable                 = 1'b0;
        paddr                   = addr;
        pwrite                  = 1'b1;
        pwdata                  = data;
        @(posedge clk);
        #1
        // Setup to ACCESS 
        penable                 = 1'b1;
        @(posedge clk);

        // slave가 ready 할때까지 clk 진행. 
        // pready=1 이 아닌 경우 계속해서 access 상태. 
        while (pready==1'b0) begin
            @(posedge clk);
        end

        // ACCESS to IDLE
        psel                    = 1'b0;
        penable                 = 1'b0;
        paddr                   = 'hX;
        pwrite                  = 1'bx;
        pwdata                  = 'hX;

        // release the semaphore
        sema.put(1);
    endtask

    // 주어진 주소(addr)에서 data를 read하는 작업 수행. 
    // APB Read Operation 
    // psel=1로 만드는 동시 read할 address(addr)을 paddr로 보냄. read이므로 pwdata=x이며, pwrite=0.  
    task automatic read(input int addr,
                        output int data);
        // during a read, another threads cannot access APB
        sema.get(1);
        #1
        // IDLE to Setup
        psel                    = 1'b1;
        penable                 = 1'b0;
        paddr                   = addr;
        pwrite                  = 1'b0;
        pwdata                  = 'hX;
        @(posedge clk);
        #1

        // Setup to ACCESS
        penable                 = 1'b1;
        @(posedge clk);

        while (pready==1'b0) begin
            @(posedge clk);
        end
        data                    = prdata; // read할 data를 data(output)에 할당. 

        // ACCESS to IDLE
        psel                    = 1'b0;
        penable                 = 1'b0;
        paddr                   = 'hX;
        pwrite                  = 1'bx;
        pwdata                  = 'hX;

        // release the semaphore
        sema.put(1);
    endtask

endinterface
