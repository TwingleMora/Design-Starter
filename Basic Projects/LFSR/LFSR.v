module LFSR (
    input clock,reset,out_enable,enable,
    input      [7:0] Seed,
    output reg [7:0] LFSR,
    output reg Valid,OUT
);
 integer i;
 reg [7:0] taps = 8'b10101010;
 reg feedback,Valid_Comb,OUT_Comb;
 reg [7:0] LFSR_COMB;
 
 function reg [7:0] SET_LFSR_COMB;
    input fb;
    input [7:0] lfsr;
    integer i;

    begin
     SET_LFSR_COMB[0] =  fb;
      for(i =1  ;  i <= 7  ;  i = i + 1)
       begin
        if(taps[i]==1)
         begin
          SET_LFSR_COMB[i] = lfsr[i-1]^fb;  
         end
        else
         begin
           SET_LFSR_COMB[i] = lfsr[i-1];
         end
       end 
    end
    
 endfunction
 always@(*)
 begin
   feedback = (~|LFSR[6:0]) ^ (LFSR[7]);
   //LFSR_COMB[0] = feedback; 
   
   Valid_Comb=0;
   OUT_Comb=OUT;
    if(enable)
     begin
     LFSR_COMB = SET_LFSR_COMB(feedback,LFSR);
     end
    else if(out_enable&&!enable)
     begin
      LFSR_COMB=LFSR>>1;
      
       Valid_Comb=1;
       OUT_Comb =  LFSR[0];
      
      end
    else
     begin
      LFSR_COMB = LFSR;
     end
 end
 always@(posedge clock or negedge reset)
 begin
    if(!reset)//priority for reset
     begin 
      LFSR<=Seed;
      OUT<=0;
      Valid<=0;
     end
    else
     begin
      LFSR <= LFSR_COMB;
      Valid <= Valid_Comb;
      OUT <= OUT_Comb;
     end
 end
function [3:0] new_feature(input [3:0] x);
begin
new_feature = x+3;
end
endfunction
function [3:0] new_feature2(input [3:0] x);
begin
new_feature2 = x+3;
end
endfunction
endmodule
