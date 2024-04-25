grammar Arithmetic;

@header {
package org.cylindrical.iting.grammar;
}

expr:   <assoc=right> expr '^' expr
    |   expr '*' expr
    |   expr '/' expr
    |   expr '+' expr
    |   expr '-' expr
    |   INT
    |   '(' expr ')'
    ;

INT :   [0-9]+;
WS  :   [ \t\r\n]+ -> skip;
