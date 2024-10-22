/*DIVIDER*/
    addi x1, x0, 10
    addi x2, x0, 2
    addi x3, x0, 0
    addi x4, x0, 0
    addi x5, x0, 0
    addi x6, x0, 0
    /* x3 = 5 x 10 */
    L1:
    sub x1,x1,x2 /* x1 = x1-x2*/
    /*x1<0 */
    /*if(!(x1<=0))*/
    slt x4,x1,x0 /*x1<0 => 1, x1>0 => 1*/
    addi x4,x4,-1 /*x1<0 => 1-1 = 0, x1>0 => 0-1 = -1*/
    
   
    
    beq x4,x0,EXIT /* EXIT if x1<0 */
    addi x3,x3,1 /* else x3 = x3 + 1*/
    
    jal x0, L1 /*jump to L1*/
    EXIT:
    sw x3,0(x5) /* store the result at 0x0 in data memory */
    lw x6,0(x5) /* load the result from 0x0 and assign it to x6 register*/
    addi x7,x0,1 /* Exit Code */