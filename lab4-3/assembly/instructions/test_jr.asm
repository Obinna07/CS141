addi $8, $zero, 7
addi $9, $zero, 8192      # set $9 = 8192
sll $10, $9, 9            # multiply $9 by 512, so $10 = 419304 = 0x400000
addi $11, $10, 28         # set $9 = 0x40001c
jr $11                    # jump to address 0x0040001c
addi $8, $8, -6
nop
nop                       # we jump to this address, so the last addi doesn't occur
nop
nop

# final values
# $8 = 7 (if $8 = 1, the jump failed)
# $9 = 8192 (0x400000 shifted 9 places right)
# $10 = 0x400000
# $11 = 0x40001c
