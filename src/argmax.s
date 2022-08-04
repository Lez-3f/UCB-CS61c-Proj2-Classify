.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax:

    # Prologue
    li t0, 1
    blt a1, t0, length_error

    li t0, 0    # i = 0
    lw t1, 0(a0) # max = v[0] 

    li t3, 0    # max_i = 0
loop_start:
    lw t2, 0(a0)
    ble t2, t1, loop_continue   # v[i] <= max ? 
    add t1, t2, zero # max = v[i]
    add t3, t0, zero # max_i = i

loop_continue:
    addi a0, a0, 4
    addi t0, t0, 1
    beq t0, a1, loop_end
    j loop_start

loop_end:
    
    add a0, t3, zero
    # Epilogue

    ret

length_error:
    li a1, 7
    jal exit2