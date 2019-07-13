nor $t0, $0, $0           # register t0 now holds -1 ("nor"-ing zero and zero is
                          # only way to initially store a number in a register
                          # using only r-type instructions)
srl $t1, $t0, 2           # register t1 should now hold 2^29 - 1
srl $t2, $t1, 3
srl $t3, $t2, 3
srl $t4, $t3, 5
