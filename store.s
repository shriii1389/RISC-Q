
.globl store_var
.globl store_loop
.globl store_here

store_var:
    la t0, symbol_table

store_loop:
    lw t1, 0(t0)          # Check if this slot is empty
    beqz t1, store_here   # If empty (0), use this slot
    addi t0, t0, 8        # Else try next slot
    j store_loop

store_here:
    lb t1, 0(a0)          # Load first character of name
    sw t1, 0(t0)          # Store the name (like "a")
    sw a1, 4(t0)          # Store address where data will be
    ret