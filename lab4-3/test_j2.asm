# program to test jump types
# counts to ten

      addi $s0, $0, 10          # register $s0 should now hold integer 10
      addi $t1, $0, 0           # register $t1 should be intialized to zero
      addi $t2, $0, 0
      j BEGIN
LOOP  addi #t1, $t1, 1
BEGIN bne $t0, $s0, SKIP
      j END
SKIP  addi $t2, $t2, 1
      j LOOP
END   nop
