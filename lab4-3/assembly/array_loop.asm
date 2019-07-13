addi $s0, $zero, 1024     # put the start address of the array in $s0

# store the values [1, 3, 3, 9, 4] at the address stored in $s0
ori $8, $zero, 1
sw $8, 0($s0)
ori $8, $zero, 3
sw $8, 4($s0)
ori $8, $zero, 3
sw $8, 8($s0)
ori $8, $zero, 9
sw $8, 12($s0)
ori $8, $zero 4
sw $8, 16($s0)
ori $s1, $zero, 5         # store the length of the array in $s1

# find the sum of the elements and store it in $s2
or $8, $zero, $zero       # zero out the index variable $8
or $s2, $zero, $zero      # zero out the total sum $s2
loop: beq $8, $s1, end    # only exit the loop if $8 = length of array = $s1
sll $9, $8, 2             # multiply the index by 4 and store it in $9
add $10, $9, $s0          # calculate the effective address of the next array element
lw $11, 0($10)            # access the array element from memory
add $s2, $s2, $11         # add array element to the total sum
addi $8, $8, 1            # increment the index variable
j loop
end: nop

# final values
# $8 = 5
# $9 = 16
# $10 = 1024 + 16 = 1040
# $11 = 4
# $s0 = 1024
# $s1 = 5
# $s2 = 20
