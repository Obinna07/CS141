# program to test jump types
# counts to ten
        addi $s0, $0, 5          # register $s0 should now hold integer 5
        addi $t1, $0, 0           # register $t1 should be initialized to zero
BEGIN:  bne $t1, $s0, SKIP
        j END
SKIP:   addi $t1, $t1, 1
        j BEGIN
END:    nop
