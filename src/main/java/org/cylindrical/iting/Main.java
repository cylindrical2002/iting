package org.cylindrical.iting;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ParseTree;
import org.cylindrical.iting.grammar.GQLLexer;
import org.cylindrical.iting.grammar.GQLParser;

public class Main {
    public static void main(String[] args) throws Exception {
        String expression = "10.M";
        CharStream input = CharStreams.fromString(expression);
        GQLLexer lexer = new GQLLexer(input);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        tokens.fill();  // Load all tokens from lexer
        for (Token token : tokens.getTokens()) {
            System.out.println(token.getText() + ": " + token.getType());
        }

        GQLParser parser = new GQLParser(tokens);
        ParseTree tree = parser.unsigned_numeric_literal();
        System.out.println(tree.toStringTree(parser));
    }
}
