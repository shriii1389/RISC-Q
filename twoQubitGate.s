.globl handle_qubitop2_stmt
.data
    CNgate1_str: .string "CN1"
    CNgate2_str: .string "CN2" 
    CNgate3_str: .string "CN3" 
    CNgate4_str: .string "CN4"
    
    SWgate1_str: .string "SW1"
    SWgate2_str: .string "SW2"
    SWgate3_str: .string "SW3"
    SWgate4_str: .string "SW4"
    
    CYgate1_str: .string "CY1" 
    CYgate2_str: .string "CY2" 
    CYgate3_str: .string "CY3" 
    CYgate4_str: .string "CY4" 
    
    CZgate1_str: .string "CZ1"
    CZgate2_str: .string "CZ2"
    CZgate3_str: .string "CZ3" 
    CZgate4_str: .string "CZ4" 
    
.text
handle_qubitop2_stmt:
    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)

    # Load buffer address
    la s0, buffer
    addi s0,s0, 8    # Skip "qubitop2" by searching for space
    
    skip_command_2:
    lb t1, 0(s0)
    li t0, ' '
    skip_leading_spaces:
        beq t1, t0, skip_leading_spaces_continue
        j syntaxError
    skip_leading_spaces_continue:
        addi s0, s0, 1
        lb t1, 0(s0)
        bne t1, t0, find_var_start_2
        j skip_leading_spaces

    find_var_start_2:
        # Skip any additional spaces
        addi s0, s0, 1
        lb t1, 0(s0)
        li t0, ' '
        beq t1, t0, find_var_start_2
        
        mv a0, s0          
        jal ra, find_var   
        beqz a0, parse_error
        mv s1, a1          

        addi s0, s0, 1

        find_equals_2:
            lb t1, 0(s0)
            li t0, '='
            skip_spaces_before_equals:
                beq t1, t0, found_equalss
                li t2, ' '
                bne t1, t2, syntaxError
                addi s0, s0, 1
                lb t1, 0(s0)
                j skip_spaces_before_equals
            found_equalss:
                addi s0, s0, 1
                j find_gate_2

        
        # Parse the gate type
        find_gate_2:
            # Skip whitespace
            lb t1, 0(s0)
            li t0, ' '
            bne t1,t0, check_gate_2
            addi s0, s0, 1
            j find_gate_2
    check_gate_2:
        # Save gate pointer
        mv s2, s0

        # Match gate strings
        la t0, CNgate1_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CN1_gate

        la t0, CNgate2_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CN2_gate

        la t0, CNgate3_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CN3_gate

        la t0, CNgate4_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CN4_gate

        la t0, SWgate1_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_SW1_gate

        la t0, SWgate2_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_SW2_gate

        la t0, SWgate3_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_SW3_gate

        la t0, SWgate4_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_SW4_gate

        la t0, CZgate1_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CZ1_gate

        la t0, CZgate2_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CZ2_gate

        la t0, CZgate3_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CZ3_gate

        la t0, CZgate4_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CZ4_gate

        la t0, CYgate1_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CY1_gate

        la t0, CYgate2_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CY2_gate

        la t0, CYgate3_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CY3_gate

        la t0, CYgate4_str
        mv t1, s2
        jal ra, starts_with
        beqz a0, set_CY4_gate

        j parse_error

    set_CN1_gate: 
        li s2, 0
        j find_first_var
    set_CN2_gate: 
        li s2, 1
        j find_first_var
    set_CN3_gate: 
        li s2, 2
        j find_first_var
    set_CN4_gate: 
        li s2, 3
        j find_first_var
    
    set_SW1_gate: 
        li s2, 4
        j find_first_var
    set_SW2_gate: 
        li s2, 5
        j find_first_var
    set_SW3_gate: 
        li s2, 6
        j find_first_var
    set_SW4_gate: 
        li s2, 7
        j find_first_var
    
    set_CY1_gate: 
        li s2, 8
        j find_first_var
    set_CY2_gate: 
        li s2, 9
        j find_first_var
    set_CY3_gate: 
        li s2, 10
        j find_first_var
    set_CY4_gate: 
        li s2, 11
        j find_first_var
    
    set_CZ1_gate: 
        li s2, 12
        j find_first_var
    set_CZ2_gate: 
        li s2, 13
        j find_first_var
    set_CZ3_gate: 
        li s2, 14
        j find_first_var
    set_CZ4_gate: 
        li s2, 15
        j find_first_var


    # Parse input variables (similar to earlier)
find_first_var:
    # Skip whitespace after gate name to find first variable
    skip_ws2_2:
        lb t1, 0(s0)
        li t0, ' '
        bne t1, t0, parse_first_var
        addi s0, s0, 1
        j skip_ws2_2

    parse_first_var:
        mv a0, s0      # Save the address of the first input variable
        jal ra, find_var
        beqz a0, parse_error_2
        mv s3, a1      # Save the address of the first input variable's value

    # Find comma between variables
    find_comma:
        lb t1, 0(s0)
        li t0, ','
        skip_spaces_before_comma:
            li t2, ' '
            beq t1, t0, found_comma
            bne t1, t2, syntaxError
            addi s0, s0, 1
            lb t1, 0(s0)
            j skip_spaces_before_comma
        found_comma:
            addi s0, s0, 1
        skip_spaces_after_comma:
            lb t1, 0(s0)
            li t2, ' '
            bne t1, t2, parse_second_var
            addi s0, s0, 1
            j skip_spaces_after_comma


    parse_second_var:
        mv a0, s0      # Save the address of the second input variable
        jal ra, find_var
        beqz a0, parse_error
        mv s4, a1      # Save the address of the second input variable's value
        j apply_two_qubit_gate

    # Apply two-qubit gate and store the result
apply_two_qubit_gate:
    # Prepare to call the quantum gate function
    la a0, qubitnum      
    li t0, 2

    sw t0, 0(a0)
    la a1, Qgate         
    
    sw s2, 0(a1)         
    mv a2, s2            
    
    la t0, qubit1        
    mv a3, t0

    # Store input qubits' values before calling
    la t0, qubit2
    lw t1, 0(s3)         
    sw t1, 0(t0)         
    lw t1, 4(s3)
    sw t1, 4(t0)
    
    la t0, qubit3
    lw t1, 0(s4)         
    sw t1, 0(t0)         
    lw t1, 4(s4)
    sw t1, 4(t0)

    jal ra, quantum_gate
    beqz a0, parse_error 
    j store_result


    # Store result and exit
store_result:
    # Load the result from the `res` array
    la t0, res_2         # Load the address of the result
    lw t1, 0(t0)         # First word of the result
    sw t1, 0(s1)         # Store the first word in the output variable
    lw t1, 4(t0)         # Second word of the result
    sw t1, 4(s1)         # Store the second word
    lw t1, 8(t0)         # Third word
    sw t1, 8(s1)         # Store the third word
    lw t1, 12(t0)        # Fourth word
    sw t1, 12(s1)        # Store the fourth word

    li a0, 0             # Success return value
    j parse_exit


    parse_error_2:
        li a0, -1           # Error return value

    parse_exit_2:
        # Epilogue
        lw ra, 28(sp)
        lw s0, 24(sp)
        lw s1, 20(sp)
        lw s2, 16(sp)
        lw s3, 12(sp)
        lw s4, 8(sp)
        addi sp, sp, 32
        ret
