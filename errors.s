.globl not_found_var
.globl syntaxError
.globl VariableNotDeclared
syntaxError:
    la a0, err_syntax
    li a7, 4
    ecall
    j input_loop


not_found_var:
    # Error: Variable not found
    la a0, err_var
    li a7, 4               # Syscall for string output
    ecall
    j input_loop

VariableNotDeclared:
    la a0, err_undeclared
    li a7, 4
    ecall
    j input_loop
