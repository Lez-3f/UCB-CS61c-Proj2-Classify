.globl classify

.data
load_matrix_done: .asciiz "load matrix done\n"
cal_hd_done: .asciiz "cal hidden layer done\n"
run_layer_done: .asciiz "run layer done\n"
write_matrix_done: .asciiz "write matrix done\n"

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    li t0, 5
    bne t0, a0, argc_error

    # prologue
    addi sp, sp, -52
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)

    mv s0, a0   # argc
    mv s1, a1   # argv
    mv s2, a2   # print_flag
    mv a1, s2

	# =====================================
    # LOAD MATRICES
    # ====================================

    # Load pretrained m0

    li a0, 8
    jal ra, malloc
    beq x0, a0, malloc_error    # malloc error

    mv s3, a0   # --> row0, col0
    mv a1, s3   # row loc
    addi a2, s3, 4  # col loc

    lw a0, 4(s1)    # file_name argv[1]
    jal ra, read_matrix
    mv s4, a0 # --> mat0


    # Load pretrained m1

    li a0, 8
    jal ra, malloc
    beq x0, a0, malloc_error    # malloc error

    mv s5, a0   # --> row1, col1
    mv a1, s5   # row loc
    addi a2, s5, 4  # col loc

    lw a0, 8(s1)    # file_name argv[2]
    jal ra, read_matrix
    mv s6, a0 # --> mat1

    # Load input matrix

    li a0, 8
    jal ra, malloc
    beq x0, a0, malloc_error    # malloc error

    mv s7, a0   # --> row_i, col_i
    mv a1, s7   # row loc
    addi a2, s7, 4  # col loc

    lw a0, 12(s1)    # file_name argv[3]
    jal ra, read_matrix
    mv s8, a0 # --> mat_i

    # for debug begin
    la a1, load_matrix_done
    jal ra, print_str
    # for debug end

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    lw t0, 0(s3)
    lw t1, 4(s7)
    mul a0, t0, t1
    slli a0, a0, 2
    jal ra, malloc
    beq x0, a0, malloc_error
    mv s9, a0   # hidden layer

    mv a0, s4
    lw a1, 0(s3)
    lw a2, 4(s3)

    mv a3, s8
    lw a4, 0(s7)
    lw a5, 4(s7)

    mv a6, s9
    jal ra, matmul  # m0 * input

    # for debug begin
    # mv a0, s9
    # li a1, 3
    # li a2, 1
    # jal ra, print_int_array
    la a1, cal_hd_done
    jal ra, print_str
    # for debug end

    mv a0, s9
    lw t0, 0(s3)
    lw t1, 4(s7)
    mul a1, t0, t1
    jal ra, relu    # relu (m0 * input)

    # for debug begin
    la a1, cal_hd_done
    jal ra, print_str
    # for debug end

    lw t0, 0(s5)
    lw t1, 4(s7)
    mul a0, t0, t1
    slli a0, a0, 2
    jal ra, malloc
    beq x0, a0, malloc_error
    mv s10, a0   # output layer

    # # for debug begin
    # lw a1, 0(s5)
    # jal print_int
    # li a1, ' '
    # jal print_char
    # lw a1, 4(s5)
    # jal print_int
    #     li a1, ' '
    # jal print_char
    # lw a1, 0(s3)
    # jal print_int
    #     li a1, ' '
    # jal print_char
    # lw a1, 4(s7)
    # jal print_int
    #     li a1, '\n'
    # jal print_char
    # # for debug end

    mv a0, s6
    lw a1, 0(s5)
    lw a2, 4(s5)

    mv a3, s9
    lw a4, 0(s3)
    lw a5, 4(s7)

    mv a6, s10
    jal ra, matmul  # m1 * relu (m0 * input)

    # for debug begin
    la a1, run_layer_done
    jal ra, print_str
    # for debug end


    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

	lw a0, 16(s1) # argv[4]
    mv a1, s10
    lw a2, 0(s5)
    lw a3, 4(s7)
    jal ra, write_matrix

    # for debug begin
    la a1, write_matrix_done
    jal ra, print_str
    # for debug end

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    mv a0, s10
    lw t0, 0(s5)
    lw t1, 4(s7)
    mul a1, t0, t1
    jal ra, argmax
    mv s11, a0  # classificatiion

    bne s2, x0, not_print
    # Print classification
    mv a1, s11
    jal ra, print_int

    # Print newline afterwards for clarity
    li a1, '\n'
    jal ra, print_char

    bne s1, x0, not_print
    
not_print:
	# free the space
	mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    
    # return classification
    mv a0, s10 

    # epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 52

    ret

malloc_error:
    li a1, 48
    jal exit2
argc_error:
    li a1, 49
    jal exit2