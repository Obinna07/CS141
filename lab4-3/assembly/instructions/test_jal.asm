jal label1    # $ra should contain 0x400004 (0x400000 + 4)
nop
nop
label1: nop
nop
jal label2    # $ra should contain 0x400018 (0x400000 + 24)
nop
label2: nop
nop
nop
nop
