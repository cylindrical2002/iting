package org.cylindrical.iting.grammar;

import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.misc.ParseCancellationException;
import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class GQLKeywordTest {

    private void testWords(String filePath, String testName) throws Exception {
        List<String> lines = Files.readAllLines(Paths.get(getClass().getResource(filePath).toURI()));
        GQLLexer lexer = new GQLLexer(CharStreams.fromString(String.join("\n", lines)));
        int tokenCount = 0;
        try {
            for (Token token = lexer.nextToken(); token.getType() != Token.EOF; token = lexer.nextToken()) {
                System.out.println(token.getText() + " : " + lexer.getVocabulary().getSymbolicName(token.getType()));
                tokenCount++;
            }
        } catch (ParseCancellationException e) {
            System.out.println("Error in parsing: " + e.getMessage());
        }
        assertEquals(lines.size(), tokenCount, "The number of tokens in " + testName + " does not match the expected count.");
    }

    @Test
    public void testNonReservedWords() throws Exception {
        testWords("/non_reserved_words.txt", "non-reserved words");
    }

    @Test
    public void testPreReservedWords() throws Exception {
        testWords("/pre_reserved_words.txt", "pre-reserved words");
    }

    @Test
    public void testReservedWords() throws Exception {
        testWords("/reserved_words.txt", "reserved words");
    }
}
