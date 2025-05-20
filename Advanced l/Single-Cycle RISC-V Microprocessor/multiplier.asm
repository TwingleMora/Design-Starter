    /*MULTIPLIER*/
    addi x1, x0, 10
    addi x2, x0, 5
    addi x3, x0, 0
    addi x4, x0, 0
    addi x5, x0, 0
    addi x6, x0, 0
    
    
    L1:addi x2, x2, -1 /* x2 = x2 - 1 */
    slt x4, x2, x0     /* x4 = x2 < 0 */
    add x3, x3, x1     /* x3 = x3 + x1*/
    beq x4, x0, L1     /* if ((x2>=0)) loop else if(x2<0) break  */
    sub x3, x3, x1     /* x3 = x3 - x1 */
    sw x3, 0(x5)
    lw x6, 0(x5)        
    addi x7, x0, 1     /* Exit Code */