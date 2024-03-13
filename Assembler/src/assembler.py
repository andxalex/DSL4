import argparse


# Parser
def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--infile",
        type=str,
        required=True,
        help="assembly text file",
    )

    parser.add_argument(
        "--outfile",
        type=str,
        default="../../Core/src/Complete_Demo_ROM.txt",
        required=False,
        help="output text file",
    )
    return parser


# Define opcodes for instructions
opcodes = {
    "alu": "0100",
    "blu": "0101",
    "alui": "1101",
    "blui": "1110",
    "lda": "00000000",
    "ldb": "00000001",
    "sta": "00000010",
    "stb": "00000011",
    "beq": "10010110",
    "bgt": "10100110",
    "blt": "10110110",
    "gto": "00000111",
    "gti": "00001000",
    "fnc": "00001001",
    "ret": "00001010",
    "dfa": "00001011",
    "dfb": "00001100",
}

# Define opcodes for ALU;
alu_opcodes = {
    "add": "00000",
    "sub": "00001",
    "mul": "00010",
    "sla": "00011",
    "sra": "00100",
    "app": "00101",
    "bpp": "00110",
    "amm": "00111",
    "bmm": "01000",
    "equ": "01001",
    "gte": "01010",
    "lte": "01011",
}


# Function to encode instructions with no operands
def encode_no_operand(instruction):
    return "0x" + format(int(opcodes[instruction], 2), "02x")


# Function to encode branch and jump instructions with address
def encode_with_address(instruction, address):
    opcode = opcodes[instruction]
    return "0x" + format(int(opcode, 2), "02x") + "\n" + address


# Function to encode alu ops
def encode_alu(op_code, alu_opcode):
    return "0x" + format(int(alu_opcodes[alu_opcode] + opcodes[op_code], 2), "02x")


# Function to encode immediate instructions (alu operations for now)
def encode_with_immediate(op_code, alu_opcode, imm):
    return (
        "0x"
        + format(int(alu_opcodes[alu_opcode] + opcodes[op_code], 2), "02x")
        + "\n"
        + format(int(imm), "02x")
    )


# Function to parse and encode a single instruction
def parse_and_encode(instruction_line):
    # Split once for comments
    instruction = instruction_line.split("//", 1)[0]
    # Split further
    split_instruct = instruction.split(",")
    split_instruct = [a.split() for a in split_instruct][0]

    # Opcode is first word
    opcode = split_instruct[0]
    print(split_instruct)

    if opcode in ["alu", "blu"]:
        alu_code = split_instruct[1]
        return encode_alu(opcode, alu_code)
    elif opcode in ["alui", "blui"]:
        alu_code = split_instruct[1]
        imm = split_instruct[2]
        return encode_with_immediate(opcode, alu_code, imm)
    elif opcode in ["lda", "ldb", "sta", "stb", "gto", "beq", "bgt", "blt", "fnc"]:
        arg = split_instruct[1]
        return encode_with_address(opcode, arg)
    else:
        return encode_no_operand(opcode)
    # return "\n"


def main():
    # Parse args
    parser = get_parser()
    args = parser.parse_args()
    input_file = args.infile
    output_file = args.outfile

    # Open files
    fin = open(f"{input_file}", "r")
    fout = open(f"{output_file}", "w+")

    # Iterate and translate
    for line in fin.read().splitlines():
        fout.write(parse_and_encode(line) + "\n")

    # Close files
    fin.close()
    fout.close()

    # Pad output
    num_lines = sum(1 for _ in open(f"{output_file}", "r"))
    fout = open(f"{output_file}", "a+")
    for _ in range(num_lines, 255 - 1):
        fout.write("0x0F" + "\n")
    fout.write("0x00" + "\n")
    fout.write("0x00")

    # Close output file again
    fout.close()


if __name__ == "__main__":
    main()
