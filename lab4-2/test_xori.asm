# tests for xor-immediate instruction

addi $t0, $0, 10                  # register t0 now holds integer 10:
                              # (00000000000000000000000000001010)

                              # (00000000000000000000000000001010)
                              # (00000000000000000000000000001011)
xori $t0, $t0, 11                 # register t0 now holds integer 1:
                              # (00000000000000000000000000000001)

                              # (00000000000000000000000000000001)
                              # (00000000000000000000000000001101)
xori $t0, $t0, 13                 # register t0 now holds integer 12:
                              # (00000000000000000000000000001100)

                              # (00000000000000000000000000001100)
                              # (11111111111111111111111111111111)
xori $t0, $t0, -1                 # register t0 now holds integer -13:
                              # (11111111111111111111111111110011)

                              # (11111111111111111111111111110011)
                              # (00000000000000000000000000000000)
xori $t0, $t0, 0                  # register t0 still holds integer -13:
                              # (11111111111111111111111111110011)
