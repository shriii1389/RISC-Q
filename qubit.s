.globl handle_qubit_decl
.globl got_var_start
.globl new_variable
.globl found_equals
.globl parse_numbers
.globl update_storage
.globl parse_float
.globl done_parse

handle_qubit_decl:
    # Skip "qubit" and spaces
    la t0, buffer
    addi t0, t0, 5  # Skip "qubit"
    
    # Skip spaces to variable name
    skip_spaces_1:
        lb t1, 0(t0)
        li t2, ' '
        bne t1, t2, got_var_start
        addi t0, t0, 1
        j skip_spaces_1
got_var_start:
    # Save variable name pointer and current position
    mv s0, t0       # Save name pointer
    
    # Check if variable already exists
    mv a0, s0
    jal find_var
    beqz a0, new_variable    # If not found (a0 = 0), create new variable
    
    # Variable exists, use existing location in a1
    mv t3, a1
    j find_equals    # Skip storage allocation, use existing location

new_variable:
    # Store new variable in symbol table
    mv a0, s0          # Variable name
    mv a1, s11         # Current storage location
    jal store_var
    mv t3, s11         # Save storage location for later
            
find_equals:
    lb t1, 0(t0)
    li t2, '='
    beq t1, t2, found_equals
    addi t0, t0, 1
    j find_equals

found_equals:
    # Skip equals and spaces
    addi t0, t0, 1
skip_spaces_2:
    lb t1, 0(t0)
    li t2, ' '
    bne t1, t2, find_bracket
    addi t0, t0, 1
    j skip_spaces_2    
    
find_bracket:
    # Skip to opening '['
    lb t1, 0(t0)
    li t2, '['
    bne t1, t2, find_bracket_next
    j parse_numbers
find_bracket_next:
    addi t0, t0, 1
    j find_bracket
    
parse_numbers:
    # Skip '[' and '('
    addi t0, t0, 2
    
    # Parse first number (1)
    mv a0, t0
    jal parse_float
    mv t0, a1
    
    # Store first number
    fsw f0, 0(t3)
    
    # Skip comma
    addi t0, t0, 1
    
    # Parse second number (0)
    mv a0, t0
    jal parse_float
    mv t0, a1
    fsw f0, 4(t3)
    
    # Skip ),( - three characters
    addi t0, t0, 3
    
    # Parse third number (0)
    mv a0, t0
    jal parse_float
    mv t0, a1
    fsw f0, 8(t3)
    
    # Skip comma
    addi t0, t0, 1
    
    # Parse fourth number (1)
    mv a0, t0
    jal parse_float
    mv t0, a1
    fsw f0, 12(t3)
    
    # Only update storage pointer for new variables
    beq t3, s11, update_storage
    j input_loop

update_storage:
    addi s11, s11, 16
    j input_loop

parse_float:
    # Save return address
    addi sp, sp, -4
    sw ra, 0(sp)
    
    mv t4, a0          # Save string pointer
    li t5, 0          # Integer part
    li t6, 0          # Decimal part
    li s2, 0          # Decimal position
    li s3, 0          # Is negative
    
    # Check for negative sign
    lb t1, 0(t4)
    li t2, '-'
    bne t1, t2, parse_int_part
    li s3, 1
    addi t4, t4, 1
    
	parse_int_part:
	    lb t1, 0(t4)
	    li t2, '.'
	    beq t1, t2, parse_decimal
	    li t2, ','
	    beq t1, t2, finish_parse
	    li t2, ')'
	    beq t1, t2, finish_parse
	    
	    # Convert char to int and add to total
	    addi t1, t1, -48   # ASCII to int
	    li t2, 10
	    mul t5, t5, t2
	    add t5, t5, t1
	    
	    addi t4, t4, 1
	    j parse_int_part
	    
	parse_decimal:
	    addi t4, t4, 1     # Skip decimal point
	    
	parse_decimal_part:
	    lb t1, 0(t4)
	    li t2, ','
	    beq t1, t2, finish_parse
	    li t2, ')'
	    beq t1, t2, finish_parse
	    
	    # Convert char to int and add to decimal
	    addi t1, t1, -48   # ASCII to int
	    li t2, 10
	    mul t6, t6, t2
	    add t6, t6, t1
	    addi s2, s2, 1     # Increment decimal position
	    
	    addi t4, t4, 1
	    j parse_decimal_part
    
	finish_parse:
	    # Convert to float
	    fcvt.s.w f0, t5    # Convert integer part
	    
	    # If we have decimal part
	    beqz t6, check_negative
	    
	    # Convert decimal part
	    fcvt.s.w f1, t6
	    li t1, 1
	    li t2, 10
	decimal_divide_loop:
	    beqz s2, combine_parts
	    mul t1, t1, t2
	    addi s2, s2, -1
	    j decimal_divide_loop
	    
	combine_parts:
	    fcvt.s.w f2, t1
	    fdiv.s f1, f1, f2
	    fadd.s f0, f0, f1
	    
	check_negative:
	    beqz s3, done_parse
	    fneg.s f0, f0
	    
done_parse:
    # Return new position in a1
    mv a1, t4
    
    # Restore return address
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
