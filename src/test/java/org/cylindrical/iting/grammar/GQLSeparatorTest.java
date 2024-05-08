package org.cylindrical.iting.grammar;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.TestFactory;

import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.fail;

public class GQLSeparatorTest {
    @TestFactory
    public Stream<DynamicTest> generateSeparatorTests() throws Exception {
        URL resource = getClass().getResource("/separator.txt");
        if (resource == null) {
            throw new IllegalArgumentException("Resource not found");
        }
        String content = new String(Files.readAllBytes(Paths.get(resource.toURI())));
        String[] sections = content.split("###");
        List<DynamicTest> tests = new ArrayList<>();

        for (int testIndex = 0; testIndex < sections.length; testIndex++) {
            String section = sections[testIndex];
            if (!section.trim().isEmpty()) {
                String[] parts = section.split("\n", 2);
                String testType = parts[0].trim();
                String testData = parts.length > 1 ? parts[1].trim() : "";

                tests.add(DynamicTest.dynamicTest("Test " + testIndex, () -> {
                    System.out.println(testType);
                    System.out.println(testData);
                    CharStream input = CharStreams.fromString(testData);
                    GQLLexer lexer = new GQLLexer(input);
                    CommonTokenStream tokens = new CommonTokenStream(lexer);
                    tokens.fill();
                    for (Token token : tokens.getTokens()) {
                        System.out.println(
                                token.getText() + " : " + lexer.getVocabulary().getSymbolicName(token.getType())
                        );
                    }
                    boolean correctSeparator = tokens.getTokens().size() == 2
                            && tokens.getTokens().get(0).getType() == GQLLexer.SEPARATOR
                            && tokens.getTokens().get(1).getType() == Token.EOF;

                    if (testType.equals("invalid") && correctSeparator) {
                        fail("Expected invalid, but found correct separator.");
                    } else if (testType.equals("valid") && !correctSeparator) {
                        fail("Expected valid, but found incorrect separator.");
                    }
                }));
            }
        }

        return tests.stream();
    }
}