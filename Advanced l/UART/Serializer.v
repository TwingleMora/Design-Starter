module serializer  #(
    parameter DATAWIDTH=8,PTRWIDTH=4
) (
    input clk,rst,
    input [DATAWIDTH-1:0] P_DATA,
    input Data_Valid,ser_en,
    output reg ser_data,ser_done
);
reg [DATAWIDTH-1:0]memory;
//reg out;
reg [PTRWIDTH-1:0] Ptr;
        always @(*) begin 
        ser_done = (Ptr[PTRWIDTH-1])&&(~(&(Ptr[PTRWIDTH-2:0])));
        end
        always @(posedge clk or negedge rst) begin
           if(!rst)
           begin
            Ptr<=0;
            ser_data<=0;
            memory<=0;
           end
           else
           begin
            if(Data_Valid&&!ser_en)//or just if(Data_Valid)  (i don't which one is appropriate to write here )
            begin
            memory<=P_DATA;
            end
            else if(ser_en)
            begin
             Ptr<=Ptr+1; 
            {ser_data,memory}<={ser_data,memory}<<1;
            end
            else
            Ptr<=0;
           end
        end
    
endmodule