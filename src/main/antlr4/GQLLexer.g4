/*
Copyright (c) 2024 Yue Chen
All rights reserved.
*/

lexer grammar GQLLexer;

channels {
    COMMENT
}

// ---------------------------------------------------------------------
// KEYWORD
// PRE-RESERVED WORD
ABSTRACT : [aA][bB][sS][tT][rR][aA][cC][tT];
AGGREGATE : [aA][gG][gG][rR][eE][gG][aA][tT][eE];
AGGREGATES : [aA][gG][gG][rR][eE][gG][aA][tT][eE][sS];
ALTER : [aA][lL][tT][eE][rR];
CATALOG : [cC][aA][tT][aA][lL][oO][gG];
CLEAR : [cC][lL][eE][aA][rR];
CLONE : [cC][lL][oO][nN][eE];
CONSTRAINT : [cC][oO][nN][sS][tT][rR][aA][iI][nN][tT];
CURRENT_ROLE : [cC][uU][rR][rR][eE][nN][tT][_][rR][oO][lL][eE];
CURRENT_USER : [cC][uU][rR][rR][eE][nN][tT][_][uU][sS][eE][rR];
DATA : [dD][aA][tT][aA];
DIRECTORY : [dD][iI][rR][eE][cC][tT][oO][rR][yY];
DRYRUN : [dD][rR][yY][rR][uU][nN];
EXACT : [eE][xX][aA][cC][tT];
EXISTING : [eE][xX][iI][sS][tT][iI][nN][gG];
FUNCTION : [fF][uU][nN][cC][tT][iI][oO][nN];
GQLSTATUS : [gG][qQ][lL][sS][tT][aA][tT][uU][sS];
GRANT : [gG][rR][aA][nN][tT];
INSTANT : [iI][nN][sS][tT][aA][nN][tT];
INFINITY : [iI][nN][fF][iI][nN][iI][tT][yY];
NUMBER : [nN][uU][mM][bB][eE][rR];
NUMERIC : [nN][uU][mM][eE][rR][iI][cC];
ON : [oO][nN];
OPEN : [oO][pP][eE][nN];
PARTITION : [pP][aA][rR][tT][iI][tT][iI][oO][nN];
PROCEDURE : [pP][rR][oO][cC][eE][dD][uU][rR][eE];
PRODUCT : [pP][rR][oO][dD][uU][cC][tT];
PROJECT : [pP][rR][oO][jJ][eE][cC][tT];
QUERY : [qQ][uU][eE][rR][yY];
RECORDS : [rR][eE][cC][oO][rR][dD][sS];
REFERENCE : [rR][eE][fF][eE][rR][eE][nN][cC][eE];
RENAME : [rR][eE][nN][aA][mM][eE];
REVOKE : [rR][eE][vV][oO][kK][eE];
SUBSTRING : [sS][uU][bB][sS][tT][rR][iI][nN][gG];
SYSTEM_USER : [sS][yY][sS][tT][eE][mM][_][uU][sS][eE][rR];
TEMPORAL : [tT][eE][mM][pP][oO][rR][aA][lL];
UNIQUE : [uU][nN][iI][qQ][uU][eE];
UNIT : [uU][nN][iI][tT];
VALUES : [vV][aA][lL][uU][eE][sS];
WHITESPACE : [wW][hH][iI][tT][eE][sS][pP][aA][cC][eE];
// RESERVED WORD
ABS : [aA][bB][sS];
ACOS : [aA][cC][oO][sS];
ALL : [aA][lL][lL];
ALL_DIFFERENT : [aA][lL][lL][_][dD][iI][fF][fF][eE][rR][eE][nN][tT];
AND : [aA][nN][dD];
ANY : [aA][nN][yY];
ARRAY : [aA][rR][rR][aA][yY];
AS : [aA][sS];
ASC : [aA][sS][cC];
ASCENDING : [aA][sS][cC][eE][nN][dD][iI][nN][gG];
ASIN : [aA][sS][iI][nN];
AT : [aA][tT];
ATAN : [aA][tT][aA][nN];
AVG : [aA][vV][gG];
BIG : [bB][iI][gG];
BIGINT : [bB][iI][gG][iI][nN][tT];
BINARY : [bB][iI][nN][aA][rR][yY];
BOOL : [bB][oO][oO][lL];
BOOLEAN : [bB][oO][oO][lL][eE][aA][nN];
BOTH : [bB][oO][tT][hH];
BTRIM : [bB][tT][rR][iI][mM];
BY : [bB][yY];
BYTE_LENGTH : [bB][yY][tT][eE][_][lL][eE][nN][gG][tT][hH];
BYTES : [bB][yY][tT][eE][sS];
CALL : [cC][aA][lL][lL];
CARDINALITY : [cC][aA][rR][dD][iI][nN][aA][lL][iI][tT][yY];
CASE : [cC][aA][sS][eE];
CAST : [cC][aA][sS][tT];
CEIL : [cC][eE][iI][lL];
CEILING : [cC][eE][iI][lL][iI][nN][gG];
CHAR : [cC][hH][aA][rR];
CHAR_LENGTH : [cC][hH][aA][rR][_][lL][eE][nN][gG][tT][hH];
CHARACTER_LENGTH : [cC][hH][aA][rR][aA][cC][tT][eE][rR][_][lL][eE][nN][gG][tT][hH];
CHARACTERISTICS : [cC][hH][aA][rR][aA][cC][tT][eE][rR][iI][sS][tT][iI][cC][sS];
CLOSE : [cC][lL][oO][sS][eE];
COALESCE : [cC][oO][aA][lL][eE][sS][cC][eE];
COLLECT_LIST : [cC][oO][lL][lL][eE][cC][tT][_][lL][iI][sS][tT];
COMMIT : [cC][oO][mM][mM][iI][tT];
COPY : [cC][oO][pP][yY];
COS : [cC][oO][sS];
COSH : [cC][oO][sS][hH];
COT : [cC][oO][tT];
COUNT : [cC][oO][uU][nN][tT];
CREATE : [cC][rR][eE][aA][tT][eE];
CURRENT_DATE : [cC][uU][rR][rR][eE][nN][tT][_][dD][aA][tT][eE];
CURRENT_GRAPH : [cC][uU][rR][rR][eE][nN][tT][_][gG][rR][aA][pP][hH];
CURRENT_PROPERTY_GRAPH : [cC][uU][rR][rR][eE][nN][tT][_][pP][rR][oO][pP][eE][rR][tT][yY][_][gG][rR][aA][pP][hH];
CURRENT_SCHEMA : [cC][uU][rR][rR][eE][nN][tT][_][sS][cC][hH][eE][mM][aA];
CURRENT_TIME : [cC][uU][rR][rR][eE][nN][tT][_][tT][iI][mM][eE];
CURRENT_TIMESTAMP : [cC][uU][rR][rR][eE][nN][tT][_][tT][iI][mM][eE][sS][tT][aA][mM][pP];
DATE : [dD][aA][tT][eE];
DATETIME : [dD][aA][tT][eE][tT][iI][mM][eE];
DAY : [dD][aA][yY];
DEC : [dD][eE][cC];
DECIMAL : [dD][eE][cC][iI][mM][aA][lL];
DEGREES : [dD][eE][gG][rR][eE][eE][sS];
DELETE : [dD][eE][lL][eE][tT][eE];
DESC : [dD][eE][sS][cC];
DESCENDING : [dD][eE][sS][cC][eE][nN][dD][iI][nN][gG];
DETACH : [dD][eE][tT][aA][cC][hH];
DISTINCT : [dD][iI][sS][tT][iI][nN][cC][tT];
DOUBLE : [dD][oO][uU][bB][lL][eE];
DROP : [dD][rR][oO][pP];
DURATION : [dD][uU][rR][aA][tT][iI][oO][nN];
DURATION_BETWEEN : [dD][uU][rR][aA][tT][iI][oO][nN][_][bB][eE][tT][wW][eE][eE][nN];
ELEMENT_ID : [eE][lL][eE][mM][eE][nN][tT][_][iI][dD];
ELSE : [eE][lL][sS][eE];
END : [eE][nN][dD];
EXCEPT : [eE][xX][cC][eE][pP][tT];
EXISTS : [eE][xX][iI][sS][tT][sS];
EXP : [eE][xX][pP];
FALSE : [fF][aA][lL][sS][eE];
FILTER : [fF][iI][lL][tT][eE][rR];
FINISH : [fF][iI][nN][iI][sS][hH];
FLOAT : [fF][lL][oO][aA][tT];
FLOAT16 : [fF][lL][oO][aA][tT][1][6];
FLOAT32 : [fF][lL][oO][aA][tT][3][2];
FLOAT64 : [fF][lL][oO][aA][tT][6][4];
FLOAT128 : [fF][lL][oO][aA][tT][1][2][8];
FLOAT256 : [fF][lL][oO][aA][tT][2][5][6];
FLOOR : [fF][lL][oO][oO][rR];
FOR : [fF][oO][rR];
FROM : [fF][rR][oO][mM];
GROUP : [gG][rR][oO][uU][pP];
HAVING : [hH][aA][vV][iI][nN][gG];
HOME_GRAPH : [hH][oO][mM][eE][_][gG][rR][aA][pP][hH];
HOME_PROPERTY_GRAPH : [hH][oO][mM][eE][_][pP][rR][oO][pP][eE][rR][tT][yY][_][gG][rR][aA][pP][hH];
HOME_SCHEMA : [hH][oO][mM][eE][_][sS][cC][hH][eE][mM][aA];
HOUR : [hH][oO][uU][rR];
IF : [iI][fF];
IMPLIES : [iI][mM][pP][lL][iI][eE][sS];
IN : [iI][nN];
INSERT : [iI][nN][sS][eE][rR][tT];
INT : [iI][nN][tT];
INTEGER : [iI][nN][tT][eE][gG][eE][rR];
INT8 : [iI][nN][tT][8];
INTEGER8 : [iI][nN][tT][eE][gG][eE][rR][8];
INT16 : [iI][nN][tT][1][6];
INTEGER16 : [iI][nN][tT][eE][gG][eE][rR][1][6];
INT32 : [iI][nN][tT][3][2];
INTEGER32 : [iI][nN][tT][eE][gG][eE][rR][3][2];
INT64 : [iI][nN][tT][6][4];
INTEGER64 : [iI][nN][tT][eE][gG][eE][rR][6][4];
INT128 : [iI][nN][tT][1][2][8];
INTEGER128 : [iI][nN][tT][eE][gG][eE][rR][1][2][8];
INT256 : [iI][nN][tT][2][5][6];
INTEGER256 : [iI][nN][tT][eE][gG][eE][rR][2][5][6];
INTERSECT : [iI][nN][tT][eE][rR][sS][eE][cC][tT];
INTERVAL : [iI][nN][tT][eE][rR][vV][aA][lL];
IS : [iI][sS];
LEADING : [lL][eE][aA][dD][iI][nN][gG];
LEFT : [lL][eE][fF][tT];
LET : [lL][eE][tT];
LIKE : [lL][iI][kK][eE];
LIMIT : [lL][iI][mM][iI][tT];
LIST : [lL][iI][sS][tT];
LN : [lL][nN];
LOCAL : [lL][oO][cC][aA][lL];
LOCAL_DATETIME : [lL][oO][cC][aA][lL][_][dD][aA][tT][eE][tT][iI][mM][eE];
LOCAL_TIME : [lL][oO][cC][aA][lL][_][tT][iI][mM][eE];
LOCAL_TIMESTAMP : [lL][oO][cC][aA][lL][_][tT][iI][mM][eE][sS][tT][aA][mM][pP];
LOG : [lL][oO][gG];
LOG10 : [lL][oO][gG][1][0];
LOWER : [lL][oO][wW][eE][rR];
LTRIM : [lL][tT][rR][iI][mM];
MATCH : [mM][aA][tT][cC][hH];
MAX : [mM][aA][xX];
MIN : [mM][iI][nN];
MINUTE : [mM][iI][nN][uU][tT][eE];
MOD : [mM][oO][dD];
MONTH : [mM][oO][nN][tT][hH];
NEXT : [nN][eE][xX][tT];
NODETACH : [nN][oO][dD][eE][tT][aA][cC][hH];
NORMALIZE : [nN][oO][rR][mM][aA][lL][iI][zZ][eE];
NOT : [nN][oO][tT];
NOTHING : [nN][oO][tT][hH][iI][nN][gG];
NULL : [nN][uU][lL][lL];
NULLS : [nN][uU][lL][lL][sS];
NULLIF : [nN][uU][lL][lL][iI][fF];
OCTET_LENGTH : [oO][cC][tT][eE][tT][_][lL][eE][nN][gG][tT][hH];
OF : [oO][fF];
OFFSET : [oO][fF][fF][sS][eE][tT];
OPTIONAL : [oO][pP][tT][iI][oO][nN][aA][lL];
OR : [oO][rR];
ORDER : [oO][rR][dD][eE][rR];
OTHERWISE : [oO][tT][hH][eE][rR][wW][iI][sS][eE];
PARAMETER : [pP][aA][rR][aA][mM][eE][tT][eE][rR];
PARAMETERS : [pP][aA][rR][aA][mM][eE][tT][eE][rR][sS];
PATH : [pP][aA][tT][hH];
PATH_LENGTH : [pP][aA][tT][hH][_][lL][eE][nN][gG][tT][hH];
PATHS : [pP][aA][tT][hH][sS];
PERCENTILE_CONT : [pP][eE][rR][cC][eE][nN][tT][iI][lL][eE][_][cC][oO][nN][tT];
PERCENTILE_DISC : [pP][eE][rR][cC][eE][nN][tT][iI][lL][eE][_][dD][iI][sS][cC];
POWER : [pP][oO][wW][eE][rR];
PRECISION : [pP][rR][eE][cC][iI][sS][iI][oO][nN];
PROPERTY_EXISTS : [pP][rR][oO][pP][eE][rR][tT][yY][_][eE][xX][iI][sS][tT][sS];
RADIANS : [rR][aA][dD][iI][aA][nN][sS];
REAL : [rR][eE][aA][lL];
RECORD : [rR][eE][cC][oO][rR][dD];
REMOVE : [rR][eE][mM][oO][vV][eE];
REPLACE : [rR][eE][pP][lL][aA][cC][eE];
RESET : [rR][eE][sS][eE][tT];
RETURN : [rR][eE][tT][uU][rR][nN];
RIGHT : [rR][iI][gG][hH][tT];
ROLLBACK : [rR][oO][lL][lL][bB][aA][cC][kK];
RTRIM : [rR][tT][rR][iI][mM];
SAME : [sS][aA][mM][eE];
SCHEMA : [sS][cC][hH][eE][mM][aA];
SECOND : [sS][eE][cC][oO][nN][dD];
SELECT : [sS][eE][lL][eE][cC][tT];
SESSION : [sS][eE][sS][sS][iI][oO][nN];
SESSION_USER : [sS][eE][sS][sS][iI][oO][nN][_][uU][sS][eE][rR];
SET : [sS][eE][tT];
SIGNED : [sS][iI][gG][nN][eE][dD];
SIN : [sS][iI][nN];
SINH : [sS][iI][nN][hH];
SIZE : [sS][iI][zZ][eE];
SKIP_TOKEN : [sS][kK][iI][pP];
SMALL : [sS][mM][aA][lL][lL];
SMALLINT : [sS][mM][aA][lL][lL][iI][nN][tT];
SQRT : [sS][qQ][rR][tT];
START : [sS][tT][aA][rR][tT];
STDDEV_POP : [sS][tT][dD][dD][eE][vV][_][pP][oO][pP];
STDDEV_SAMP : [sS][tT][dD][dD][eE][vV][_][sS][aA][mM][pP];
STRING : [sS][tT][rR][iI][nN][gG];
SUM : [sS][uU][mM];
TAN : [tT][aA][nN];
TANH : [tT][aA][nN][hH];
THEN : [tT][hH][eE][nN];
TIME : [tT][iI][mM][eE];
TIMESTAMP : [tT][iI][mM][eE][sS][tT][aA][mM][pP];
TRAILING : [tT][rR][aA][iI][lL][iI][nN][gG];
TRIM : [tT][rR][iI][mM];
TRUE : [tT][rR][uU][eE];
TYPED : [tT][yY][pP][eE][dD];
UBIGINT : [uU][bB][iI][gG][iI][nN][tT];
UINT : [uU][iI][nN][tT];
UINT8 : [uU][iI][nN][tT][8];
UINT16 : [uU][iI][nN][tT][1][6];
UINT32 : [uU][iI][nN][tT][3][2];
UINT64 : [uU][iI][nN][tT][6][4];
UINT128 : [uU][iI][nN][tT][1][2][8];
UINT256 : [uU][iI][nN][tT][2][5][6];
UNION : [uU][nN][iI][oO][nN];
UNKNOWN : [uU][nN][kK][nN][oO][wW][nN];
UNSIGNED : [uU][nN][sS][iI][gG][nN][eE][dD];
UPPER : [uU][pP][pP][eE][rR];
USE : [uU][sS][eE];
USMALLINT : [uU][sS][mM][aA][lL][lL][iI][nN][tT];
VALUE : [vV][aA][lL][uU][eE];
VARBINARY : [vV][aA][rR][bB][iI][nN][aA][rR][yY];
VARCHAR : [vV][aA][rR][cC][hH][aA][rR];
VARIABLE : [vV][aA][rR][iI][aA][bB][lL][eE];
WHEN : [wW][hH][eE][nN];
WHERE : [wW][hH][eE][rR][eE];
WITH : [wW][iI][tT][hH];
XOR : [xX][oO][rR];
YEAR : [yY][eE][aA][rR];
YIELD : [yY][iI][eE][lL][dD];
ZONED : [zZ][oO][nN][eE][dD];
ZONED_DATETIME : [zZ][oO][nN][eE][dD][_][dD][aA][tT][eE][tT][iI][mM][eE];
ZONED_TIME : [zZ][oO][nN][eE][dD][_][tT][iI][mM][eE];
// NON-RESERVED WORD
ACYCLIC : [aA][cC][yY][cC][lL][iI][cC];
BINDING : [bB][iI][nN][dD][iI][nN][gG];
BINDINGS : [bB][iI][nN][dD][iI][nN][gG][sS];
CONNECTING : [cC][oO][nN][nN][eE][cC][tT][iI][nN][gG];
DESTINATION : [dD][eE][sS][tT][iI][nN][aA][tT][iI][oO][nN];
DIFFERENT : [dD][iI][fF][fF][eE][rR][eE][nN][tT];
DIRECTED : [dD][iI][rR][eE][cC][tT][eE][dD];
EDGE : [eE][dD][gG][eE];
EDGES : [eE][dD][gG][eE][sS];
ELEMENT : [eE][lL][eE][mM][eE][nN][tT];
ELEMENTS : [eE][lL][eE][mM][eE][nN][tT][sS];
FIRST : [fF][iI][rR][sS][tT];
GRAPH : [gG][rR][aA][pP][hH];
GROUPS : [gG][rR][oO][uU][pP][sS];
KEEP : [kK][eE][eE][pP];
LABEL : [lL][aA][bB][eE][lL];
LABELED : [lL][aA][bB][eE][lL][eE][dD];
LABELS : [lL][aA][bB][eE][lL][sS];
LAST : [lL][aA][sS][tT];
NFC : [nN][fF][cC];
NFD : [nN][fF][dD];
NFKC : [nN][fF][kK][cC];
NFKD : [nN][fF][kK][dD];
NO : [nN][oO];
NODE : [nN][oO][dD][eE];
NORMALIZED : [nN][oO][rR][mM][aA][lL][iI][zZ][eE][dD];
ONLY : [oO][nN][lL][yY];
ORDINALITY : [oO][rR][dD][iI][nN][aA][lL][iI][tT][yY];
PROPERTY : [pP][rR][oO][pP][eE][rR][tT][yY];
READ : [rR][eE][aA][dD];
RELATIONSHIP : [rR][eE][lL][aA][tT][iI][oO][nN][sS][hH][iI][pP];
RELATIONSHIPS : [rR][eE][lL][aA][tT][iI][oO][nN][sS][hH][iI][pP][sS];
REPEATABLE : [rR][eE][pP][eE][aA][tT][aA][bB][lL][eE];
SHORTEST : [sS][hH][oO][rR][tT][eE][sS][tT];
SIMPLE : [sS][iI][mM][pP][lL][eE];
SOURCE : [sS][oO][uU][rR][cC][eE];
TABLE : [tT][aA][bB][lL][eE];
TEMP : [tT][eE][mM][pP];
TO : [tT][oO];
TRAIL : [tT][rR][aA][iI][lL];
TRANSACTION : [tT][rR][aA][nN][sS][aA][cC][tT][iI][oO][nN];
TYPE : [tT][yY][pP][eE];
UNDIRECTED : [uU][nN][dD][iI][rR][eE][cC][tT][eE][dD];
VERTEX : [vV][eE][rR][tT][eE][xX];
WALK : [wW][aA][lL][kK];
WITHOUT : [wW][iI][tT][hH][oO][uU][tT];
WRITE : [wW][rR][iI][tT][eE];
ZONE : [zZ][oO][nN][eE];

// ---------------------------------------------------------------------
// REGULAR IDENTIFIER
// NOTE:
// IT NEED TO BE DEFINED BEFORE THE SPECIAL CHARACTER
// BECAUSE WE THINK _ IS LIKELY TO BE USED AS REGULAR IDENTIFIER, BUT NOT JUST AN UNDERSCORE
REGULAR_IDENTIFIER
    // <identifier start> [ <identifier extend>... ]
    : [a-zA-Z_][a-zA-Z_0-9]*
    ;

// ---------------------------------------------------------------------
// BYTE STRING
//BYTE_STRING
//    : 'X' QUOTE SPACE*  QUOTE
//    ;

//fragment ByteStringPrefix : [xX];

// ---------------------------------------------------------------------
// DIGIT
// SPECIAL CASE NEEDING TO CHECK FIRST
UNSIGNED_DECIMAL_INTEGER
    : DecimalNumber
    ;
UNSIGNED_HEXADECIMAL_INTEGER
    : HexadecimalPrefix HEXADECIMALDIGIT (UNDERSCORE? HEXADECIMALDIGIT)*
    ;
UNSIGNED_OCTAL_INTEGER
    : OctalPrefix OCTALDIGIT (UNDERSCORE? OCTALDIGIT)*
    ;
UNSIGNED_BINARY_INTEGER
    : BinaryPrefix BINARYDIGIT (UNDERSCORE? BINARYDIGIT)*
    ;
// OTHER TYPE OF NUMERIC LITERAL
UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION
    : DecimalNumber [eE] SIGN? DecimalNumber
    | UNSIGNED_DECIMAL_IN_COMMON_NOTATION [eE] SIGN? DecimalNumber
    ;
UNSIGNED_DECIMAL_IN_COMMON_NOTATION
    : DecimalNumber PERIOD DecimalNumber?
    | PERIOD DecimalNumber
    ;
EXACT_NUMERIC_LITERAL
    : UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION ExactNumberSuffix
    | UNSIGNED_DECIMAL_IN_COMMON_NOTATION ExactNumberSuffix
    | UNSIGNED_DECIMAL_INTEGER ExactNumberSuffix
    ;
APPROXIMATE_NUMERIC_LITERAL
    : UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION ApproximateNumberSuffix
    | UNSIGNED_DECIMAL_IN_COMMON_NOTATION ApproximateNumberSuffix
    | UNSIGNED_DECIMAL_INTEGER ApproximateNumberSuffix
    ;

fragment DecimalNumber : DIGIT (UNDERSCORE? DIGIT)*;
fragment HexadecimalPrefix : '0x';
fragment OctalPrefix : '0o';
fragment BinaryPrefix : '0b';
fragment ExactNumberSuffix : [mM];
fragment ApproximateNumberSuffix : [dfDF];
fragment SIGN : [+-];
fragment DIGIT : [0-9];
fragment OCTALDIGIT : [0-7];
fragment HEXADECIMALDIGIT : [0-9a-fA-F];
fragment BINARYDIGIT : [01];

// ---------------------------------------------------------------------
// CHARACTER STRING
// NORMAL CASE WITH ESCAPE CHARACTERS
SINGLE_QUOTED_CHARACTER_SEQUENCE
    : QUOTE (SingleQuotedStringLiteralCharacter | EscapeCharacter | DOUBLE_SINGLE_QUOTE)* QUOTE
    ;
DOUBLE_QUOTED_CHARACTER_SEQUENCE
    : DOUBLE_QUOTE (DoubleQuotedStringLiteralCharacter | EscapeCharacter | DOUBLE_DOUBLE_QUOTE)* DOUBLE_QUOTE
    ;
ACCENT_QUOTED_CHARACTER_SEQUENCE
    : GRAVE_ACCENT (AccentQuotedStringLiteralCharacter | EscapeCharacter | DOUBLE_GRAVE_ACCENT)* GRAVE_ACCENT
    ;
// NO ESCAPE
NO_ESCAPE_SINGLE_QUOTED_CHARACTER_SEQUENCE
    : NoEscapePrefix QUOTE (SingleQuotedStringLiteralCharacter | '\\' | DOUBLE_SINGLE_QUOTE)* QUOTE
    ;
NO_ESCAPE_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    : NoEscapePrefix DOUBLE_QUOTE (DoubleQuotedStringLiteralCharacter | '\\' | DOUBLE_DOUBLE_QUOTE)* DOUBLE_QUOTE
    ;
NO_ESCAPE_ACCENT_QUOTED_CHARACTER_SEQUENCE
    : NoEscapePrefix GRAVE_ACCENT (AccentQuotedStringLiteralCharacter | '\\' | DOUBLE_GRAVE_ACCENT)* GRAVE_ACCENT
    ;

fragment NoEscapePrefix : COMMERCIAL_AT;

fragment SingleQuotedStringLiteralCharacter : ~['\\];
fragment DoubleQuotedStringLiteralCharacter : ~["\\];
fragment AccentQuotedStringLiteralCharacter : ~[`\\];
fragment EscapeCharacter
    : EscapeReverseSolidus
    | EscapeQuote
    | EscapeDoubleQuote
    | EscapeGraveAccent
    | EscapeTab
    | EscapeBackspace
    | EscapeNewline
    | EscapeCarriageReturn
    | EscapeFormFeed
    | UnicodeEscapeValue
    ;
fragment EscapeReverseSolidus : REVERSE_SOLIDUS REVERSE_SOLIDUS;
fragment EscapeQuote : REVERSE_SOLIDUS QUOTE;
fragment EscapeDoubleQuote : REVERSE_SOLIDUS DOUBLE_QUOTE;
fragment EscapeGraveAccent : REVERSE_SOLIDUS GRAVE_ACCENT;
fragment EscapeTab : REVERSE_SOLIDUS 't';
fragment EscapeBackspace : REVERSE_SOLIDUS 'b';
fragment EscapeNewline : REVERSE_SOLIDUS 'n';
fragment EscapeCarriageReturn : REVERSE_SOLIDUS 'r';
fragment EscapeFormFeed : REVERSE_SOLIDUS 'f';
fragment UnicodeEscapeValue
    : Unicode4DigitEscapeValue
    | Unicode6DigitEscapeValue
    ;
fragment Unicode4DigitEscapeValue
    : REVERSE_SOLIDUS 'u' HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT
    ;
fragment Unicode6DigitEscapeValue
    : REVERSE_SOLIDUS 'U' HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT HEXADECIMALDIGIT
    ;

// ---------------------------------------------------------------------
// TOKEN WITH SPECIAL CHARACTERS
MULTISET_ALTERNATION_OPERATOR : '|+|';
BRACKET_RIGHT_ARROW : ']->';
BRACKET_TILDE_RIGHT_ARROW : ']~>';
CONCATENATION_OPERATOR : '||';
DOUBLE_COLON : '::';
DOUBLE_DOLLAR_SIGN : '$$';
DOUBLE_MINUS_SIGN : '--';
DOUBLE_PERIOD : '..';
// GREATER_THAN_OPERATOR : RIGHT_ANGLE_BRACKET;
GREATER_THAN_OR_EQUALS_OPERATOR : '>=';
LEFT_ARROW : '<-';
LEFT_ARROW_TILDE : '<~';
LEFT_ARROW_BRACKET : '<-[';
LEFT_ARROW_TILDE_BRACKET : '<~[';
LEFT_MINUS_RIGHT : '<->';
LEFT_MINUS_SLASH : '<-/';
LEFT_TILDE_SLASH : '<~/';
// LESS_THAN_OPERATOR : LEFT_ANGLE_BRACKET;
LESS_THAN_OR_EQUALS_OPERATOR : '<=';
MINUS_LEFT_BRACKET : '-[';
MINUS_SLASH : '-/';
NOT_EQUALS_OPERATOR : '<>';
RIGHT_ARROW : '->';
RIGHT_BRACKET_MINUS : ']-';
RIGHT_BRACKET_TILDE : ']~';
RIGHT_DOUBLE_ARROW : '=>';
SLASH_MINUS : '/-';
SLASH_MINUS_RIGHT : '/->';
SLASH_TILDE : '/~';
SLASH_TILDE_RIGHT : '/~>';
TILDE_LEFT_BRACKET : '~[';
TILDE_RIGHT_ARROW : '~>';
TILDE_SLASH : '~/';
DOUBLE_SINGLE_QUOTE : '\'\'';
DOUBLE_DOUBLE_QUOTE : '""';
DOUBLE_GRAVE_ACCENT : '``';

// ---------------------------------------------------------------------
// WHITESPACE
WS : [ \t\r\n]+ -> skip ;

// ---------------------------------------------------------------------
// SPECIAL CHARACTER
// NOTE:
// THE ANTLR ALWAYS TRY TO MATCH THE LONGEST TOKEN
SPACE : ' ';
AMPERSAND : '&';
ASTERISK : '*';
COLON : ':';
COMMA : ',';
COMMERCIAL_AT : '@';
DOLLAR_SIGN : '$';
DOUBLE_QUOTE : '"';
EQUALS_OPERATOR : '=';
EXCLAMATION_MARK : '!';
RIGHT_ANGLE_BRACKET : '>';
GRAVE_ACCENT : '`';
LEFT_BRACE : '{';
LEFT_BRACKET : '[';
LEFT_PAREN : '(';
LEFT_ANGLE_BRACKET : '<';
MINUS_SIGN : '-';
PERCENT : '%';
PERIOD : '.';
PLUS_SIGN : '+';
QUESTION_MARK : '?';
QUOTE : '\'';
REVERSE_SOLIDUS : '\\';
RIGHT_BRACE : '}';
RIGHT_BRACKET : ']';
RIGHT_PAREN : ')';
SOLIDUS : '/';
TILDE : '~';
UNDERSCORE : '_';
VERTICAL_BAR : '|';

// TODO: support more digits or languages
// OTHER_DIGIT : '\uFFFE';
// OTHER_LANGUAGE_CHARACTER : '\uFFFF';
