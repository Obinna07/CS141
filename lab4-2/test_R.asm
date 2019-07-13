# we re-use one of our tests from 4-1 just to make sure our CPU can still do R-type instructions

nor $s0, $0, $0   # set $s0 to -1
or $at, $s0, $0   # set $at to -1 with or
and $s1, $at, $s0 # set $s1 to -1 with and
and $s2, $s0, $0  # set $s2 to 0 with and
sub $t0, $s2, $s1 # set $t0 to 1
add $t1, $t0, $t0 # set $t1 to 2
xor $t2, $t1, $t0 # set $t2 to 3
sll $t3, $t1, 3   # set $t3 to 16
sll $s3, $t2, 2   # set $s3 to 12
sub $s4, $t3, $s3 # set $s4 to 7
slt $s5, $s4, $s3 # set $s5 to 1
slt $s6, $t3, $s0 # set $s6 to 0

# final values:
# $s0 = -1
# $at = -1
# $s1 = -1
# $s2 = 0
# $t0 = 1
# $t1 = 2
# $t2 = 3
# $t3 = 16
# $s3 = 12
# $s4 = 4
# $s5 = 1
# $s6 = 0
