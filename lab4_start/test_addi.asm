# tests for the addi instruction

addi $t0, $0, 10                  # register t1 now holds integer 10:
                            #(00000000000000000000000000001010)

                              #(00000000000000000000000000001010)
                              #(00000000000000000000000000001011)
addi $t0, $t0, 11                 # register t0 now holds integer 21:
                              #(00000000000000000000000000010101)

                              #(00000000000000000000000000010101)
                              #(11111111111111111111111111110011)
addi $t0, $t0, -13                 # register t0 now holds integer 8:
                              #(00000000000000000000000000001000)

                              #(00000000000000000000000000001000)
                              #(11111111111111111111111111111111)
addi $t0, $t0, 4294967295         # register $t0 now holds:
                              #(00000000000000000000000000000111)

                              #(11111111111111111111111111111111)
                              #(00000000000000000000000000000000)
addi $t0, $t0, 0                  # register t0 still holds all 1s:
                             # (00000000000000000000000000011111)