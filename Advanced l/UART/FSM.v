module FSM #(parameter STATEWIDTH = 3) (
input clk,rst,
input data_Valid,PAR_EN,ser_done,
output reg [STATEWIDTH-1:0] mux_sel,
output reg busy,ser_en
);

  localparam IDLE =  0,
             START=  1,
             DATA=   2,
             PARITY= 3,
             STOP =  4;

reg[STATEWIDTH-1:0] next;  
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        mux_sel<=IDLE;
        busy<=0;//busy is register because i want store it's vaue at start and then release it at stop
    end
    else
    begin
        mux_sel<=next;
    end
end
//Next State Logic
always @(*) begin
   case(mux_sel)
   IDLE:
   begin
    if(data_Valid)
    begin
       next = START;  
    end
    else
       next =IDLE;
   end
   START:
   begin
     next=DATA;
   end
   DATA:
   begin
    if(ser_done)
    begin
    if(PAR_EN)
    next=PARITY;
    else
    next=STOP;
    end
   end
   PARITY:
   begin
    next=STOP;
   end
   STOP:
   begin
    next = IDLE;
   end
   default://to prevent latches
   next=IDLE;
   endcase 
end
//Outputs Logic
always @(*) begin
   //busy is wire will depend on the output of state register
   //if busy was register it'ld depend on the value of next wire(input of state register)
   busy=1;
   ser_en=0;// that'll prevent latches
   //if ser_en is to be stored in Register in serializer then it's enough to make it high in START State Only
   //if ser_en is just a wire connected to comb logic in serializer then we have to set it high at start and at data
   //ser_en is connected to serializer input logic
   case(mux_sel)
   IDLE:
   begin
    busy=0;
   end
   START:
   begin
    ser_en =1;
   end
   DATA:
   begin
    ser_en=1;
    if(ser_done)
    ser_en=0;
    else
    ser_en=1;
   end
   endcase 
end
endmodule