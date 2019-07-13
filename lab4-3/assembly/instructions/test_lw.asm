# tests for load word instructions

addi $t0, $0, 10                # register t0 now contains integer 10

sw $t0, 16($zero)               # store integer into the memory address offset
                                # by 16 from the zero register address

lw $t1, 16($zero)               # register t1 should now contain integer 10

lw $t2, 16($zero)               # register t2 should now also contain integer 10
