nor $t0, $0, $0           # register t0 now holds -1 ("nor"-ing zero and zero is
                          # only way to initially store a number in a register
                          # using only r-type instructions)
sra $t1, $t0, 2           # register t1 should still hold -1
sra $t7, $t1, 4           # register t7 should now also hold -1
sra $t4, $t7, 5           # register t4 should now also hold -1
sra $t1, $t4, 7           # register t1 should still hold -1
