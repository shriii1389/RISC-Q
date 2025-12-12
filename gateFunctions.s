.globl quantum_gate

.text
quantum_gate:
        # Prologue
        addi sp, sp, -32
        sw ra, 28(sp) 
        sw s0, 24(sp) 
        sw s1, 20(sp) 
        sw s2, 16(sp) 
        sw s3, 12(sp)
        sw s4, 8(sp)
        sw s5, 4(sp)
        sw s6, 0(sp)
        
        # Load input parameters
        lw t4, 0(a0)            # Load qubitnum
        li t6, 1
        bne t4, t6, two_qubit   # Branch if not single qubit
        
        # Single qubit operations
        lw t5, 0(a1)            # Load Qgate
        
        # Gate selection logic
        H: li t1, 0             
           bne t5, t1, I
           la t0, Hgate
           j next
        I: li t1, 1             
           bne t5, t1, X
           la t0, Igate
           j next
        X: li t1, 2             
           bne t5, t1, Y
           la t0, Xgate
           j next
        Y: li t1, 3             
           bne t5, t1, Z
           la t0, Ygate
           j next
        Z: li t1, 4             
           bne t5, t1, S
           la t0, Zgate
           j next
        S: li t1, 5             
           bne t5, t1, T
           la t0, Sgate
           j next
        T: li t1, 6             
           bne t5, t1, SN
           la t0, Tgate
           j next
        SN: li t1, 7            
           bne t5, t1, quantum_exit
           la t0, SNgate
           j next

two_qubit: 
          la s0, qubit2                
          la s1, qubit3               
          la s3, tensor
          li t1, 2
          mv t2, t1
          
tensorprod: 
         flw ft0, 0(s0)     # Load values
         flw ft1, 4(s0)      
         flw ft2, 0(s1)      
         flw ft3, 4(s1)      

         # Compute products
         fmul.s ft4, ft0, ft2  
         fmul.s ft5, ft1, ft3  
         fmul.s ft6, ft0, ft3  
         fmul.s ft7, ft1, ft2  
         fsub.s ft8, ft4, ft5  
         fadd.s ft9, ft6, ft7  

         # Store results
         fsw ft8, 0(s3)
         fsw ft9, 4(s3)
         addi s3, s3, 8
         addi s1, s1, 8
         addi t1, t1, -1
         bgt t1, zero, tensorprod
         addi t2, t2, -1
         addi s0, s0, 8
         addi s1, s1, -16
         li t1, 2
         bgt t2, zero, tensorprod

         # Two-qubit gate selection
         lw t5, 0(a2)        
         CN1: li t1, 0           
            bne t5, t1, CN2
            la t0, CNgate1
            j next
         CN2: li t1, 1           
            bne t5, t1, CN3
            la t0, CNgate2
            j next
         CN3: li t1, 2           
            bne t5, t1, CN4
            la t0, CNgate3
            j next
         CN4: li t1, 3           
            bne t5, t1, SW1
            la t0, CNgate4
            j next
         
         SW1: li t1, 4           
            bne t5, t1, SW2
            la t0, SWgate1
            j next
         SW2: li t1, 5           
            bne t5, t1, SW3
            la t0, SWgate2
            j next
         SW3: li t1, 6           
            bne t5, t1, SW4
            la t0, SWgate3
            j next
         SW4: li t1, 7           
            bne t5, t1, CY1
            la t0, SWgate4
            j next
         
         CY1: li t1, 8           
            bne t5, t1, CY2
            la t0, CYgate1
            j next
         CY2: li t1, 9           
            bne t5, t1, CY3
            la t0, CYgate2
            j next
         CY3: li t1, 10           
            bne t5, t1, CY4
            la t0, CYgate3
            j next
         CY4: li t1, 11           
            bne t5, t1, CZ1
            la t0, CYgate4
            j next
         
         CZ1: li t1, 12           
            bne t5, t1, CZ2
            la t0, CZgate1
            j next
         CZ2: li t1, 13           
            bne t5, t1, CZ3
            la t0, CZgate2
            j next
         CZ3: li t1, 14           
            bne t5, t1, CZ4
            la t0, CZgate1
            j next
         CZ4: li t1, 15           
            bne t5, t1, quantum_exit
            la t0, CZgate1
            j next
         

next:   la t2, res
        la a6, row1
        beq t4, t6, next1
        la t2, res_2
        la a6, row1_2
next1:  lw t3, 0(a6)         
nextrow: fmv.s.x ft10, zero
         fmv.s.x ft11, zero
         la s2, col2 
         la t1, qubit1
         beq t4, t6, next2
         la s2, col2_2
         la t1, tensor
next2:  lw t5, 0(s2)         
nextcol: la s3, row2
         beq t4, t6, next3
         la s3, row2_2
next3:  lw s5, 0(s3)         
        mv s4, zero
        mv s7, zero
    
dotprod: flw ft0, 0(t0)       
         flw ft1, 4(t0)       
         flw ft2, 0(t1)       
         flw ft3, 4(t1)       
         fmul.s ft4, ft0, ft2  
         fmul.s ft5, ft1, ft3   
         fmul.s ft6, ft0, ft3  
         fmul.s ft7, ft1, ft2  
         fsub.s ft8, ft4, ft5  
         fadd.s ft9, ft6, ft7  
         fadd.s ft10, ft10, ft8 
         fadd.s ft11, ft11, ft9 
         addi t0, t0, 8
         slli s8, t5, 3
         add t1, t1, s8
         addi s5, s5, -1
         bne s5, zero, dotprod
         fsw ft10, 0(t2)      
         fsw ft11, 4(t2)
         addi t2, t2, 8        
       
         addi t5, t5, -1       
         beq t5, zero, skip
         slli s9, s5, 3        
         sub t0, t0, s9        

         mul s10, s9, t5      
         li s11, 8
         sub s5, s11, s10      
       
         add t1, t1, s5        
         j nextcol

skip:    addi t3, t3, -1
         bne t3, zero, nextrow 
        
copy_results:
         mv t2, a3             
         li s7, 4              
         beq t4, t6, copy_loop
         li s7, 8              

copy_loop:
         flw ft0, 0(t2)
         fsw ft0, 0(a3)        
         addi t2, t2, 4
         addi a3, a3, 4
         addi s7, s7, -1
         bne s7, zero, copy_loop

quantum_exit:
        # Epilogue
        lw s6, 0(sp)
        lw s5, 4(sp)
        lw s4, 8(sp)
        lw s3, 12(sp)
        lw s2, 16(sp)
        lw s1, 20(sp)
        lw s0, 24(sp)
        lw ra, 28(sp)
        addi sp, sp, 32
        ret
