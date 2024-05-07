package org.cylindrical.iting.grammar;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.ParseTree;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

public class GQLNumericLiteralTest {

    @TestFactory
    public Iterable<DynamicTest> dynamicTestsForNumericLiterals() {
        URL resource = getClass().getResource("/numeric_literal.txt");
        if (resource == null) {
            throw new IllegalArgumentException("Resource not found");
        }

        try (Stream<String> lines = Files.lines(Paths.get(resource.toURI()))) {
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

                                try {
                                    ParseTree tree = switch (parts[1]) {
                                        case "SIGNED_NUMERIC_LITERAL" -> parser.signed_numeric_literal();
                                        case "UNSIGNED_NUMERIC_LITERAL" -> parser.unsigned_numeric_literal();
                                        case "EXACT_NUMERIC_LITERAL" -> parser.exact_numeric_literal();
                                        case "APPROXIMATE_NUMERIC_LITERAL" -> parser.approximate_numeric_literal();
                                        case "UNSIGNED_INTEGER" -> parser.unsigned_integer();
                                        default -> fail("Test case rule not recognized: " + parts[1]);
                                    };

                                    assertNotNull(tree, "Parsing returned null tree, expected a valid parse tree.");
                                    assertEquals(Token.EOF, tokens.LA(1), "Parser did not consume the entire input");

                                    if (parts[2].equals("invalid")) {
                                        fail("Expected parsing to fail, but it succeeded: " + tree.toStringTree(parser));
                                    }
                                    System.out.println(tree.toStringTree(parser));
                                } catch (IllegalStateException | AssertionError e) {
                                    if (parts[2].equals("valid")) {
                                        fail("Expected parsing to succeed, but it failed with error: " + e.getMessage());
                                    }
                                }
                            }
                    ))
                    .collect(Collectors.toList());
        } catch (URISyntaxException e) {
            throw new RuntimeException("Error converting URL to URI", e);
        } catch (IOException e) {
            throw new RuntimeException("Error reading from file", e);
        }
    }
}
