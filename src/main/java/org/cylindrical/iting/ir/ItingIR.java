package org.cylindrical.iting.ir;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.tree.ParseTree;
import org.cylindrical.iting.grammar.GQLLexer;
import org.cylindrical.iting.grammar.GQLParser;
import org.cylindrical.iting.ir.generator.IRGeneratorVisitor;
import org.cylindrical.iting.ir.preprocess.PreCalculatorVisitor;
import org.cylindrical.iting.ir.semantics.NameCheckVisitor;
import org.cylindrical.iting.ir.semantics.TypeCheckVisitor;

public class ItingIR {
    public String generateIR(String input) {
        CharStream charStream = CharStreams.fromString(input);
        GQLLexer lexer = new GQLLexer(charStream);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        GQLParser parser = new GQLParser(tokens);
        ParseTree tree = parser.gql_program();

        PreCalculatorVisitor preCalculator = new PreCalculatorVisitor();
        preCalculator.visit(tree);

        NameCheckVisitor nameCheck = new NameCheckVisitor();
        nameCheck.visit(tree);

        TypeCheckVisitor typeCheck = new TypeCheckVisitor();
        typeCheck.visit(tree);

        IRGeneratorVisitor irGenerator = new IRGeneratorVisitor();
        return irGenerator.visit(tree);
    }
}

