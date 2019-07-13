# tests for store word instructions

addi $t0, $0, 10              # register t0 now contains integer 10
addi $t1, $0, 13              # register t1 should now contain integer 13
addi $t2, $0, -16             # register t2 should now contain integer -16
addi $s0, $0, 16
sw $t0, 16($s0)               # memory located at 16($s0) should now contain integer 10
sw $t1, 20($s0)               # memory located at 20($s0) should now contain integer 13
sw $t2, 24($s0)               # memory located at 24($s0) should now contain integer -16

###################### Now to check if memory was stored correctly:

lw $t3, 16($s0)               # register t3 should now contain integer 10
lw $t4, 20($s0)               # register t4 should now contain integer 13
lw $t5, 24($s0)               # register t5 should now contain integer -16

###################### Overwriting memory:

sub $s1, $zero, $t5
sw $s1, 24($s0)
lw $t6, 24($s0)               # register t3 should now contain integer +16
