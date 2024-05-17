package org.cylindrical.iting;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.cylindrical.iting.grammar.GQLLexer;
import org.cylindrical.iting.grammar.GQLParser;

public class Main {

    private static final Logger logger = LogManager.getLogger(Main.class);

    public static void main(String[] args) {
        String expression = "MATCH (n:Person) WHERE n.name = 'Alice' RETURN n.age AS age, n.name AS name";
        CharStream input = CharStreams.fromString(expression);
        GQLLexer lexer = new GQLLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        tokens.fill();  // Load all tokens from lexer
        for (Token token : tokens.getTokens()) {
            System.out.println(token.getText() + " : " + lexer.getVocabulary().getSymbolicName(token.getType()));
        }

        GQLParser parser = new GQLParser(tokens);
        ParseTree tree = parser.gql_program();
        System.out.println(tree.toStringTree(parser));

        logger.info("This is an info message.");
        logger.debug("This is a debug message.");
        logger.error("This is an error message.");
    }
}
