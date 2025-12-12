.globl check_print_cmd
.globl check_print_paren
.globl handle_print_stmt
.globl skip_spaces_print
.globl got_print_var

check_print_cmd:
    lb t2, 0(t1)           # Load char from print_str
    beqz t2, check_print_paren  # End of "print", check '('
    lb t3, 0(t0)           # Load char from input
    beqz t3, prefix_diff   # End of input = no match
    bne t2, t3, prefix_diff # Mismatch
    addi t0, t0, 1         # Advance input pointer
    addi t1, t1, 1         # Advance print_str pointer
    j check_print_cmd      # Continue comparison

check_print_paren:
    lb t3, 0(t0)           # Load next input char
    li t2, '('             # Check for '('
    bne t3, t2, prefix_diff # If not '(', no match
    addi t0, t0, 1         # Skip '('
    li a0, 0               # Match found
    ret

handle_print_stmt:
    # Skip "print("
    la t0, buffer
    addi t0, t0, 6         # Skip "print("
skip_spaces_print:
    lb t1, 0(t0)           # Load current char
    beqz t1, not_found     # End of input = error
    li t2, ' '             # Check for space
    bne t1, t2, got_print_var # If not space, stop skipping
    addi t0, t0, 1         # Skip space
    j skip_spaces_print    # Repeat

got_print_var:
    # Find variable
    mv a0, t0
    jal find_var
    beqz a0, not_found_var     # If variable not found, error

    # Print the matrix
    mv s0, a1              # Load matrix pointer

    # Print format
    li a0, '['
    li a7, 11              # Syscall for character output
    ecall
    li a0, '('
    li a7, 11
    ecall

    # Print first complex number
    flw fa0, 0(s0)         # Real part
    li a7, 2               # Syscall for float output
    ecall
    li a0, ','             # Separator
    li a7, 11
    ecall
    flw fa0, 4(s0)         # Imaginary part
    li a7, 2
    ecall

    li a0, ')'             # Close complex number
    li a7, 11
    ecall
    li a0, ','             # Separator
    li a7, 11
    ecall
    li a0, '('             # Start next complex number
    li a7, 11
    ecall

    # Print second complex number
    flw fa0, 8(s0)         # Real part
    li a7, 2
    ecall
    li a0, ','             # Separator
    li a7, 11
    ecall
    flw fa0, 12(s0)        # Imaginary part
    li a7, 2
    ecall
    li a0, ')'             # Close complex number
    li a7, 11
    ecall
    li a0, ']'             # Close matrix
    li a7, 11
    ecall

    # Print newline
    la a0, newline
    li a7, 4               # Syscall for string output
    ecall

    j input_loop

