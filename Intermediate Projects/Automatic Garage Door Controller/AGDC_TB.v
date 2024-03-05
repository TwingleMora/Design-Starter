module AGDC_TB;
 reg UP_Max,DN_Max,Activate,CLK,RST;
 wire UP_M,DN_M;

AGDC Auto_Garage_Door( //Automatic Garage Door Controller
    .UP_Max(UP_Max),.DN_Max(DN_Max),.Activate(Activate),.CLK(CLK),.RST(RST),
    .UP_M(UP_M),.DN_M(DN_M)
);
always #5 CLK=~CLK;
integer prev_state;
task initialize;
begin
CLK=0;
RST=0;//state is IDLE
@(negedge CLK)
RST=1; 
$display("Resetting...");
$display("Now Current State Is: %0d\n",Auto_Garage_Door.Current);
end
endtask

task Sensors_Activate;
reg [5:0] activates;//= 6'b000000;  
reg [5:0] max_ups;// =  6'b000001;
reg [5:0] max_dns;// =  6'b000000;
integer counter;
begin
activates = 6'b010101;  
max_ups =   6'b011001;
max_dns =   6'b100110;


 @(negedge CLK)
    for(counter=0;counter<6;counter=counter+1)
    begin
        prev_state = Auto_Garage_Door.Current;
        UP_Max=max_ups[counter];
        DN_Max=max_dns[counter];
        Activate=activates[counter];
        #10
        $display("State Changes From %0d To %0d When[ Up_Max: %b, Dn_Max: %b, Activate: %b ] ",prev_state,Auto_Garage_Door.Current,UP_Max,DN_Max,Activate);
        $display("UP_Mator: %b, DN_Mator: %b",UP_M,DN_M);
        if(!(Auto_Garage_Door.Current)&&prev_state==1)
         $display("The Door Is Closed");
        else if(!(Auto_Garage_Door.Current)&&prev_state==2)
         $display("The Door Is Open");
         $display("\n");
    end
end
endtask

initial
begin
    $display("State 0: IDLE , State 1: Move Down , State 2: Move Up \n");
initialize;
Sensors_Activate;
$stop;
end
endmodule
