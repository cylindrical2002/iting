/*
Copyright (c) 2024 Yue Chen
All rights reserved.
*/

parser grammar GQLParser;

options {
    tokenVocab = GQLLexer;
}

// ---------------------------------------------------------------------
// name, variable
authorization_identifier : identifier;
object_name : identifier;
object_name_or_binding_variable : REGULAR_IDENTIFIER;
directory_name : identifier;
schema_name : identifier;
graph_name
    : REGULAR_IDENTIFIER
    | delimited_graph_name
    ;
delimited_graph_name : delimited_identifier;
graph_type_name : identifier;
node_type_name : identifier;
edge_type_name : identifier;
binding_table_name
    : REGULAR_IDENTIFIER
    | delimited_binding_table_name
    ;
delimited_binding_table_name : delimited_identifier;
procedure_name : identifier;
label_name : identifier;
property_name : identifier;
field_name : identifier;
parameter_name : separated_identifier;
graph_pattern_variable
    : element_variable
    | path_or_subpath_variable
    ;
path_or_subpath_variable
    : path_variable
    | subpath_variable
    ;
element_variable : binding_variable;
path_variable : binding_variable;
subpath_variable : REGULAR_IDENTIFIER;
binding_variable : REGULAR_IDENTIFIER;

// ---------------------------------------------------------------------
// literal
literal
    : signed_numeric_literal
    | general_literal
    ;
unsigned_literal
    : unsigned_numeric_literal
    | general_literal
    ;
general_literal
    : boolean_literal
    | character_string_literal
    | BYTE_STRING_LITERAL
    | temporal_literal
    | duration_literal
    | null_literal
    ;

// ---------------------------------------------------------------------
// boolean literal
boolean_literal
    : TRUE
    | FALSE
    | UNKNOWN
    ;

// ---------------------------------------------------------------------
// character string literal
character_string_literal
    : single_quoted_character_sequence
    | double_quoted_character_sequence
    ;
single_quoted_character_sequence
    : SINGLE_QUOTED_CHARACTER_SEQUENCE
    | NO_ESCAPE_SINGLE_QUOTED_CHARACTER_SEQUENCE
    ;
double_quoted_character_sequence
    : DOUBLE_QUOTED_CHARACTER_SEQUENCE
    | NO_ESCAPE_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    ;
accent_quoted_character_sequence
    : ACCENT_QUOTED_CHARACTER_SEQUENCE
    | NO_ESCAPE_ACCENT_QUOTED_CHARACTER_SEQUENCE
    ;

// ---------------------------------------------------------------------
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

// ---------------------------------------------------------------------
// temporal literal
temporal_literal
    : date_literal
    | time_literal
    | datetime_literal
//  | SQL__DATETIME_LITERAL
    ;
date_literal : DATE date_string;
time_literal : TIME time_string;
datetime_literal : (DATETIME | TIMESTAMP) datetime_string;
date_string : character_string_literal;
time_string : character_string_literal;
datetime_string : character_string_literal;
time_zone_string : character_string_literal;
duration_literal
    : DURATION duration_string
//  | SQL__INTERVAL_LITERAL
    ;
duration_string : character_string_literal;

// ---------------------------------------------------------------------
// null literal
null_literal
    : NULL
    ;

// ---------------------------------------------------------------------
// token
token
    : delimiter_token
    | non__delimiter_token
    ;
non__delimiter_token
    : REGULAR_IDENTIFIER
    | substituted_parameter_reference
    | general_parameter_reference
    | keyword
    | unsigned_numeric_literal
    | BYTE_STRING_LITERAL
    | MULTISET_ALTERNATION_OPERATOR
    ;

// ---------------------------------------------------------------------
// identifier
identifier
    : REGULAR_IDENTIFIER
    | delimited_identifier
    ;
separated_identifier
    : EXTENDED_IDENTIFIER
    | delimited_identifier
    ;
non__delimited_identifier
    : REGULAR_IDENTIFIER
    | EXTENDED_IDENTIFIER
    ;
delimited_identifier
    : double_quoted_character_sequence
    | accent_quoted_character_sequence
    ;

// ---------------------------------------------------------------------
// parameter reference
substituted_parameter_reference : DOUBLE_DOLLAR_SIGN parameter_name;
general_parameter_reference : DOLLAR_SIGN parameter_name;

// ---------------------------------------------------------------------
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

// ---------------------------------------------------------------------
// delimiter token
delimiter_token
    : gql_special_character
    | BRACKET_RIGHT_ARROW
    | BRACKET_TILDE_RIGHT_ARROW
    | character_string_literal
    | CONCATENATION_OPERATOR
    | date_string
    | datetime_string
    | delimited_identifier
    | duration_string
    | greater_than_operator
    | GREATER_THAN_OR_EQUALS_OPERATOR
    | LEFT_ARROW
    | LEFT_ARROW_BRACKET
    | LEFT_ARROW_TILDE
    | LEFT_ARROW_TILDE_BRACKET
    | LEFT_MINUS_RIGHT
    | LEFT_MINUS_SLASH
    | LEFT_TILDE_SLASH
    | less_than_operator
    | LESS_THAN_OR_EQUALS_OPERATOR
    | MINUS_LEFT_BRACKET
    | MINUS_SLASH
    | NOT_EQUALS_OPERATOR
    | RIGHT_ARROW
    | RIGHT_BRACKET_MINUS
    | RIGHT_BRACKET_TILDE
    | RIGHT_DOUBLE_ARROW
    | SLASH_MINUS
    | SLASH_MINUS_RIGHT
    | SLASH_TILDE
    | SLASH_TILDE_RIGHT
    | TILDE_LEFT_BRACKET
    | TILDE_RIGHT_ARROW
    | TILDE_SLASH
    | time_string
    ;
greater_than_operator : RIGHT_ANGLE_BRACKET;
less_than_operator : LEFT_ANGLE_BRACKET;

// ---------------------------------------------------------------------
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

// ---------------------------------------------------------------------
// implies
implies
    : RIGHT_DOUBLE_ARROW
    | IMPLIES
    ;

// ---------------------------------------------------------------------
// gql special character
gql_special_character
    : SPACE
    | AMPERSAND
    | ASTERISK
    | COLON
    | EQUALS_OPERATOR
    | COMMA
    | COMMERCIAL_AT
    | DOLLAR_SIGN
    | DOUBLE_QUOTE
    | EXCLAMATION_MARK
    | GRAVE_ACCENT
    | RIGHT_ANGLE_BRACKET
    | LEFT_BRACE
    | LEFT_BRACKET
    | LEFT_PAREN
    | LEFT_ANGLE_BRACKET
    | MINUS_SIGN
    | PERIOD
    | PLUS_SIGN
    | QUESTION_MARK
    | QUOTE
    | REVERSE_SOLIDUS
    | RIGHT_BRACE
    | RIGHT_BRACKET
    | RIGHT_PAREN
    | SOLIDUS
    | UNDERSCORE
    | VERTICAL_BAR
    | PERCENT
    | TILDE
    ;