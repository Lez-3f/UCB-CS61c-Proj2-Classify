.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul:

    # Error checks
    li t0, 1
    blt a1, t0, m0_dim_error
    blt a2, t0, m0_dim_error
    blt a4, t0, m1_dim_error
    blt a5, t0, m1_dim_error
    bne a2, a4, dim_match_error

    # Prologue
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)
    # register not enough
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    mv s5, a5
    mv s6, a6

    # for debug begin
    mv a1, s1
    jal print_int

    li a1, 'x'
    jal print_char

    mv a1, s2
    jal print_int

    li a1, '|'
    jal print_char

    mv a1, s4
    jal print_int

    li a1, 'x'
    jal print_char

    mv a1, s5
    jal print_int

    li a1, '\n'
    jal print_char
    # for debug end

    li t0, 0    # i = 0 not correct
    li s7, 0
    
outer_loop_start:

    # li t1, 0    # j = 0 not correct
    li s8, 0

inner_loop_start:

    # li a1 'i'
    # jal ra print_char
    # li a1 '='
    # jal ra print_char
    # mv a1, s7
    # jal ra,  print_int
    #     li a1 ' '
    # jal ra print_char
    # li a1 'j'
    # jal ra print_char
    # li a1 '='
    # jal ra,  print_char
    # mv a1, s8
    # jal ra,  print_int
    #     li a1 ' '
    # jal ra print_char
    # li a1 'k'
    # jal ra print_char
    # li a1 '='
    # jal ra,  print_char
    # mv a1, s2
    # jal ra,  print_int
    # li a1 '\n'
    # jal ra print_char

    slli t2, s2, 2 # col0 * 4
    mul t2, t2, s7 # col0 * 4  * i
    add a0, s0, t2 # m0 + col0 * 4 * i

    slli t2, s8, 2 # j * 4
    add a1, s3, t2 # m1 + j * 4

    mv a2, s2 # length of vector dotted

    li a3, 1

    mv a4, s5

    # test start
    # mv s0, a1

    # lw a1, 0(a0)
    # jal ra, print_int

    #     li a1, ' '
    # jal ra, print_char

    # lw a1, 0(s0)
    # jal ra, print_int

    #     li a1, ' '
    # jal ra, print_char

    # add a1, zero, a2
    # jal ra, print_int

    #     li a1, ' '
    # jal ra, print_char

    # add a1, zero, a3
    # jal ra, print_int

    #     li a1, ' '
    # jal ra, print_char

    # add a1, zero, a4
    # jal ra, print_int

    # li a1, '\n'
    # jal ra, print_char

    # add a1, zero, t0
    # test end

    jal ra, dot

    sw a0, 0(s6)

    addi s6, s6, 4 # d[i][j] = dot(., .)
    addi s8, s8, 1 # j = j + 1

    # li a1 '-'
    # jal ra print_char
    # li a1 'i'
    # jal ra print_char
    # li a1 '='
    # jal ra print_char
    # mv a1, s7
    # jal ra,  print_int
    # li a1 ' '
    # jal ra print_char
    # li a1 'j'
    # jal ra print_char
    # li a1 '='
    # jal ra,  print_char
    # mv a1, s8
    # jal ra,  print_int
    # li a1 '\n'
    # jal ra print_char

    blt s8, s5, inner_loop_start # j < col2, loop continue 

inner_loop_end:

    addi s7, s7, 1 # i = i + 1
    blt s7, s1, outer_loop_start

outer_loop_end:


    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 32
    
    ret

m0_dim_error:
    li a1, 2
    jal exit2
m1_dim_error:
    li a1, 3
    jal exit2
dim_match_error:
    li a1, 4
    jal exit2