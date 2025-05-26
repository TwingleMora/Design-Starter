`timescale 1ns/1ps
module ClkDivTB;

     //////////////////////////////////
    //////////////////////////////////
   ///////////    I     /////////////
  ///////////     O    /////////////
 //////////////////////////////////
//////////////////////////////////
    reg       i_ref_clk;
    reg       i_rst_n;
    reg       i_clk_en;
    //reg [7:0] i_div_ratio;
    
    wire       div2;
    wire       div3;
    wire       div4;
    wire       div5;
    wire       div6;


      //////////////////////////////////
     //////////////////////////////////
    ///////////          /////////////
   ///////////   DUT    /////////////
  ///////////          /////////////
 //////////////////////////////////
//////////////////////////////////
ClkDiv CDIV2(

    .i_ref_clk(i_ref_clk),
    .i_rst_n(i_rst_n),
    .i_clk_en(i_clk_en),
    .i_div_ratio(8'd2),
    .o_div_clk(div2)
);
ClkDiv CDIV3(

    .i_ref_clk(i_ref_clk),
    .i_rst_n(i_rst_n),
    .i_clk_en(i_clk_en),
    .i_div_ratio(8'd3),
    .o_div_clk(div3)

);
ClkDiv CDIV4(

    .i_ref_clk(i_ref_clk),
    .i_rst_n(i_rst_n),
    .i_clk_en(i_clk_en),
    .i_div_ratio(8'd4),
    .o_div_clk(div4)

);
ClkDiv CDIV5(

    .i_ref_clk(i_ref_clk),
    .i_rst_n(i_rst_n),
    .i_clk_en(i_clk_en),
    .i_div_ratio(8'd5),
    .o_div_clk(div5)

);
ClkDiv CDIV6(

    .i_ref_clk(i_ref_clk),
    .i_rst_n(i_rst_n),
    .i_clk_en(i_clk_en),
    .i_div_ratio(8'd6),
    .o_div_clk(div6)

);

localparam period =60;
localparam hp = period/2;

          ////////////////////////////////////////
         ////////////////////////////////////////
        ///////////    CLOCK       /////////////
       ///////////   GENERATION   /////////////
      ////////////////////////////////////////
     ////////////////////////////////////////
always #(hp) i_ref_clk = ~i_ref_clk;


          ////////////////////////////////////////
         ////////////////////////////////////////
        ///////////     EXPECTED   /////////////
       ///////////      OUTPUTS   /////////////
      ////////////////////////////////////////
     ////////////////////////////////////////
reg exp_div2=0,exp_div3=0,exp_div4=0,exp_div5=0,exp_div6=0;
initial
begin 
    @(posedge i_ref_clk);
    exp_div2=1;
    exp_div3=1;
    exp_div4=1;
    exp_div5=1;
    exp_div6=1;
end
initial
begin
    @(posedge i_ref_clk);
    fork
        
    forever begin
        #(hp*2) exp_div2= ~exp_div2;
      //#(hp*2) exp_div2= ~exp_div2; (optional)
    end

    forever begin
        
        #(hp*2) exp_div3= ~exp_div3;
        #(hp*2 + hp*2) exp_div3= ~exp_div3;
    end

    forever begin
        
        #(hp*4) exp_div4= ~exp_div4;
      //#(hp*4) exp_div4= ~exp_div4; (optional)
    end 

    forever begin
        
        #(hp*4) exp_div5= ~exp_div5;
        #(hp*4 + hp*2) exp_div5= ~exp_div5;
    end 

    forever begin
        
        #(hp*6) exp_div6= ~exp_div6;
      //#(hp*6) exp_div6= ~exp_div6; (optional)
    end 

    join
    $display("");
end



                 //////////////////////////////////////////
                //////////////////////////////////////////
               ////////////               ///////////////
  ////////////////////////   Initial     //////////////////////////////
 ////////////////////////               //////////////////////////////
////////////////////////     Block     //////////////////////////////
           ////////////               ///////////////
          //////////////////////////////////////////
         //////////////////////////////////////////
integer test_result=1;
initial
begin
    i_rst_n = 0;
    #(i_rst_n/100) i_rst_n =1;
    i_ref_clk=0;

    i_clk_en=1;

    repeat(12)
    begin
        @(negedge i_ref_clk);
        if(div2 != exp_div2)
        begin
            test_result=0;
            $display("Div2 Failed!");
        end
        else
            $display("Div2 Clock Matches The Expected Output");

        if(div3 != exp_div3)
        begin
            test_result=0;
            $display("Div3 Failed!");
        end
        else
            $display("Div3 Clock Matches The Expected Output");

        if(div4 != exp_div4)
        begin
            test_result=0;
            $display("Div4 Failed!");
        end
        else
            $display("Div4 Clock Matches The Expected Output");

        if(div5 != exp_div5)
        begin
            test_result=0;
            $display("Div5 Failed!");
        end
        else
            $display("Div5 Clock Matches The Expected Output");

        if(div6 != exp_div6)
        begin
            test_result=0;
            $display("Div6 Failed!");
        end
        else
            $display("Div6 Clock Matches The Expected Output");

    end
    if(test_result)
    $display("Clock Divider Operate Fine at all Dividing Ratios");
    else
    $display("Clock Divider Failed!");
    $stop;
end

endmodule