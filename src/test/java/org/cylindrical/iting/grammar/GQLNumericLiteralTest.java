package org.cylindrical.iting.grammar;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.fail;

public class GQLNumericLiteralTest {

    @BeforeEach
    public void setup() {
        // Setup code if necessary
    }

    @TestFactory
    public Iterable<DynamicTest> dynamicTestsForNumericLiterals() throws Exception {
        try (var lines = Files.lines(Paths.get(getClass().getResource("/numeric_literal.txt").toURI()))) { // Use try-with-resources
            return lines.map(line -> line.split(";"))
                    .map(parts -> DynamicTest.dynamicTest(
                            "Testing input: " + parts[0] + " for rule: " + parts[1] + " should be " + parts[2],
                            () -> {
                                CharStream input = CharStreams.fromString(parts[0]);
                                GQLLexer lexer = new GQLLexer(input);
                                CommonTokenStream tokens = new CommonTokenStream(lexer);
                                GQLParser parser = new GQLParser(tokens);
                                parser.removeErrorListeners();
                                parser.addErrorListener(new BaseErrorListener() {
                                    @Override
                                    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol,
                                                            int line, int charPositionInLine, String msg, RecognitionException e) {
                                        throw new IllegalStateException("Syntax error encountered!", e);
                                    }
                                });

                                ParseTree tree;
                                try {
                                    tree = switch (parts[1]) { // Enhanced switch
                                        case "SIGNED_NUMERIC_LITERAL" -> parser.signed_numeric_literal();
                                        case "UNSIGNED_NUMERIC_LITERAL" -> parser.unsigned_numeric_literal();
                                        case "EXACT_NUMERIC_LITERAL" -> parser.exact_numeric_literal();
                                        case "APPROXIMATE_NUMERIC_LITERAL" -> parser.approximate_numeric_literal();
                                        case "UNSIGNED_INTEGER" -> parser.unsigned_integer();
                                        default -> fail("Test case rule not recognized: " + parts[1]);
                                    };

                                    assertNotNull(tree, "Parsing returned null tree, expected a valid parse tree.");
                                    if (parts[2].equals("invalid")) {
                                        fail("Expected parsing to fail, but it succeeded" + tree.toStringTree(parser));
                                    }
                                } catch (IllegalStateException e) {
                                    if (parts[2].equals("valid")) {
                                        fail("Expected parsing to succeed, but it failed with error: " + e.getMessage());
                                    }
                                }
                            }
                    ))
                    .collect(Collectors.toList());
        }
    }
}
