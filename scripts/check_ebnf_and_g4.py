import re


def read_file(file_path, skip_lines=0):
    """Read and return content of a file, skipping a specified number of lines at the beginning."""
    with open(file_path, "r") as file:
        for _ in range(skip_lines):
            next(file)  # Skip initial lines
        return file.read()


def preprocess_rule(rule, rule_type):
    """Apply initial preprocessing steps based on rule type."""
    rule = re.sub(r"\s+", " ", rule).strip()  # Normalize spaces

    if rule_type == "g4":
        if rule.endswith(";"):
            rule = rule[:-1].rstrip()
    elif rule_type == "ebnf":
        if "SKIP" in rule:
            rule = rule.replace("SKIP", "SKIP_TOKEN")
        tokens = re.findall(r"(<[^>]+>|::=|\||\[|\]|\{|\}|\.\.\.|\w+)", rule)
        # Join tokens with single space, ensuring no trailing space
        rule = " ".join(tokens).strip()
        # Remove spaces before ..., ], }
        rule = re.sub(r"\s+(\.\.\.|]|})", r"\1", rule)
        # Remove spaces after {, [
        rule = re.sub(r"(\{|\[)\s+", r"\1", rule)

    return rule.lower()


def rename_ebnf_names(rule):
    """Rename EBNF names to G4 style by replacing spaces with underscores and non-alphanumerics with double underscores."""

    def replace_name(match):
        # 获取匹配的名称部分，忽略尖括号
        name = match.group(1)
        # 替换所有空格为单个下划线
        name = re.sub(r"\s+", "_", name)
        # 替换所有非字母数字字符为双下划线
        name = re.sub(r"[^\w]", "__", name)
        return name

    # 应用替换规则到规则字符串
    rule = re.sub(r"<([^>]+)>", replace_name, rule)
    return rule


def transform_ebnf_to_g4(rule):
    """Transform EBNF rule to G4 format."""

    # Step 1: Replace {} with () and ::= with :
    rule = rule.replace("{", "(")
    rule = rule.replace("}", ")")
    rule = rule.replace("::=", ":")

    # Repeat processing [] until all are transformed
    old_rule = None
    while old_rule != rule:
        old_rule = rule

        # Process [] for optional and repetition constructs
        def process_square_brackets(match):
            content = match.group(1)
            # Detect whether content ends with '...'
            if content.endswith("..."):
                return content[:-3] + "*"
            # Check if content is a single word consisting only of lowercase letters, digits, or underscores
            if re.fullmatch(r"[a-z0-9_]+", content):
                return content + "?"
            # Otherwise, return content as an optional grouped expression
            return f"({content})?"

        # Use a regex to match brackets considering nesting
        rule = re.sub(
            r"\[((?:[^\[\]]|\[(?:[^\[\]]|\[[^\[\]]*\])*\])*)\]",
            process_square_brackets,
            rule,
        )

    # Step 3: Replace remaining ... with +
    rule = rule.replace("...", "+")

    return rule


def compress_rules(content, rule_type):
    """Extract rules and keep them in their line with starting and ending tokens intact."""
    rules = []
    if rule_type == "g4":
        # Remove comments and extract rules for G4
        content = re.sub(
            r"/\*.*?\*/", "", content, flags=re.DOTALL
        )  # Remove block comments
        content = re.sub(
            r"//.*$", "", content, flags=re.MULTILINE
        )  # Remove line comments
        # Extract rules ending with semicolon
        rules = re.split(r"(?<=;)", content)  # Keep semicolon at the end
    else:
        # Extract rules for EBNF, starting each rule at <name> ::=
        # Remove comments and extract rules for EBNF
        content = re.sub(
            r"/\*.*?\*/", "", content, flags=re.DOTALL
        )  # Remove block comments

        rule_pattern = re.compile(r"(<[^>]+>\s*::=.*?)(?=(<[^>]+>\s*::=|$))", re.DOTALL)
        rules = [match.group(1) for match in rule_pattern.finditer(content)]

    # Filter out empty strings and compress whitespace within rules
    compressed_rules = [" ".join(rule.split()) for rule in rules if rule.strip()]
    return compressed_rules


def compare_rules(ebnf_rules, g4_rules):
    import re

    # 将列表转换为集合
    ebnf_set = set(ebnf_rules)
    g4_set = set(g4_rules)

    # 准备两个字典，以EBNF和G4规则的首个单词作为键
    ebnf_rules_by_first_word = {}
    g4_rules_by_first_word = {}
    for rule in ebnf_rules:
        first_word = re.match(r"^\s*(\S+)", rule)
        if first_word:
            first_word = first_word.group(1)
            if first_word not in ebnf_rules_by_first_word:
                ebnf_rules_by_first_word[first_word] = []
            ebnf_rules_by_first_word[first_word].append(rule)

    for rule in g4_rules:
        first_word = re.match(r"^\s*(\S+)", rule)
        if first_word:
            first_word = first_word.group(1)
            if first_word not in g4_rules_by_first_word:
                g4_rules_by_first_word[first_word] = []
            g4_rules_by_first_word[first_word].append(rule)

    # 已比较并找到相似规则的集合
    compared_pairs = set()

    # 输出 EBNF 中但不在 G4 中的规则
    print(f"{len(ebnf_set - g4_set)} Rules unique to EBNF or have similar in G4:")
    for rule in ebnf_set:
        if rule in g4_set:
            continue  # Skip if the rule is in both sets
        first_word = re.match(r"^\s*(\S+)", rule)
        similar_rule = "no similar rule"
        if first_word:
            first_word = first_word.group(1)
            if first_word in g4_rules_by_first_word:
                similar_rule = g4_rules_by_first_word[first_word][0]
                compared_pairs.add((rule, similar_rule))
        print(f"EBNF Rule      : {rule}")
        print(f"Similar G4 Rule: {similar_rule}")

    # 输出 G4 中但不在 EBNF 中的规则
    print(f"\n{len(g4_set - ebnf_set)} Rules unique to G4 or have similar in EBNF:")
    for rule in g4_set:
        if rule in ebnf_set:
            continue  # Skip if the rule is in both sets
        first_word = re.match(r"^\s*(\S+)", rule)
        similar_rule = "no similar rule"
        if first_word:
            first_word = first_word.group(1)
            if first_word in ebnf_rules_by_first_word:
                similar_rule = ebnf_rules_by_first_word[first_word][0]
                if (similar_rule, rule) in compared_pairs:
                    continue  # Skip if this pair was already compared
        print(f"G4 Rule          : {rule}")
        print(f"Similar EBNF Rule: {similar_rule}")
    # print("\nRules in both EBNF and G4:")
    # for rule in rules_in_both:
    #     print(rule)


def main():
    ebnf_content = read_file("ebnf.txt")
    g4_content = read_file("../src/main/antlr4/GQLParser.g4", skip_lines=10)
    ebnf_rules = compress_rules(ebnf_content, "ebnf")
    g4_rules = compress_rules(g4_content, "g4")

    ebnf_rules = [preprocess_rule(rule, "ebnf") for rule in ebnf_rules]
    g4_rules = [preprocess_rule(rule, "g4") for rule in g4_rules]

    ebnf_rules = [rename_ebnf_names(rule) for rule in ebnf_rules]

    ebnf_rules = [transform_ebnf_to_g4(rule) for rule in ebnf_rules]

    compare_rules(ebnf_rules, g4_rules)

    # print("EBNF Rules:")
    # for rule in ebnf_rules:
    #     print(rule)
    # print("\nG4 Rules:")
    # for rule in g4_rules:
    #     print(rule)


if __name__ == "__main__":
    main()
