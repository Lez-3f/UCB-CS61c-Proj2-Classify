.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot:

    # Prologue
    li t0, 1
    blt a2, t0, length_error #check if length < 1
    blt a3, t0, stride_error #check if stride < 1
    blt a4, t0, stride_error #check if stride < 1

    li t0, 0 # i = 0
    li t1, 0 # product = 0
    slli t4, a3, 2 # stide * 4
    slli t5, a4, 2 # stride * 4

loop_start:
    lw t2, 0(a0)
    lw t3, 0(a1)
    mul t2, t2, t3
    add t1, t1, t2
    
    addi t0, t0, 1
    beq t0, a2, loop_end
    add a0, a0, t4
    add a1, a1, t5
    j loop_start

loop_end:
    add a0, t1, zero

    # Epilogue

    
    ret
length_error:
    li a1, 5
    jal exit2
stride_error:
    li a1, 6
    jal exit2