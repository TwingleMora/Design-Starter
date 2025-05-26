module ClkDiv(

    input wire       i_ref_clk,
    input wire       i_rst_n,
    input wire       i_clk_en,
    input wire [7:0] i_div_ratio,
    
    output reg       o_div_clk

);

wire CLK_DIV_EN;
wire [7:0] max_steps;
reg [7:0] counter;
reg [7:0] counter_next;
assign max_steps = i_div_ratio[0]==0?(i_div_ratio>>1)-1:(((i_div_ratio-1)>>1)-1);
assign CLK_DIV_EN = i_clk_en &&  (i_div_ratio!=0) && (i_div_ratio!=1);
reg first_stage_ff;
always@(*)
begin
if(CLK_DIV_EN)
    begin
        counter_next=counter+1;

        if(i_div_ratio[0]==0)//even
        begin
            if(counter==max_steps)
                begin
                    counter_next=0;
                end
        end
        else if(i_div_ratio[0]==1)//odd
            begin
                /*priorities*/
                if(max_steps)
                begin
                    if(!o_div_clk&&first_stage_ff) // it has the greatest priority as counter may == max_steps
                        begin
                            counter_next=1;
                            
                        end
                    else if(counter==max_steps)
                        begin
                            counter_next=0;
                        end
                end
            
                else
                begin
                if(counter==max_steps)
                    begin
                        counter_next=0;
                    end 
                end

            end
    end
end
reg comb;
always@(posedge i_ref_clk or negedge i_rst_n)
begin
    if(!i_rst_n)
    begin
        o_div_clk<=0;
        first_stage_ff<=1;//1 or 0 doesn't really matter 
        counter<=0;

    end
    else 
    begin
        counter<=counter_next;
        if(CLK_DIV_EN)
        begin
                if(i_div_ratio[0]==0)//even
                begin
                    if(counter==0)
                    begin
                        o_div_clk <= ~ o_div_clk;
                    end
                end
                else//odd **********************
                begin 
                    // [l][h]  [l][l]  [l][l]   [l][l]   [h][l]   [h][h]     [][]    [][]
                    //   0        1      2        3        0        1         2       3       0    
                    /*
                        if(counter==0)
                        begin
                        //last    <=~1  <=0
                        first_stage_ff<=~o_div_clk;//(1->0)(0->1)
                        //                              f  o
                        //                             [0][1]   c:0  shift to f with not
                        //                             [0][0]   c:1

                        //                             [1][0]   c:0
                        //                             [1][1]   c:1 //shift to o with no not

                        //                             [0][1]   c:0
                        //counter<=0;
                        end
                    */
                        if(o_div_clk)//high
                        begin
                            if(counter==0)
                            begin
                            o_div_clk<=~o_div_clk; 
                            first_stage_ff<=~o_div_clk; 
                            end               
                        end
                        else//low
                        begin
                            if(counter==0)
                            begin
                                first_stage_ff<=~o_div_clk; 
                            end
                        //counter<=0;  
                            o_div_clk<=first_stage_ff;
                        //counter<=counter;
                        end
                    end
        end
    end
end

endmodule


/*
 LATCH:
always@(en or d or rst)
begin
    if(!rst)
    begin
        q<=0;
    end
    else
    begin
        if(en)
        begin
            q<=d
        end
    end
end
*/