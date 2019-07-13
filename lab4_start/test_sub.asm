nor $t0, $0, $0           # register t0 now holds -1 ("nor"-ing zero and zero is
                          # only way to initially store a number in a register
                          # using only r-type instructions)
add $t1, $t0, $t0         # register t1 now holds -2
add $t2, $t1, $t0         # register t2 now holds -3
add $t3, $t2, $t0         # register t3 now holds -4

sub $t4, $t0, $t1         # register t4 now holds 1
sub $t5, $t4, $t0         # register t5 now holds 2
sub $t6, $t5, $t0         # register t6 now holds 3
sub $t7, $t6, $t0         # register t7 now holds 4
