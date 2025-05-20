module APB_ALU #(parameter [31:0] RO_START = 'b11_11, RO_END = 'b00_00, MEMORY_DEPTH = 3) //Slave
(
    input  logic PCLK, 
    input  logic PRESETn,

    //APB INTERFACE
    input  logic        PSEL, 
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [3:0]  PSTRB,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY,

    output wire [31:0]       OUT1,
    output wire [31:0]       OUT2,
    output wire [31:0]       OUT3,
    output reg [15:0] A, B, OP,
    output reg [15:0] Valid,
    output reg [15:0] OUT,

    output wire [3:0]lrg_thn_ro_strt,
    output wire [3:0]les_thn_ro_end,
    output wire [3:0] ro_region

     

);
reg [31:0] REGISTERS [MEMORY_DEPTH];






reg [3:0]  ENABLES[2];
reg [31:0] SHIFTED_PWDATA;
reg [31:0] CURRENT_BASE_ADDRESS;
reg        output_ready;

     wire   [1:0]     OFFSET;
     wire   [1:0]     BASE;
     reg              CURRENT_CYCLE;
     logic            OVERFLOW;
    //  wire   [31:0]      OUT1;
    //  wire   [31:0]      OUT2;
     reg    [3:0]      LARGER_THAN_RO_START;
     reg    [3:0]      SMALLER_THAN_RO_END;
     reg    [3:0]      RO_REGION;
     reg    [31:0]     EFFECTIVE_ADDRESS;



assign OUT1 = REGISTERS[0];
assign OUT2 = REGISTERS[1];
assign OUT3 = REGISTERS[2];


assign BASE =   PADDR[3:2];
assign OFFSET = PADDR[1:0];

//Byte Enables Logic
always@(*) begin
    ENABLES[0] = 0;
    ENABLES[1] = 0;
    //SECOND_EN = 0;
    case(OFFSET)
    0:
        {ENABLES[1], ENABLES[0]} = PSTRB<<0;
    1:
        {ENABLES[1], ENABLES[0]} = PSTRB<<1;
    2:
        {ENABLES[1], ENABLES[0]} = PSTRB<<2;
    3:
        {ENABLES[1], ENABLES[0]} = PSTRB<<3;
    endcase
    OVERFLOW = ENABLES[1][0];
end

assign lrg_thn_ro_strt = {LARGER_THAN_RO_START[3], LARGER_THAN_RO_START[2], LARGER_THAN_RO_START[1], LARGER_THAN_RO_START[0]};
assign les_thn_ro_end = {SMALLER_THAN_RO_END[3], SMALLER_THAN_RO_END[2], SMALLER_THAN_RO_END[1], SMALLER_THAN_RO_END[0]};
assign ro_region = RO_REGION;
//Read-Only Protection
reg [31:0] dummy[8];
always@(*)
begin
    CURRENT_BASE_ADDRESS = 0;
    CURRENT_BASE_ADDRESS = BASE + CURRENT_CYCLE;
    EFFECTIVE_ADDRESS = CURRENT_BASE_ADDRESS<<2 ;
    //I Forgot <<32, the problem is LARGER_THAN_RO_START[x] detects only the bit[32] (33th bit);
    {LARGER_THAN_RO_START[0],dummy[0]} =  ((RO_START)- (EFFECTIVE_ADDRESS))|((RO_START) == (EFFECTIVE_ADDRESS))<<32;
    {SMALLER_THAN_RO_END[0],dummy[1]} =   ((EFFECTIVE_ADDRESS) - (RO_END));
    
    {LARGER_THAN_RO_START[1],dummy[2]} =  ((RO_START)- (EFFECTIVE_ADDRESS|2'd1))|((RO_START) == (EFFECTIVE_ADDRESS|2'd1))<<32;
    {SMALLER_THAN_RO_END[1],dummy[3]} =   ((EFFECTIVE_ADDRESS|2'd1) - (RO_END));
    
    {LARGER_THAN_RO_START[2],dummy[4]} =  ((RO_START)- (EFFECTIVE_ADDRESS|2'd2))|((RO_START) == (EFFECTIVE_ADDRESS|2'd2))<<32;
    {SMALLER_THAN_RO_END[2],dummy[5]} =   ((EFFECTIVE_ADDRESS|2'd2) - (RO_END));
    
    {LARGER_THAN_RO_START[3],dummy[6]} =  ((RO_START)- (EFFECTIVE_ADDRESS|2'd3))|((RO_START) == (EFFECTIVE_ADDRESS|2'd3))<<32;
    {SMALLER_THAN_RO_END[3],dummy[7]} =   ((EFFECTIVE_ADDRESS|2'd3) - (RO_END));
    
    RO_REGION = LARGER_THAN_RO_START & SMALLER_THAN_RO_END; 


end

//Shifted Data for Second Cycle
always@(*)
begin
    if(CURRENT_CYCLE==0)
        SHIFTED_PWDATA = PWDATA;
    else
    begin
        case(OFFSET)
        0:
        SHIFTED_PWDATA = PWDATA;
        1:
        SHIFTED_PWDATA = PWDATA>>(8*3); //three written, get rid of them >>24 (8*3)
        2:
        SHIFTED_PWDATA = PWDATA>>(8*2); //2 written, get rid of them >> so that in the new cycle the new values are shown
        3:
        SHIFTED_PWDATA = PWDATA>>(8*1); //1 written, get rid of it >>
        endcase 
    end
end

//PREADY(APB) and CURRENT_CYCLE Logic
always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
    begin
        PREADY <= 0;
        CURRENT_CYCLE <= 0;
    end
    else
    begin
        if(PENABLE && PSEL) begin
            case(OVERFLOW) //Thanks God
            0:
            begin

                CURRENT_CYCLE <= 0;
                PREADY <= 1;
                // if(!PWRITE)
                // begin
                //     PREADY <= 0;
                //     if(output_ready)
                //         PREADY <= 1;
                // end
            end
            1:
            begin
                if(CURRENT_CYCLE == 1)
                begin
                    PREADY <= 1;
                    CURRENT_CYCLE <= 0;
                    // if(!PWRITE)
                    // begin
                    //     CURRENT_CYCLE <= 1;
                    //     PREADY <= 0;
                    //     if(output_ready) begin
                    //         PREADY <= 1;
                    //         CURRENT_CYCLE <= 0;
                    //     end
                    // end
                end
                else
                begin
                    PREADY <= 0;
                    CURRENT_CYCLE <= 1;
                end
            end
            endcase
        end
        else begin
            PREADY <= 0;
            CURRENT_CYCLE <= 0;
        end
    end
end

// REGISTERS READ & WRITE LOGIC
always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        for(int x = 0; x < MEMORY_DEPTH; x++)
        begin
            REGISTERS[x] <= 0;
        end
        PRDATA <= 0;
        // output_ready <= 0;
    end
    else begin
        //output_ready <= 0;
        //Write Logic is more complicated because it's not just about the starting point (offset) we also should 
        //make sure it doesn't cross the endpoint FBE: 0010, LBE:0000, offset = 1, and end @ base + offset + 1 (byte 8bits) mem [15:8] <= data [0:7]
        //while doesn't need it's end point to be specified (just read 4 bytes each tome and trim them it bridge later if needed)
 
        if(PENABLE && PSEL) 
        begin
            if(PWRITE) begin
                
                if(ENABLES[CURRENT_CYCLE][3]&&!RO_REGION[3])
                    begin
                        if (ENABLES[CURRENT_CYCLE][2:0] == 3'b111)
                            REGISTERS[CURRENT_BASE_ADDRESS][31:24] <= SHIFTED_PWDATA[31:24];
                        else if(ENABLES[CURRENT_CYCLE][2:1] == 2'b11)
                            REGISTERS[CURRENT_BASE_ADDRESS][31:24] <= SHIFTED_PWDATA[23:16];
                        else if(ENABLES[CURRENT_CYCLE][2] == 1'b1)
                            REGISTERS[CURRENT_BASE_ADDRESS][31:24] <= SHIFTED_PWDATA[15:8];
                        else // Only ENABLES[CURRENT_CYCLE][3] = 1
                            REGISTERS[CURRENT_BASE_ADDRESS][31:24] <= SHIFTED_PWDATA[7:0];
                    end
                
                if(ENABLES[CURRENT_CYCLE][2]&&!RO_REGION[2])
                    begin
                        if(ENABLES[CURRENT_CYCLE][1:0] == 2'b11)
                            REGISTERS[CURRENT_BASE_ADDRESS][23:16] <= SHIFTED_PWDATA[23:16];
                        else if(ENABLES[CURRENT_CYCLE][1] == 1'b1)
                            REGISTERS[CURRENT_BASE_ADDRESS][23:16] <= SHIFTED_PWDATA[15:8];
                        else // Only ENABLES[CURRENT_CYCLE][2] = 1
                            REGISTERS[CURRENT_BASE_ADDRESS][23:16]  <= SHIFTED_PWDATA[7:0];
                    end
                
                if(ENABLES[CURRENT_CYCLE][1]&&!RO_REGION[1])
                    begin
                        if(ENABLES[CURRENT_CYCLE][0] == 1'b1)
                            REGISTERS[CURRENT_BASE_ADDRESS][15:8]  <= SHIFTED_PWDATA[15:8];
                        else // Only ENABLES[CURRENT_CYCLE][1] = 1
                            REGISTERS[CURRENT_BASE_ADDRESS][15:8]  <= SHIFTED_PWDATA[7:0];
                    end
                
                if(ENABLES[CURRENT_CYCLE][0]&&!RO_REGION[0])
                    begin
                        REGISTERS[CURRENT_BASE_ADDRESS][7:0]  <= SHIFTED_PWDATA[7:0];
                    end 
            end
            else begin //Read
                case(CURRENT_CYCLE)
                    0:
                    begin
                        case (OFFSET)
                        0: PRDATA[31:0] <= REGISTERS[CURRENT_BASE_ADDRESS][31:0];
                        1: PRDATA[23:0] <= REGISTERS[CURRENT_BASE_ADDRESS][31:8];
                        2: PRDATA[15:0] <= REGISTERS[CURRENT_BASE_ADDRESS][31:16];
                        3: PRDATA[7:0]  <= REGISTERS[CURRENT_BASE_ADDRESS][31:24];
                        endcase  
                    end
                    1:
                    begin
                        case (OFFSET)
                        1: PRDATA[31:24] <= REGISTERS[CURRENT_BASE_ADDRESS][7:0];
                        2: PRDATA[31:16] <= REGISTERS[CURRENT_BASE_ADDRESS][15:0];
                        3: PRDATA[31:8]  <= REGISTERS[CURRENT_BASE_ADDRESS][23:0];
                        endcase   
                    end
 
                endcase
                    // if(CURRENT_BASE_ADDRESS==1)
                    //     REGISTERS[1][16:8] <= 0;
            end
        end
        else
        begin
            //if(!(PENABLE & PSEL)) begin
                if(Valid) begin
                    REGISTERS[2][15:0] <= OUT;
                    //REGISTERS[1][16:8] <= 1;
                    REGISTERS[1][31:16] <= 0;
                    //output_ready <= 1;
                end
            //end
        end
       
    end
end

always @(posedge PCLK) begin
    begin
        
    end

end

//CORE
// reg [7:0] A, B, OP;
// reg [7:0] Valid;
// reg [7:0] OUT;

always@(*)
begin
A = REGISTERS[0][15:0];
B = REGISTERS[0][31:16];
OP = REGISTERS[1][15:0];
Valid = REGISTERS[1][31:16];
//-----------------------------------
// case(OP)
// 0:
// OUT = A+B;
// 1:
// OUT = A-B;
// 4:
// OUT = A&B;
// 5:
// OUT = A|B;
// 6:
// OUT = A^B;
// default:
// OUT = 0;

// endcase
OUT = 0;
if(OP==0)
OUT = A+B;
if(OP==1)
OUT = A-B;
if(OP==2)
OUT = A&B;
if(OP==3)
OUT = A|B;
end

reg [1:0] Counter;
always@(posedge PCLK or negedge PRESETn)
begin
if(PRESETn)
begin
output_ready <= 0;
Counter <= 0;
end
else
begin

end

end





endmodule
