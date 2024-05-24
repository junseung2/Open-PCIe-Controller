package PCIe_PKG;

    localparam  int     PCIe_DATA_PAYLOAD_SIZE      = 128;  
    localparam  int     PCIe_TL_TLP_PACKET_SIZE     = 224;  
    localparam  int     PCIe_DLL_TLP_PACKET_SIZE    = 268;  
   
    typedef struct packed {
        logic [1:0]             ph;             // [95:94]
        logic [29:0]            address;        // [93:64]
        logic [15:0]            requester_id;   // [63:48]
        logic [7:0]             tag;            // [47:40]
        logic [3:0]             last_dw_be;     // [39:36]
        logic [3:0]             first_dw_be;    // [35:32]
        logic [2:0]             fmt;            // [31:29]
        logic [4:0]             type_;          // [28:24]
        logic                   t9;             // [23]
        logic [2:0]             tc;             // [22:20]                     
        logic                   t8;             // [19]
        logic                   attr_1;         // [18]
        logic                   ln;             // [17]
        logic                   th;             // [16]
        logic                   td;             // [15]
        logic                   ep;             // [14]
        logic [1:0]             attr_0;         // [13:12]
        logic [1:0]             at;             // [11:10]
        logic [9:0]             length;         // [9:0]
    } tlp_memory_header;

    typedef struct packed {
        logic [15:0]    crc1;           // [47:32]
        logic [7:0]     ack_or_nak;     // [31:24]
        logic [11:0]    reserved;       // [23:12]
        logic [11:0]    seq_num;        // [11:0]
    } dllp_packet; 

endpackage
