# naivemm:
        addi	$sp,	$sp,  -40
        sw	  $fp,	36($sp)
        sw	  $4,	  40($fp)
        sw	  $5,	  44($fp)
        sw	  $6,	  48($fp)
        sw	  $7,	  52($fp)
        sw	  $0,	  8($fp)
        j		  L2
        nop


L7:     sw	  $0,	12($fp)
        j		  L3
        nop

L6:     sw	  $0,	16($fp)
        j		  L4
        nop

L5:     lw		$3,	8($fp)
        lw		$2,	56($fp)
        nop
        mul	  $3,	$2
        lw		$2,	12($fp)
        add	  $2,	$3,	$2
        sw	  $2,	20($fp)
        lw		$3,	8($fp)
        lw		$2,	60($fp)
        nop
        mul	  $3,	$2
        lw		$2,	16($fp)
        add	  $2,	$3,	$2
        sw	  $2,	24($fp)
        lw		$3,	16($fp)
        lw		$2,	56($fp)
        nop
        mul	  $3,	$2
        lw		$2,	12($fp)
        add	  $2,	$3,	$2
        sw    $2,	28($fp)
        lw		$2,	20($fp)
        nop
        sll		$2,	$2,	2
        lw		$3,	40($fp)
        nop
        add	  $2,	$3,	$2
        lw		$3,	20($fp)
        nop
        sll		$3,	$3,	2
        lw		$4,	40($fp)
        nop
        add	  $3,	$4,	$3
        lw		$2,	0($3)
        lw		$3,	24($fp)
        nop
        sll		$3,	$3,	2
        lw		$4,	44($fp)
        nop
        add 	$3,	$4,	$3
        lw		$t4,	0($3)
        lw		$3,	28($fp)
        nop
        sll		$3,	$3,	2
        lw		$4,	48($fp)
        nop
        add 	$3,	$4,	$3
        lw		$t0,	0($3)
        nop
        mul	  $t0,	$t4,	$t0
        add	  $a0,	$2,	$t0
        sw	  $t0,	0($2)
        lw		$2,	16($fp)
        nop
        addi	$2,	$2,	1
        sw	  $2,	16($fp)

L4:     lw		$3,	16($fp)
        lw		$2,	60($fp)
        nop
        slt		$2,	$3,	$2
        bne	  $2,	$0,	L5
        nop

        lw		$2,	12($fp)
        nop
        addi	$2,	$2,	1
        sw	  $2,	12($fp)

L3:     lw		$3,	12($fp)
        lw		$2,	56($fp)
        nop
        slt		$2,	$3,	$2
        bne	  $2,	$0,	L6
        nop

        lw		$2,	8($fp)
        nop
        addi	$2,	$2,	1
        sw	  $2,	8($fp)

L2:     lw		$3,	8($fp)
        lw		$2,	52($fp)
        nop
        slt		$2,	$3,	$2
        bne	  $2,	$0,	L7
        nop

        nop
        lw		$fp,	36($sp)
        addi	$sp,	$sp,	40
        j		  L3
        nop
