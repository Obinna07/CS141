# tests for the or-immediate instructions

addi $t0, $0, 10                 # register t1 now holds integer 10:
                              # (00000000000000000000000000001010)

                              # (00000000000000000000000000001010)
                              # (00000000000000000000000000001011)
ori $t0, $t0, 11                 # register t0 now holds integer 11:
                              # (00000000000000000000000000001011)

                              # (00000000000000000000000000001011)
                              # (00000000000000000000000000001101)
ori $t0, $t0, 13                 # register t0 now holds integer 15:
                              # (00000000000000000000000000001111)

                              # (00000000000000000000000000001111)
                              # (11111111111111111111111111111111)
ori $t0, $t0, -1                 # register t0 now holds integer -1:
                              # (11111111111111111111111111111111)

                              # (11111111111111111111111111111111)
                              # (00000000000000000000000000000000)
ori $t0, $t0, 0                  # register t0 still holds all 1s:
                              # (11111111111111111111111111111111)
