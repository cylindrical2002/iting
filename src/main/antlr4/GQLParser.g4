/*
Copyright (c) 2024 Yue Chen
All rights reserved.
*/

parser grammar GQLParser;

options {
    tokenVocab = GQLLexer;
}

// literal
// boolean literal
boolean_literal
    : TRUE
    | FALSE
    | UNKNOWN
    ;
// numeric literal
signed_numeric_literal
    : (PLUS_SIGN | MINUS_SIGN)? unsigned_numeric_literal
    ;
unsigned_numeric_literal
    : exact_numeric_literal
    | approximate_numeric_literal
    ;
exact_numeric_literal
    : EXACT_NUMERIC_LITERAL
    | UNSIGNED_DECIMAL_IN_COMMON_NOTATION
    | unsigned_integer
    ;
approximate_numeric_literal
    : APPROXIMATE_NUMERIC_LITERAL
    | UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION
    ;
unsigned_integer
    : UNSIGNED_DECIMAL_INTEGER
    | UNSIGNED_HEXADECIMAL_INTEGER
    | UNSIGNED_OCTAL_INTEGER
    | UNSIGNED_BINARY_INTEGER
    ;

// identifier
non__delimited_identifier
    : REGULAR_IDENTIFIER
//  | EXTENDED_IDENTIFIER
    ;

// keyword
keyword
    : reserved_word
    | non__reserved_word
    ;

non__reserved_word
    : ACYCLIC
    | BINDING
    | BINDINGS
    | CONNECTING
    | DESTINATION
    | DIFFERENT
    | DIRECTED
    | EDGE
    | EDGES
    | ELEMENT
    | ELEMENTS
    | FIRST
    | GRAPH
    | GROUPS
    | KEEP
    | LABEL
    | LABELED
    | LABELS
    | LAST
    | NFC
    | NFD
    | NFKC
    | NFKD
    | NO
    | NODE
    | NORMALIZED
    | ONLY
    | ORDINALITY
    | PROPERTY
    | READ
    | RELATIONSHIP
    | RELATIONSHIPS
    | REPEATABLE
    | SHORTEST
    | SIMPLE
    | SOURCE
    | TABLE
    | TEMP
    | TO
    | TRAIL
    | TRANSACTION
    | TYPE
    | UNDIRECTED
    | VERTEX
    | WALK
    | WITHOUT
    | WRITE
    | ZONE
    ;

reserved_word
    : pre__reserved_word
    | ABS
    | ACOS
    | ALL
    | ALL_DIFFERENT
    | AND
    | ANY
    | ARRAY
    | AS
    | ASC
    | ASCENDING
    | ASIN
    | AT
    | ATAN
    | AVG
    | BIG
    | BIGINT
    | BINARY
    | BOOL
    | BOOLEAN
    | BOTH
    | BTRIM
    | BY
    | BYTE_LENGTH
    | BYTES
    | CALL
    | CARDINALITY
    | CASE
    | CAST
    | CEIL
    | CEILING
    | CHAR
    | CHAR_LENGTH
    | CHARACTER_LENGTH
    | CHARACTERISTICS
    | CLOSE
    | COALESCE
    | COLLECT_LIST
    | COMMIT
    | COPY
    | COS
    | COSH
    | COT
    | COUNT
    | CREATE
    | CURRENT_DATE
    | CURRENT_GRAPH
    | CURRENT_PROPERTY_GRAPH
    | CURRENT_SCHEMA
    | CURRENT_TIME
    | CURRENT_TIMESTAMP
    | DATE
    | DATETIME
    | DAY
    | DEC
    | DECIMAL
    | DEGREES
    | DELETE
    | DESC
    | DESCENDING
    | DETACH
    | DISTINCT
    | DOUBLE
    | DROP
    | DURATION
    | DURATION_BETWEEN
    | ELEMENT_ID
    | ELSE
    | END
    | EXCEPT
    | EXISTS
    | EXP
    | FALSE
    | FILTER
    | FINISH
    | FLOAT
    | FLOAT16
    | FLOAT32
    | FLOAT64
    | FLOAT128
    | FLOAT256
    | FLOOR
    | FOR
    | FROM
    | GROUP
    | HAVING
    | HOME_GRAPH
    | HOME_PROPERTY_GRAPH
    | HOME_SCHEMA
    | HOUR
    | IF
    | IMPLIES
    | IN
    | INSERT
    | INT
    | INTEGER
    | INT8
    | INTEGER8
    | INT16
    | INTEGER16
    | INT32
    | INTEGER32
    | INT64
    | INTEGER64
    | INT128
    | INTEGER128
    | INT256
    | INTEGER256
    | INTERSECT
    | INTERVAL
    | IS
    | LEADING
    | LEFT
    | LET
    | LIKE
    | LIMIT
    | LIST
    | LN
    | LOCAL
    | LOCAL_DATETIME
    | LOCAL_TIME
    | LOCAL_TIMESTAMP
    | LOG
    | LOG10
    | LOWER
    | LTRIM
    | MATCH
    | MAX
    | MIN
    | MINUTE
    | MOD
    | MONTH
    | NEXT
    | NODETACH
    | NORMALIZE
    | NOT
    | NOTHING
    | NULL
    | NULLS
    | NULLIF
    | OCTET_LENGTH
    | OF
    | OFFSET
    | OPTIONAL
    | OR
    | ORDER
    | OTHERWISE
    | PARAMETER
    | PARAMETERS
    | PATH
    | PATH_LENGTH
    | PATHS
    | PERCENTILE_CONT
    | PERCENTILE_DISC
    | POWER
    | PRECISION
    | PROPERTY_EXISTS
    | RADIANS
    | REAL
    | RECORD
    | REMOVE
    | REPLACE
    | RESET
    | RETURN
    | RIGHT
    | ROLLBACK
    | RTRIM
    | SAME
    | SCHEMA
    | SECOND
    | SELECT
    | SESSION
    | SESSION_USER
    | SET
    | SIGNED
    | SIN
    | SINH
    | SIZE
    | SKIP_TOKEN
    | SMALL
    | SMALLINT
    | SQRT
    | START
    | STDDEV_POP
    | STDDEV_SAMP
    | STRING
    | SUM
    | TAN
    | TANH
    | THEN
    | TIME
    | TIMESTAMP
    | TRAILING
    | TRIM
    | TRUE
    | TYPED
    | UBIGINT
    | UINT
    | UINT8
    | UINT16
    | UINT32
    | UINT64
    | UINT128
    | UINT256
    | UNION
    | UNKNOWN
    | UNSIGNED
    | UPPER
    | USE
    | USMALLINT
    | VALUE
    | VARBINARY
    | VARCHAR
    | VARIABLE
    | WHEN
    | WHERE
    | WITH
    | XOR
    | YEAR
    | YIELD
    | ZONED
    | ZONED_DATETIME
    | ZONED_TIME
    ;

pre__reserved_word
    : ABSTRACT
    | AGGREGATE
    | AGGREGATES
    | ALTER
    | CATALOG
    | CLEAR
    | CLONE
    | CONSTRAINT
    | CURRENT_ROLE
    | CURRENT_USER
    | DATA
    | DIRECTORY
    | DRYRUN
    | EXACT
    | EXISTING
    | FUNCTION
    | GQLSTATUS
    | GRANT
    | INSTANT
    | INFINITY
    | NUMBER
    | NUMERIC
    | ON
    | OPEN
    | PARTITION
    | PROCEDURE
    | PRODUCT
    | PROJECT
    | SUBSTRING
    | SYSTEM_USER
    | TEMPORAL
    | UNIQUE
    | UNIT
    | VALUES
    | WHITESPACE
    ;

// synonym
edge_synonym
    : EDGE
    | RELATIONSHIP
    ;

edges_synonym
    : EDGES
    | RELATIONSHIPS
    ;

node_synonym:
    | NODE
    | VERTEX
    ;

// implies
implies
    : RIGHT_DOUBLE_ARROW
    | IMPLIES
    ;