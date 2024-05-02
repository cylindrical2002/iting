def parse_keywords_and_generate_rules(input_file, output_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    with open(output_file, 'w') as file:
        for line in lines:
            line = line.strip()
            if line.startswith('//'):
                # Preserve comments
                file.write(line + '\n')
                continue
            if ':' not in line:
                # Skip lines without colon, typically empty lines
                continue

            # Split the line on colon to get the keyword
            keyword_name, keyword = line.split(':')
            keyword_name = keyword_name.strip()
            keyword = keyword.replace(";", '')
            keyword = keyword.replace("'", '')
            keyword = keyword.strip()

            # Generate case-insensitive rule
            case_insensitive_rule = ''.join(
                f"[{char.lower()}{char.upper()}]" if char.isalpha() else f'[{char}]' for char in keyword)
            antlr_rule = f"{keyword_name} : {case_insensitive_rule};"

            # Write the new rule to the output file
            file.write(antlr_rule + '\n')


parse_keywords_and_generate_rules('old_keyword_lexer.txt', 'new_keyword_lexer.txt')
