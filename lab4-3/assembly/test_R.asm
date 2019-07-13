# we re-use one of our tests from 4-1 just to make sure our CPU can still do R-type instructions

nor $1, $0, $0    # set $1 to -1
or $8, $1, $0     # set $8 to -1 with or
and $2, $8, $1    # set $2 to -1 with and
and $3, $1, $0    # set $3 to 0 with and
sub $9, $3, $2    # set $9 to 1
add $10, $9, $9   # set $10 to 2
xor $11, $10, $9  # set $11 to 3
sll $12, $10, 3   # set $12 to 16
sll $4, $11, 2    # set $4 to 12
sub $5, $12, $4   # set $5 to 7
slt $6, $5, $4    # set $6 to 1
slt $7, $12, $s0  # set $7 to 0

# final values:
# $1 = -1
# $2 = -1
# $3 = 0
# $4 = 12
# $5 = 4
# $6 = 1
# $7 = 0
# $8 = -1
# $9 = 1
# $10 = 2
# $11 = 3
# $12 = 16
