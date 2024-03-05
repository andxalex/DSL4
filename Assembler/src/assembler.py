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
        default = "output.txt",
        required=False,
        help= "output text file",
    )
    return parser

# Define opcodes for instructions
opcodes = {
    "alu": "0100",
    "blu": "0101",
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
    return hex(int(opcodes[instruction],2))

# Function to encode branch and jump instructions with address
def encode_with_address(instruction, address):
    opcode = opcodes[instruction]
    return hex(int(opcode,2)) +'\n'+ address

# Function to encode alu ops
def encode_alu(op_code, alu_opcode):
    return hex(int(alu_opcodes[alu_opcode] + opcodes[op_code],2))


# Function to parse and encode a single instruction
def parse_and_encode(instruction_line):
    # Split once for comments
    instruction = instruction_line.split("//", 1)[0]
    # Split further
    split_instruct = instruction.split(" ")

    opcode = split_instruct[0]
    print(opcode)
    
    if opcode in ["alu", "blu"]:
        return encode_alu(opcode, split_instruct[1])
    if opcode in ["lda","ldb", "sta","stb","gto", "beq", "bgt", "blt", "fnc"]:
        return encode_with_address(opcode, int(split_instruct[1]))
    else:
        return encode_no_operand(opcode)

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
    #    parse_and_encode(line)
       fout.write(parse_and_encode(line) + '\n')
    

if __name__ == "__main__":
    main()