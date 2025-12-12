.globl handle_qubitop1_stmt
.data
    Hgate_str: .string "H"
    Igate_str: .string "I"
    Xgate_str: .string "X"
    Ygate_str: .string "Y"
    Zgate_str: .string "Z"
    Sgate_str: .string "S"
    Tgate_str: .string "T"
    SNgate_str: .string "SN"
    arrow_str: .string "->"
    space_str: .string " "
    equals_str: .string "="
    
.text
handle_qubitop1_stmt:
    # Prologue
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    
    # Load buffer address directly into s0
    la s0, buffer
    
    # Skip "qubitop1" by searching for space
    skip_command_1:
        lb t1, 0(s0)
        li t0, ' '
        beq t1, t0, find_var_start_1
        addi s0, s0, 1
        j skip_command_1

    find_var_start_1:
        # Skip any additional spaces
        addi s0, s0, 1
        lb t1, 0(s0)
        li t0, ' '
        beq t1, t0, find_var_start_1
        
    # Look up variable in symbol table
    mv a0, s0      # Move current buffer position to a0
    jal ra, find_var  # Call with proper link register
    beqz a0, parse_error  # Changed to parse_error instead of VariableNotDeclared
    mv s1, a1      # Save variable address
        
    # Skip variable name
    addi s0, s0, 1
    
    find_equals_1:
        lb t1, 0(s0)
        li t0, '='
        bne t1, t0, skip_ws1_1
        addi s0, s0, 1
        j find_gate_1
        
    skip_ws1_1:
        addi s0, s0, 1
        j find_equals_1
            
    find_gate_1:
        # Skip whitespace
        lb t1, 0(s0)
        li t0, ' '
        bne t1, t0, check_gate_1
        addi s0, s0, 1
        j find_gate_1
            
    check_gate_1:
        # Store gate pointer
        mv s2, s0
            
        # Check against each gate string
        la t0, Hgate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_h_gate
            
        la t0, Igate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_i_gate
        
        la t0, Xgate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_x_gate
        
        la t0, Ygate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_y_gate
        
        la t0, Zgate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_z_gate
        
        la t0, Sgate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_s_gate
        
        la t0, Tgate_str
        mv t1, s2
        jal ra, starts_with_char1  
        beqz a0, set_t_gate
        
        la t0, SNgate_str
        mv t1, s2
        jal ra, starts_with  
        beqz a0, set_sn_gate
        
        # Invalid gate
        j parse_error
        
    set_h_gate:
        li s2, 0
        j find_arrow
    set_i_gate:
        li s2, 1
        j find_arrow
    set_x_gate:
        li s2, 2
        j find_arrow
    set_y_gate:
        li s2, 3
        j find_arrow
    set_z_gate:
        li s2, 4
        j find_arrow
    set_s_gate:
        li s2, 5
        j find_arrow
    set_t_gate:
        li s2, 6
        j find_arrow
    set_sn_gate:
        li s2, 7
        j find_arrow
    
find_arrow:
    lb t1, 0(s0)
    li t0, '-'
    beq t1, t0, check_arrow
    addi s0, s0, 1
    j find_arrow
    
    check_arrow:
        lb t1, 1(s0)
        li t0, '>'
        bne t1, t0, parse_error
        
        addi s0, s0, 2
    skip_ws2:
        lb t1, 0(s0)
        li t0, ' '
        bne t1, t0, find_target_qubit
        addi s0, s0, 1
        j skip_ws2
    
find_target_qubit:
    mv a0, s0
    jal ra, find_var  # Added ra to jal
    beqz a0, parse_error
    
    # Set up quantum_gate call
    la a0, qubitnum
    la a1, Qgate
    sw s2, 0(a1)
    la a2, Qgate_2
    mv a3, s1          # Use saved variable address
    
    jal ra, quantum_gate  
    
# After quantum_gate call, store result in the variable
    la t0, res         # Load address of result
    lw t1, 0(t0)      # Load first word of result
    sw t1, 0(s1)      # Store first word to variable
    lw t1, 4(t0)      # Load second word
    sw t1, 4(s1)      # Store second word
    lw t1, 8(t0)      # Load third word
    sw t1, 8(s1)      # Store third word
    lw t1, 12(t0)     # Load fourth word
    sw t1, 12(s1)     # Store fourth word

    li a0, 0           # Success return value
    j parse_exit
    
parse_error:
    li a0, -1
    
parse_exit:
    # Epilogue
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    addi sp, sp, 32
    ret
