main: add $s7, $s5, $s6         # this tests each type of instruction we encode
sll     $t7,        $s3,   2    # ex. we divide R-type instructions into three categories:
j       main                    # shift instructions (ex. sra), non-shift instructions (ex. sub), and jr
jr                                          $fp          # so we have an instruction for each of those categories
beq         $s3, $17, main
nop
bne $fp, $13,       test
test:   sw $t7,     -16($t2)
nop
nop
xori $s4,       $zero, 16           # we also add labels for the jump and branch instructions
nop
