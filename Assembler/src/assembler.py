import argparse


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--file",
        type=str,
        required=True,
        help="assembly text file",
    )

    return parser

# Define opcodes for instructions
opcodes = {
    "ALU_OP_A": "0100",
    "ALU_OP_B": "0101",
    "BREQ": "10010110",
    "BGTQ": "10100110",
    "BLTQ": "10110110",
    "GOTO": "xxxx0111",
    "GOTO_IDLE": "xxxx1000",
    "FUNCTION_CALL": "xxxx1001",
    "RETURN": "xxxx1010",
    "DEREF_A": "xxxx1011",
    "DEREF_B": "xxxx1100",
}

# Define opcodes for ALU;
alu_opcodes = {
    "add": "0000",
    "sub": "0001",
    "mul": "0010",
    "sla": "0011",
    "sra": "0100",
    "app": "0101",
    "bpp": "0110",
    "amm": "0111",
    "bmm": "1000",
    "equ": "1001",
    "gte": "1010",
                "lte": "1011",
}

# Function to encode instructions with no operands
def encode_no_operand(instruction):
    return opcodes[instruction]

# Function to encode branch and jump instructions with address
def encode_with_address(instruction, address):
    opcode = opcodes[instruction]
    address_bin = format(address, '08b')  # Convert address to 8-bit binary
    return opcode[:4] + address_bin

# Function to parse and encode a single instruction
def parse_and_encode(instruction_line):
    parts = instruction_line.split()
    instruction = parts[0]
    if instruction in ["GOTO", "BREQ", "BGTQ", "BLTQ", "FUNCTION_CALL"]:
        return encode_with_address(instruction, int(parts[1]))
    else:
        return encode_no_operand(instruction)

def main():
    # Parse args
    parser = get_parser()
    args = parser.parse_args()
    file = args.file

    # Open file
    f = open(f"{file}", "r")

    # Iterate and translate
    for line in f:
        parse_and_encode(line)


if __name__ == "__main__":
    main()