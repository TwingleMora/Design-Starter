module TXTOP #(
    parameter DATAWIDTH=8,PTRWIDTH=4,STATEWIDTH = 3
)
(
input clk,rst,
input [DATAWIDTH-1:0] P_DATA,
input DATA_VALID,
input PAR_EN,PAR_TYP,
output TX_OUT,Busy   
);
wire [STATEWIDTH-1:0] mux_sel;
wire start_bit=1'b0;
wire stop_bit=1'b1;
wire ser_data,par_bit;
//reg               par_en;
wire ser_en;
wire ser_done;
/*
input clk,rst,
input data_Valid,PAR_EN,ser_done
output reg [STATEWIDTH-1:0] mux_sel,
output reg busy,ser_en*/
FSM #(.STATEWIDTH(STATEWIDTH)) fsm 
(
.clk(clk),.rst(rst),
.data_Valid(DATA_VALID),.PAR_EN(PAR_EN),.ser_done(ser_done),
.mux_sel(mux_sel),
.busy(Busy),.ser_en(ser_en)
);

parityCalc#(
    .DATAWIDTH(DATAWIDTH) 
)pcalc
 (
    .clk(clk),.rst(rst),
    .data_Valid(DATA_VALID),.PAR_TYP(PAR_TYP),
    .P_DATA(P_DATA),
    .par_bit(par_bit)
);


serializer#(
    .DATAWIDTH(DATAWIDTH),.PTRWIDTH(PTRWIDTH)
) seri(
     .clk(clk),.rst(rst),
    .P_DATA(P_DATA),
    .Data_Valid(DATA_VALID),.ser_en(ser_en),
    .ser_data(ser_data),.ser_done(ser_done)
);

MUX  #(.STATEWIDTH(STATEWIDTH))mux
(
.mux_sel(mux_sel),
.start_bit(start_bit),.stop_bit(stop_bit),.ser_data(ser_data),.par_bit(par_bit),
.TX_OUT(TX_OUT)
);
endmodule