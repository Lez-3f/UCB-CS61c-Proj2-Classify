.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive an fopen error or eof, 
# this function exits with error code 50.
# If you receive an fread error or eof,
# this function exits with error code 51.
# If you receive an fclose error or eof,
# this function exits with error code 52.
# ==============================================================================
read_matrix:

    # Prologue
	addi sp, sp, -36
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2

    mv a1, s0
    li a2, 0    # read-only
    jal ra, fopen   

    li t0, -1
    beq a0, t0, fopen_error
    mv s3, a0 # file descriptor

    mv a1, s3
    mv a2, s1 # row num in M[s1]
    li a3, 4
    jal ra, fread
    li t0, 4
    bne t0, a0, fread_error

    mv a1, s3
    mv a2, s2 # col num in M[s2]
    li a3, 4
    jal ra, fread
    li t0, 4
    bne t0, a0, fread_error

    lw s1, 0(s1) # row num in s1
    lw s2, 0(s2) # col num in s2

    # allocate memory for matrix
    mul a0, s1, s2
    slli a0, a0, 2
    jal ra, malloc
    beq x0, a0, malloc_error
    mv s4, a0   # matrix in M[s4]

    # read in matrix 
    mul s5, s1, s2 # row * col
    li s6, 0
    mv s7, s4   # current data

loop_start:
    mv a1, s3
    mv a2, s7
    li a3, 4
    jal ra, fread
    li t0, 4
    bne t0, a0, fread_error
    addi s6, s6, 1
    beq s6, s5, loop_end
    addi s7, s7, 4
    j loop_start

loop_end:
    mv a1, s3
    jal ra, fclose
    li t0, -1
    beq t0, a0, fclose_error
    
    mv a0, s4 # return the matrix

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
	addi sp, sp, 36

    ret
malloc_error:
    li a1, 48
    jal exit2
fopen_error:
    li a1, 50
    jal exit2
fread_error:
    li a1, 51
    jal exit2
fclose_error:
    li a1, 52
    jal exit2