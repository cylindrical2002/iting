package org.cylindrical.iting.ir.generator;

import org.antlr.v4.runtime.tree.ParseTree;
import org.cylindrical.iting.grammar.GQLParserBaseVisitor;

public class IRGeneratorVisitor extends GQLParserBaseVisitor<String> {
    @Override
    public String visit(ParseTree tree) {
        return """
                set _T1 1
                set _T2 1
                add _T1 _T2 _T3
                return _T3""";
    }
}

