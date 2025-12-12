.globl next_var
.globl not_found

find_var:
    la t0, symbol_table
    lb t1, 0(a0)          # Get first char of name we're looking for

find_loop:
    lw t2, 0(t0)          # Load stored name
    beqz t2, not_found    # If empty slot, we didn't find it
    
    bne t1, t2, next_var  # Compare first chars
    
    # Found it!
    lw a1, 4(t0)          # Get the storage address
    li a0, 1              # Return success
    ret

next_var:
    addi t0, t0, 8
    j find_loop

not_found:
    li a0, 0              # Return failure
    ret
