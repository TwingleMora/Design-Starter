module MASTER_BRIDGE
(
    input logic         PCLK,
    input logic         PRESETn,


// Slave Interface
//  input   logic [31:0]    PRDATA,
//  input   logic           PWRITE,
 
//SLAVE Interface (APB-Like Interface FROM Transaction )
    //input   logic           PSEL,
    input   logic           PENABLE,
    output  logic           PREADY,

     
//-----------------------------------------------
//  input  logic  [7:0]     tag,
//  input  logic            EP,
    
    input  logic  [2:0]     tlp_mem_io_msg_cpl_conf,
    input  logic            tlp_address_32_64,
    input  logic            tlp_read_write,
    //input  logic            tlp_conf_type,
    
    input  logic  [3:0]     first_dw_be,
    input  logic  [3:0]     last_dw_be,
    input  logic  [31:0]    lower_addr,

    //calculate OFFSET and M_PSTRB

    input  logic             last_dw,
    input  logic  [31:0]     data,
    input  logic             DATA_BUFF_EMPTY,
    output logic             DATA_BUFF_RD_EN,

    input  logic  [11:0]     config_dw_number,

    //input  logic  [2:0]     TC,
    //input  logic  [2:0]     ATTR,
    //input  logic  [15:0]    device_id,

    //input  logic  [11:0]    byte_count,
    //input  logic  [31:0]    upper_addr,


    //input  logic  [15:0]    dest_bdf_id,

    // input  logic            valid,
    // input  logic            received_valid,

    //input logic             first;

// Master Interface (TO APPLICATION & CONF MEMORY)

    input  logic [31:0] M_PRDATA1,
    input  logic [31:0] M_PRDATA2,

    input  logic        M_PREADY1,
    input  logic        M_PREADY2,
 

    output logic        M_PSEL1,
    output logic        M_PSEL2,

    output logic [31:0] M_PADDR,
    output logic        M_PENABLE,
    output logic        M_PWRITE,
    output logic [3:0]  M_PSTRB,
    output logic [31:0] M_PWDATA 


    //////////////TRANSMITER///////////// FOR COMPLETION //////////////
);

wire upper_addr_x = '0;
//reg [1:0] M_PSEL;
reg [31:0] M_PRDATA;
reg        M_PREADY;




typedef enum logic [1:0] {IDLE = 0, START, ACCESS} STATE;
typedef enum logic [2:0] {MEM_TLP = 0, IO_TLP, MSG_TLP, CPL_TLP, CONF_TLP} TLP_TYPE;
typedef enum logic       {X32 = 0, X64 = 1}                 MEM_ADDR;
typedef enum logic       {READ = 0, WRITE = 1}              TLP_MODE;
typedef enum logic       {HEADER0 = 0, HEADER1 = 1}         CONF_TYPE;

STATE       current, next;
TLP_TYPE    tlp_type;
MEM_ADDR    mem_addr;
TLP_MODE    tlp_mode;
CONF_TYPE   conf_type;

always_comb
begin
tlp_type  = TLP_TYPE'(tlp_mem_io_msg_cpl_conf);
mem_addr  = MEM_ADDR'(tlp_address_32_64);
tlp_mode  = TLP_MODE'(tlp_read_write);
//conf_type = CONF_TYPE'(tlp_conf_type);
end

reg [31:0] GADDR;
reg [1:0]  GOFFSET;
reg [7:0]  GBYTE_ENABLE;
reg [7:0]  GPSTRB;

always@(*)
begin
    // M_PWDATA = data;
end

always@(*)
begin
    case(tlp_type)
    MEM_TLP:
    begin
        M_PRDATA = M_PRDATA1;
        M_PREADY = M_PREADY1;
    end
    CONF_TLP:
    begin
        M_PRDATA = M_PRDATA2;
        M_PREADY = M_PREADY2;
    end
    default:
    begin
        M_PRDATA = 0;
        M_PREADY = 0;
    end
    endcase

end


always@(*)
begin
if(first_dw_be[0]) //1111
    GOFFSET = 0;
else if(first_dw_be[1]) //1110
    GOFFSET = 1;
else if(first_dw_be[2]) //1100
    GOFFSET = 2;
else if(first_dw_be[3]) //
    GOFFSET = 3;
    
/*  
|  3  |  2  |  1  |  0  |
|  7  |  6  |  5  |  4  |
*/    
GADDR = lower_addr | GOFFSET;
GBYTE_ENABLE = {last_dw_be, first_dw_be};
//REMOVE OFFSET FROM BYTE ENABLE
// Addr: 00, offset: 1, BE: 111(01) 0 (00)
// Addr: 01, offset: 1, BE: 0(04) 1(03) 1(02) 1(01)
//addr: 01, byte count: 4, 
case(GOFFSET)
0: GPSTRB = GBYTE_ENABLE;
1: GPSTRB = GBYTE_ENABLE>>1;
2: GPSTRB = GBYTE_ENABLE>>2;
3: GPSTRB = GBYTE_ENABLE>>3;
endcase
end

always@(posedge PCLK or negedge PRESETn)
begin
    if(!PRESETn)
    begin
        current <= IDLE;
        PREADY<=0;
        M_PSEL1<=0;
        M_PSEL2<=0;

        M_PWRITE<=0;
        M_PADDR<=0;

        M_PWDATA<=0;
        DATA_BUFF_RD_EN<=0; //>>>>>> @ IDLE
        //  
    end
    else
    begin
        
        case(current)
        IDLE:
        begin
            PREADY <= 0;
            
            M_PSEL1 <= 0;
            M_PSEL2 <= 0;
            if(PENABLE&&!PREADY) // Everything is ready
            begin

                case(tlp_mode)
                    READ: M_PWRITE  <= 0;
                    WRITE: begin
                        M_PWRITE <= 1;
                    end
                endcase
                
                case(tlp_type)
                    MEM_TLP: begin
                        M_PSEL1 <= 1;
                        M_PSEL2 <= 0;

                        M_PADDR <= GADDR;
                        M_PSTRB <= GPSTRB[3:0];

                    end
                    CONF_TLP: begin
                        M_PSEL1 <= 0;
                        M_PSEL2 <= 1;

                        M_PADDR <= config_dw_number;
                    end

                endcase

            if(!DATA_BUFF_EMPTY)
            begin
                /////////////////////////
                // M_PWDATA <= data; //sample
                // DATA_BUFF_RD_EN<=0; // increase rd pointer

                M_PWDATA <= data; //sample (data_old_first)
                DATA_BUFF_RD_EN<=1; // increase rd pointer
                //pulling first dw and increase the pointer
                current <= START;
            end
            end
        end
        START: begin
            /*
            current = start
            DATA_BUFF_RD_EN = 1
            M_PWDATA = data_old_first
            PADDR = address
            */

            // M_PWDATA <= data; //sample
            // DATA_BUFF_RD_EN<=1; // increase rd pointer
            M_PENABLE <= 1;
            DATA_BUFF_RD_EN<=0; // stop increasing rd pointer
            // now rd pointer is pointing to next read element
            current <= ACCESS;
        end
        ACCESS: begin
            /*
            current = access
            DATA_BUFF_RD_EN = 0
            data = data_new
            M_PWDATA = data_old_first
            M_PENABLE = 1
            M_PADDR = address
            M_PSTRB = first_be;
            */

            if(M_PREADY)
            begin
                case(DATA_BUFF_EMPTY) 
                    1: begin
                        current <= IDLE;// <<< @IDLE  DATA_BUFF_RD_EN =0, PREADY = 1, M_PENABLE = 0
                        DATA_BUFF_RD_EN<=0; //stop reading pointer
                        PREADY <= 1; // Totally Finished
                        M_PENABLE <= 0;
                    end
                    0: begin //Not Finished
                        /* 
                        
                        |-------|
                        |       | ---flag---> last_dw_flag
                        |       | ---data---> last_dw_data
                        |_______|    
                        sample and turn off DATA_BUFF_RD_EN or turn it on
                        
                        */
                       
                        case(last_dw)
                            1: begin //at the end of this cycle I'm gonna read the last dw 
                                // M_PENABLE <= 1; 
                                // DATA_BUFF_RD_EN <= 1; ////stop increase reading pointer // 2ryt 5las
                                // PREADY  <= 1;
                                // M_PADDR <= M_PADDR + 4;// m3aya address
                                
                                M_PSTRB <= GPSTRB[7:4];
                            end
                            0: begin
                                //DATA_BUFF_RD_EN <= 1; //increase reading pointer 
                                //M_PADDR <= M_PADDR + 4;
                                
                                M_PSTRB <= 4'b1111;
                            end
                        endcase
                        M_PWDATA <= data; //sample // m3aya data
                        DATA_BUFF_RD_EN <= 1;
                        M_PADDR <= M_PADDR + 4;
                        // King
                        M_PENABLE <= 0;
                        current <= START;

                        
                    end
                endcase
            end
            else
            begin
                DATA_BUFF_RD_EN <= 0;
            end

        end
        endcase
    end

end


//Memory Mapping The Address I should Have 



endmodule