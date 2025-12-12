.globl starts_with
.globl prefix_match
.globl prefix_diff
.globl starts_with_char1
starts_with:
    lb t2, 0(t1)    
    beqz t2, prefix_match  
    lb t3, 0(t0)    
    beqz t3, prefix_diff   
    bne t2, t3, prefix_diff
    addi t0, t0, 1
    addi t1, t1, 1
    j starts_with

starts_with_char1:
    lb t2, 0(t1)    
    lb t3, 0(t0)    
    beq t2, t3, prefix_match
    j prefix_diff

prefix_match:
    li a0, 0        
    ret
    
prefix_diff:
    li a0, 1        
    ret    


