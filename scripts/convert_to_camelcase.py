import re


def camel_case_converter(match):
    word = match.group(0)
    if word[0].isdigit() or word[0] == '_':
        raise ValueError(f"Word cannot start with a digit or underscore: {word}")
    if word[0].islower():
        # Replace _[a-z] with [A-Z] and _[0-9] with [0-9]
        word = re.sub(r'_([a-z])', lambda x: x.group(1).upper(), word)
        word = re.sub(r'_(\d)', r'\1', word)
    return word


def convert_line(line):
    # Skip single-line comments
    if line.strip().startswith('//'):
        return line
    # Convert words in the line
    return re.sub(r'\b[a-zA-Z0-9_]+\b', camel_case_converter, line)


def convert_file_to_camelcase(input_filename, output_filename):
    with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
        lines = infile.readlines()

        for i, line in enumerate(lines):
            if i < 4:
                # Ignore the first 4 lines
                outfile.write(line)
            else:
                # Process the line
                converted_line = convert_line(line)
                outfile.write(converted_line)


# 测试
input_filename = 'OldGQLParser.g4.txt'
output_filename = 'NewGQLParser.g4.txt'
convert_file_to_camelcase(input_filename, output_filename)
