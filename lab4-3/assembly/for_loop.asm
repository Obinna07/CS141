# make a simple for-loop to increment $8 to 4

ori $8, $zero, 1       # start $8 at 1
ori $9, $zero, 4      # set the loop's limit to $9 = 4
loop: beq $8, $9, end  # end the loop if $8 is at 4
addi $8, $8, 1         # increment $8 by 1
j loop                 # re-iterate through the loop
end: nop

# final values
# $8 = 4
# $9 = 4
