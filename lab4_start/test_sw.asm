# tests for store word instructions

addi $t0, $0, 10              # register t0 now contains integer 10

addi $t1, $0, 13              # register t1 should now contain integer 13

addi $t2, $0, -16             # register t2 should now contain integer -16

sw $t0, 16($s0)               # memory located at 16($s0) should now contain
                              # integer 10

sw $t1, 19($s0)               # memory located at 19($s0) should now contain
                              # integer 13

sw $t2, 22($s0)               # memory located at 22($s0) should now contain
                              # integer -16

###################### Now to check if memory was stored correctly:

lw $t3, 16($s0)               # register t3 should now contain integer 10

lw $t4, 19($s0)               # register t4 should now contain integer 13

lw $t5, 22($s0)               # register t5 should now contain integer -16

###################### Corner Cases:

sw $t3, 23($s0)               # memory located at 23($s0) should now contain
                              # integer 10

sw $t4, 23($s0)               # memory located at 23($s0) should now contain
                              # integer 13

sw $t5, 23($s0)               # memory located at 23($s0) should now contain
                              # integer -16

lw $t3, 23($s0)               # register t3 should now contain integer -16
