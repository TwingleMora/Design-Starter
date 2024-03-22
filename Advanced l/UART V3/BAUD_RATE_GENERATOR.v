module BAUD_RATE_GENERATOR(
    input  wire        clk,
    input  wire        rst,
    input  wire [11:0] div,
    output reg         bclk
);
    reg [11:0] counter;
    
    always@(posedge clk or negedge rst)
    begin
        if(!rst)
        counter<=0;
        else
        begin
            /*
            assuming div = 3
            clk pos edges(pulses)  : 1   2    3    4    5    6    7     8    9   10    11     12
            reset counter at div   : 1   2    3   (0)    1    2    3    (0)    1    2    3    (0)
            reset counter at div-1 : 1   2   (0)   1     2   (0)    1    2    (0)   1    2    (0)
            */
            /*
            assuming div = 12
            clk pos edges(pulses)  : 1   2    3    4    5    6    7     8    9   10    11     12     13
            reset counter at div   : 1   2    3    4    5    6    7     8    9   10    11     12     (0) 
            reset counter at div-1 : 1   2    3    4    5    6    7     8    9   10    11     (0)
            */
           //(0) stands for the high baud generator output
           //in previous case it'ld be better to set the output high at early stage 
            if(counter == (div-1))
            begin
                counter<=0;
                
            end
            else
            begin
                counter <= counter+1;
            end
        end
    end
    always@(*)
    begin
        if(counter==1)
         bclk = 1;
         else
         bclk = 0;
    end
endmodule