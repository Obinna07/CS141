#!/usr/bin/env python
#
# Template for MIPS assembler.py
#
# Usage:
#    python assembler_template.py [asm file]

import sys, re

def bin_to_hex(x):
    y = hex(int(x,2))[2:]
    if len(y) < 8:
        y = (8-len(y))*"0" + y
    return y

# convert a hexadecimal string to a 32-bit binary string
def hex_to_bin32(x):
    dec_x = int(x, 16)
    return dec_to_bin(dec_x, 32)

def dec_to_bin(value, nbits):
    value = int(value)
    fill = "0"
    if value < 0:
        value = (abs(value) ^ 0xffffffff) + 1
        fill = "1"

    value = bin(value)[2:]
    if len(value) < nbits:
        value = (nbits-len(value))*fill + value
    if len(value) > nbits:
        value = value[-nbits:]
    return value

# list of all R-type instruction names
rtypes = [ 'add', 'sub', 'and', 'or', 'xor', 'nor', 'sll', 'sra', 'srl', 'slt', 'jr' ]

# mapping from instructions to their op codes (note that 'nop' has no op code)
op_codes = {
    'add'   :   dec_to_bin(0, 6),
    'addi'  :   dec_to_bin(8, 6),
    'sub'   :   dec_to_bin(0, 6),
    'and'   :   dec_to_bin(0, 6),
    'andi'  :   dec_to_bin(12, 6),
    'or'    :   dec_to_bin(0, 6),
    'ori'   :   dec_to_bin(13, 6),
    'xor'   :   dec_to_bin(0, 6),
    'xori'  :   dec_to_bin(14, 6),
    'nor'   :   dec_to_bin(0, 6),
    'sll'   :   dec_to_bin(0, 6),
    'sra'   :   dec_to_bin(0, 6),
    'srl'   :   dec_to_bin(0, 6),
    'slt'   :   dec_to_bin(0, 6),
    'slti'  :   dec_to_bin(10, 6),
    'beq'   :   dec_to_bin(4, 6),
    'bne'   :   dec_to_bin(5, 6),
    'j'     :   dec_to_bin(2, 6),
    'jal'   :   dec_to_bin(3, 6),
    'jr'    :   dec_to_bin(0, 6),
    'lw'    :   dec_to_bin(35, 6),
    'sw'    :   dec_to_bin(43, 6)
}

# mapping from R-type instructions to their function codes
function_codes = {
    'add'   :   dec_to_bin(32, 6),
    'sub'   :   dec_to_bin(34, 6),
    'and'   :   dec_to_bin(36, 6),
    'or'    :   dec_to_bin(37, 6),
    'xor'   :   dec_to_bin(38, 6),
    'nor'   :   dec_to_bin(39, 6),
    'sll'   :   dec_to_bin(0, 6),
    'sra'   :   dec_to_bin(3, 6),
    'srl'   :   dec_to_bin(2, 6),
    'slt'   :   dec_to_bin(42, 6),
    'jr'    :   dec_to_bin(8, 6)
}

# mapping from register names to their register numbers
registers = {
    '$zero' :   dec_to_bin(0, 5),
    '$at'   :   dec_to_bin(1, 5),
    '$v0'   :   dec_to_bin(2, 5),
    '$v1'   :   dec_to_bin(3, 5),
    '$a0'   :   dec_to_bin(4, 5),
    '$a1'   :   dec_to_bin(5, 5),
    '$a2'   :   dec_to_bin(6, 5),
    '$a3'   :   dec_to_bin(7, 5),
    '$t0'   :   dec_to_bin(8, 5),
    '$t1'   :   dec_to_bin(9, 5),
    '$t2'   :   dec_to_bin(10, 5),
    '$t3'   :   dec_to_bin(11, 5),
    '$t4'   :   dec_to_bin(12, 5),
    '$t5'   :   dec_to_bin(13, 5),
    '$t6'   :   dec_to_bin(14, 5),
    '$t7'   :   dec_to_bin(15, 5),
    '$s0'   :   dec_to_bin(16, 5),
    '$s1'   :   dec_to_bin(17, 5),
    '$s2'   :   dec_to_bin(18, 5),
    '$s3'   :   dec_to_bin(19, 5),
    '$s4'   :   dec_to_bin(20, 5),
    '$s5'   :   dec_to_bin(21, 5),
    '$s6'   :   dec_to_bin(22, 5),
    '$s7'   :   dec_to_bin(23, 5),
    '$t8'   :   dec_to_bin(24, 5),
    '$t9'   :   dec_to_bin(25, 5),
    '$k0'   :   dec_to_bin(26, 5),
    '$k1'   :   dec_to_bin(27, 5),
    '$gp'   :   dec_to_bin(28, 5),
    '$sp'   :   dec_to_bin(29, 5),
    '$fp'   :   dec_to_bin(30, 5),
    '$ra'   :   dec_to_bin(31, 5)
}

# add additional mappings from register number naming conventions to register numbers (ex. $8 = $t0)
for i in range(32):
    registers['$' + str(i)] = dec_to_bin(i, 5)

def main():
    # read the .asm program file
    me, fname = sys.argv
    f = open(fname, "r")

    labels = {}             # Map from label to its address.
    parsed_lines = []       # List of parsed instructions.
    address = '0x00400000'  # Track the current address of the instruction.
    line_count = 0          # Number of lines.

    for line in f:
        line_count = line_count + 1

        # Stores attributes about the current line of code, like its label, line
        # number, instruction, and arguments.
        line_attr = {}
        print(line_attr)

        # remove a comment from the line, if present
        comment_index = line.find('#')
        if not comment_index == -1:
            line = line[: comment_index]

        # remove other excessive whitespace (i.e. extra spaces and all tabs) and all commas in the line
        line = re.sub('\s+', ' ', line)
        line = re.sub(',', '', line)
        line = line.strip(' ').strip('\t')

        if line:
            # We'll get you started here with line_count.
            line_attr['line_number'] = line_count

            # separate the remaining parts of the line by spaces
            parsed_pieces = line.split(' ')

            # set a flag to state whether or not this line has a label
            labelled = 0

            # determine if this line has a label or not (it does if the first piece of the line has a colon)
            if not parsed_pieces[0].find(':') == -1:
                labelled = 1

                # map this label to its address
                label_name = parsed_pieces[0][: -1]     # the label name is everything in the first piece except the colon
                labels[label_name] = address

            # parse this line's instruction and arguments (just store the instruction and whatever arguments it has)
            line_attr['instruction'] = parsed_pieces[labelled]
            if len(parsed_pieces) > labelled + 1:
                line_attr['arg0'] = parsed_pieces[labelled + 1]
            if len(parsed_pieces) > labelled + 2:
                line_attr['arg1'] = parsed_pieces[labelled + 2]
            if len(parsed_pieces) > labelled + 3:
                line_attr['arg2'] = parsed_pieces[labelled + 3]

            # save the address of this line
            line_attr['address'] = address

            # Finally, add this dict to the complete list of instructions.
            parsed_lines.append(line_attr)

            address = hex(int(address, 16) + 4)
    f.close()

    machine_code = []

    for line in parsed_lines:
        # encode the 'nop' instruction
        if line['instruction'] == 'nop':
            bin_code = 4 * '0000'

        # encode R-type instructions
        elif line['instruction'] in rtypes:
            # all R-type instructions have the same structure for the op and funct codes, so define them here
            op = op_codes[line['instruction']]
            funct = function_codes[line['instruction']]

            # encode the remaining fields for shift instructions (fill 'shamt' field)
            if line['instruction'] in [ 'sll', 'sra', 'srl' ]:
                rs = '00000'
                rt = registers[line['arg1']]
                rd = registers[line['arg0']]
                shamt = dec_to_bin(line['arg2'], 5)

            # encode the 'jump register' (jr) instruction (note that jr is technically an R-type instruction, but it has to be dealt with separately)
            elif line['instruction'] == 'jr':
                rs = registers[line['arg0']]
                rt = '00000'
                rd = '00000'
                shamt = '00000'

            # encode the remaining fields for non-shift instructions that aren't jr (don't fill 'shamt' field)
            else:
                rs = registers[line['arg1']]
                rt = registers[line['arg2']]
                rd = registers[line['arg0']]
                shamt = '00000'

            bin_code = op + rs + rt + rd + shamt + funct

        # encode the 'load word' and 'store word' instructions
        if line['instruction'] in [ 'lw', 'sw' ]:
            op = op_codes[line['instruction']]

            # get the rs register between the second argument's parentheses
            open_paren = line['arg1'].find('(')
            close_paren = line['arg1'].find(')')
            rs = registers[line['arg1'][open_paren + 1 : close_paren]]

            # get the immedate value before the argument's parentheses
            imm = dec_to_bin(line['arg1'][: open_paren], 16)

            rt = registers[line['arg0']]

            bin_code = op + rs + rt + imm

        # encode the branch instructions (beq and bne)
        if line['instruction'] in [ 'beq', 'bne' ]:
            op = op_codes[line['instruction']]

            rs = registers[line['arg0']]
            rt = registers[line['arg1']]

            # get the relative offset of the branch (in number of lines) and save it as the immediate
            # note that the offset is measured as the number of lines from the line we're targeting to the line *after* the branch instruction for MIPS processors
            target_line = 1 + (int(labels[line['arg2']], 16) - int('0x00400000', 16)) / 4
            offset = target_line - (line['line_number'] + 1)
            imm = dec_to_bin(offset, 16)

            bin_code = op + rs + rt + imm

        # encode the other arithmetic/logical I-type instructions
        if line['instruction'] in ['addi', 'subi', 'andi', 'ori', 'xori', 'slti']:
            op = op_codes[line['instruction']]
            rt = registers[line['arg0']]
            rs = registers[line['arg1']]
            imm = dec_to_bin(int(line['arg2']), 16)

            bin_code = op + rs + rt + imm

        # encode the 'jump' (j) and 'jump and link' (jal) instructions
        if line['instruction'] in ['j', 'jal']:
            op = op_codes[line['instruction']]

            # get the 32-bit Jump Target Address (JTA) from the labels dictionary
            jta = labels[line['arg0']]
            jta_bin = hex_to_bin32(jta)     # convert the hexadecimal address to a 32-bit binary string

            # to get the machine code address, we discard the 2 least significant bits and the 4 most significant bits from the JTA
            addr = jta_bin[4 : 30]

            bin_code = op + addr

        # add the machine code to a list of strings we'll write to a file
        machine_code.append(bin_to_hex(bin_code) + "\n")

    # write the machine code in hexadecimal to a .machine file
    fout_name = fname[ : -3] + "machine"    # get the appropriate name of the output file
    f = open(fout_name, "w+")
    f.writelines(machine_code)
    f.close()

if __name__ == "__main__":
    main()
