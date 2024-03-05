// Write your modules here!
module JKRegister(input J,K,CLK,LOAD,IN,output reg Q);
  always@(posedge CLK or negedge LOAD)
    begin
      if(!LOAD)
        Q<=IN;
        else
          begin
            if(J&&K)
            Q<=~Q;
            else if(J)
              Q<=1;
            else if(K)
              Q<=0;
           end
    end
endmodule
module JKCombination#(parameter INPUTS=0)(input [INPUTS-1:0]Q,UP_DOWN,output JK);
assign JK = ((~|(Q)&~UP_DOWN) | (&(Q)&UP_DOWN));
endmodule
module Counter#(parameter WIDTH=5)(input CLK,UP_DOWN,RESET,output [(WIDTH-1):0] Q);
  //UP_DOWN = (UP:1 , DOWN:0)
  wire [WIDTH-1:0] JK;
  wire [WIDTH-1:0]IN = {(WIDTH){~UP_DOWN}};//Reset Value
  
  
  //Generating "UP DOWN" Muxes
  //UP_DOWN=1 Activates Nor Gates Between Registers For Up Counting
  //UP_DOWN=0 Activates AND Gates Between Registers For DOWN Counting
  assign JK[0] = 1;//J & K always equal 1 at first register(Toggling always)
  genvar REGISTER_POINTER;
  generate 
//Generates Combination Circuit [Inputs: Q[REGISTER_POINTER-1], UP_DOWN, OUTPUT: REGISTER INPUT(JK)]
    for(REGISTER_POINTER=1;REGISTER_POINTER<(WIDTH);REGISTER_POINTER=REGISTER_POINTER+1)begin
    //using and gate for up counter and nor for down counter
    //[REGISTER_POINTER-1:0]
    JKCombination#(.INPUTS(REGISTER_POINTER)) jk (Q[REGISTER_POINTER-1:0],UP_DOWN,JK[REGISTER_POINTER]);
    end
  endgenerate
  generate
//Generate JK Register Blocks [Inputs: JK[REGISTER_POINTER], CLK, RST, IN, OUTPUT: COUNTER]
    for(REGISTER_POINTER=0;REGISTER_POINTER<(WIDTH);REGISTER_POINTER=REGISTER_POINTER+1)begin
      JKRegister R(.J(JK[REGISTER_POINTER]),.K(JK[REGISTER_POINTER]),.CLK(CLK),.LOAD(RESET),.IN(IN),.Q(Q[REGISTER_POINTER]));
    end
  endgenerate
  

endmodule