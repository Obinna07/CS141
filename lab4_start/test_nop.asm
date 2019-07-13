nor $t0, $0, $0
sub $t1, $0, $t0
srl $t2, $t0, 1
nop
xor $t3, $t2, $t0
or $t4, $t3, $t1
nop
sra $t5, $t4, 3
nop
sra $t6, $t1, 2

# final values
# $t0 = -1
# $t1 = 1
# $t2 = 2^31 - 1
# $t3 = -2^31
# t4 = 1 - 2^31
# $t5 = -2^31 + -2^30 + -2^29 + -2^28
# $t6 = 0
