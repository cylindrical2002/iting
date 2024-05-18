/*
Copyright (c) 2024 Yue Chen
All rights reserved.
*/

parser grammar GQLParser;

options {
    tokenVocab = GQLLexer;
}

// *********************************************************************
// GQL program
gql_program
    : program_activity session_close_command?
    | session_close_command
    ;

program_activity
    : session_activity
    | transaction_activity
    ;

session_activity
    : session_reset_command+
    | session_set_command+ session_reset_command*
    ;

transaction_activity
    : start_transaction_command (procedure_specification end_transaction_command?)?
    | procedure_specification end_transaction_command?
    | end_transaction_command
    ;

end_transaction_command
    : rollback_command
    | commit_command
    ;

// *********************************************************************
// session set command
session_set_command
    : SESSION SET (session_set_schema_clause | session_set_graph_clause | session_set_time_zone_clause | session_set_parameter_clause)
    ;

session_set_schema_clause : SCHEMA schema_reference;

session_set_graph_clause : PROPERTY? GRAPH graph_expression;

session_set_time_zone_clause : TIME ZONE set_time_zone_value;

set_time_zone_value : time_zone_string;

session_set_parameter_clause
    : session_set_graph_parameter_clause
    | session_set_binding_table_parameter_clause
    | session_set_value_parameter_clause
    ;

session_set_graph_parameter_clause : PROPERTY? GRAPH session_set_parameter_name opt_typed_graph_initializer;

session_set_binding_table_parameter_clause : BINDING? TABLE session_set_parameter_name opt_typed_binding_table_initializer;

session_set_value_parameter_clause : VALUE session_set_parameter_name opt_typed_value_initializer;

session_set_parameter_name : (IF NOT EXISTS)? session_parameter_specification;

// ---------------------------------------------------------------------
// session reset command
session_reset_command : SESSION RESET session_reset_arguments?;

session_reset_arguments
    : ALL? (PARAMETERS | CHARACTERISTICS)
    | SCHEMA
    | PROPERTY? GRAPH
    | TIME ZONE
    | PARAMETER? session_parameter_specification
    ;

// ---------------------------------------------------------------------
// session close command
session_close_command : SESSION CLOSE;

// ---------------------------------------------------------------------
// session parameter specification
session_parameter_specification : general_parameter_reference;

// *********************************************************************
// start transaction command
start_transaction_command : START TRANSACTION transaction_characteristics?;

// ---------------------------------------------------------------------
// transaction characteristics
transaction_characteristics : transaction_mode (COMMA transaction_mode)*;

transaction_mode
    : transaction_access_mode
//  | implementation__defined_access_mode
    ;

transaction_access_mode
    : READ ONLY
    | READ WRITE
    ;

// todo: define implementation__defined_access_mode IE002
// implementation-defined access mode is not defined in the grammar

// ---------------------------------------------------------------------
// rollback command
rollback_command : ROLLBACK;

// ---------------------------------------------------------------------
// commit command
commit_command : COMMIT;

// *********************************************************************
// procedure specification
nested_procedure_specification : LEFT_BRACE procedure_specification RIGHT_BRACE;

// changed from the original grammar
// because the parser can't distinguish between a catalog-modifying procedure specification
// and a data-modifying procedure specification
// and query specification
procedure_specification : procedure_body;

catalog__modifying_procedure_specification : procedure_body;

nested_data__modifying_procedure_specification : LEFT_BRACE data__modifying_procedure_specification RIGHT_BRACE;

data__modifying_procedure_specification : procedure_body;

nested_query_specification : LEFT_BRACE query_specification RIGHT_BRACE;

query_specification : procedure_body;

// ---------------------------------------------------------------------
// procedure body
procedure_body : at_schema_clause? binding_variable_definition_block? statement_block;

binding_variable_definition_block : binding_variable_definition+;

binding_variable_definition
    : graph_variable_definition
    | binding_table_variable_definition
    | value_variable_definition
    ;

statement_block : statement next_statement*;

statement
    : linear_catalog__modifying_statement
    | linear_data__modifying_statement
    | composite_query_statement
    ;

next_statement : NEXT yield_clause? statement;

// *********************************************************************
// graph variable definition
graph_variable_definition : PROPERTY? GRAPH binding_variable opt_typed_graph_initializer;

opt_typed_graph_initializer : (typed? graph_reference_value_type)? graph_initializer;

graph_initializer : EQUALS_OPERATOR graph_expression;

// ---------------------------------------------------------------------
// binding table variable definition
binding_table_variable_definition : BINDING? TABLE binding_variable opt_typed_binding_table_initializer;

opt_typed_binding_table_initializer : (typed? binding_table_reference_value_type)? binding_table_initializer;

binding_table_initializer : EQUALS_OPERATOR binding_table_expression;

// ---------------------------------------------------------------------
// value variable definition
value_variable_definition : VALUE binding_variable opt_typed_value_initializer;

opt_typed_value_initializer : (typed? value_type)? value_initializer;

value_initializer : EQUALS_OPERATOR value_expression;

// *********************************************************************
// graph expression
graph_expression
    : object_expression_primary
    | graph_reference
    | object_name_or_binding_variable
    | current_graph
    ;

current_graph
    : CURRENT_PROPERTY_GRAPH
    | CURRENT_GRAPH
    ;

// ---------------------------------------------------------------------
// binding table expression
binding_table_expression
    : nested_binding_table_query_specification
    | object_expression_primary
    | binding_table_reference
    | object_name_or_binding_variable
    ;

nested_binding_table_query_specification : nested_query_specification;

// ---------------------------------------------------------------------
// object expression primary
object_expression_primary
    : VARIABLE value_expression_primary
    | parenthesized_value_expression
    | non__parenthesized_value_expression_primary_special_case
    ;

// *********************************************************************
// linear catalog-modifying statement
linear_catalog__modifying_statement : simple_catalog__modifying_statement+;

simple_catalog__modifying_statement
    : primitive_catalog__modifying_statement
    | call_catalog__modifying_procedure_statement
    ;

primitive_catalog__modifying_statement
    : create_schema_statement
    | drop_schema_statement
    | create_graph_statement
    | drop_graph_statement
    | create_graph_type_statement
    | drop_graph_type_statement
    ;

// ---------------------------------------------------------------------
// create schema statement
create_schema_statement : CREATE SCHEMA (IF NOT EXISTS)? catalog_schema_parent_and_name;

// ---------------------------------------------------------------------
// drop schema statement
drop_schema_statement : DROP SCHEMA (IF EXISTS)? catalog_schema_parent_and_name;

// ---------------------------------------------------------------------
// create graph statement
create_graph_statement
    : CREATE (PROPERTY? GRAPH (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH) catalog_graph_parent_and_name (open_graph_type | of_graph_type) graph_source?
    ;

open_graph_type : typed? ANY (PROPERTY? GRAPH)?;

of_graph_type
    : graph_type_like_graph
    | typed? graph_type_reference
    | typed? (PROPERTY? GRAPH)? nested_graph_type_specification
    ;

graph_type_like_graph : LIKE graph_expression;

graph_source : AS COPY OF graph_expression;

// ---------------------------------------------------------------------
// drop graph statement
drop_graph_statement : DROP PROPERTY? GRAPH (IF EXISTS)? catalog_graph_parent_and_name;

// ---------------------------------------------------------------------
// create graph type statement
create_graph_type_statement
    : CREATE (PROPERTY? GRAPH TYPE (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH TYPE) catalog_graph_type_parent_and_name graph_type_source
    ;

graph_type_source
    : AS? copy_of_graph_type
    | graph_type_like_graph
    | AS? nested_graph_type_specification
    ;

copy_of_graph_type : COPY OF (graph_type_reference | external_object_reference);

// ---------------------------------------------------------------------
// drop graph type statement
drop_graph_type_statement : DROP PROPERTY? GRAPH TYPE (IF EXISTS)? catalog_graph_type_parent_and_name;

// ---------------------------------------------------------------------
// call catalog-modifying procedure statement
call_catalog__modifying_procedure_statement : call_procedure_statement;

// *********************************************************************
// linear data-modifying statement
linear_data__modifying_statement
    : focused_linear_data__modifying_statement
    | ambient_linear_data__modifying_statement
    ;

focused_linear_data__modifying_statement
    : focused_linear_data__modifying_statement_body
    | focused_nested_data__modifying_procedure_specification
    ;

focused_linear_data__modifying_statement_body
    : use_graph_clause simple_linear_data__accessing_statement primitive_result_statement?
    ;

focused_nested_data__modifying_procedure_specification
    : use_graph_clause nested_data__modifying_procedure_specification
    ;

ambient_linear_data__modifying_statement
    : ambient_linear_data__modifying_statement_body
    | nested_data__modifying_procedure_specification
    ;

ambient_linear_data__modifying_statement_body
    : simple_linear_data__accessing_statement primitive_result_statement?
    ;

simple_linear_data__accessing_statement : simple_data__accessing_statement+;

simple_data__accessing_statement
    : simple_query_statement
    | simple_data__modifying_statement
    ;

simple_data__modifying_statement
    : primitive_data__modifying_statement
    | call_data__modifying_procedure_statement
    ;

primitive_data__modifying_statement
    : insert_statement
    | set_statement
    | remove_statement
    | delete_statement
    ;

// ---------------------------------------------------------------------
// insert statement
insert_statement : INSERT insert_graph_pattern;

// ---------------------------------------------------------------------
// set statement
set_statement : SET set_item_list;

set_item_list : set_item (COMMA set_item)*;

set_item
    : set_property_item
    | set_all_properties_item
    | set_label_item
    ;

set_property_item : binding_variable_reference PERIOD property_name EQUALS_OPERATOR value_expression;

set_all_properties_item : binding_variable_reference EQUALS_OPERATOR LEFT_BRACE property_key_value_pair_list? RIGHT_BRACE;

set_label_item : binding_variable_reference is_or_colon label_name;

// ---------------------------------------------------------------------
// remove statement
remove_statement : REMOVE remove_item_list;

remove_item_list : remove_item (COMMA remove_item)*;

remove_item
    : remove_property_item
    | remove_label_item
    ;

remove_property_item : binding_variable_reference PERIOD property_name;

remove_label_item : binding_variable_reference is_or_colon label_name;

// ---------------------------------------------------------------------
// delete statement
delete_statement : (DETACH | NODETACH)? DELETE delete_item_list;

delete_item_list : delete_item (COMMA delete_item)*;

delete_item : value_expression;

// ---------------------------------------------------------------------
// call data-modifying procedure statement
call_data__modifying_procedure_statement : call_procedure_statement;

// *********************************************************************
// composite query statement
composite_query_statement : composite_query_expression;

// ---------------------------------------------------------------------
// composite query expression
composite_query_expression
    : composite_query_expression query_conjunction composite_query_primary
    | composite_query_primary
    ;

query_conjunction
    : set_operator
    | OTHERWISE
    ;

set_operator
    : UNION set_quantifier?
    | EXCEPT set_quantifier?
    | INTERSECT set_quantifier?
    ;

composite_query_primary : linear_query_statement;

// ---------------------------------------------------------------------
// linear query statement and simple query statement
linear_query_statement
    : focused_linear_query_statement
    | ambient_linear_query_statement
    ;

focused_linear_query_statement
    : focused_linear_query_statement_part* focused_linear_query_and_primitive_result_statement_part
    | focused_primitive_result_statement
    | focused_nested_query_specification
    | select_statement
    ;

focused_linear_query_statement_part : use_graph_clause simple_linear_query_statement;

focused_linear_query_and_primitive_result_statement_part : use_graph_clause simple_linear_query_statement primitive_result_statement;

focused_primitive_result_statement : use_graph_clause primitive_result_statement;

focused_nested_query_specification : use_graph_clause nested_query_specification;

ambient_linear_query_statement
    : simple_linear_query_statement? primitive_result_statement
    | nested_query_specification
    ;

simple_linear_query_statement : simple_query_statement+;

simple_query_statement
    : primitive_query_statement
    | call_query_statement
    ;

primitive_query_statement
    : match_statement
    | let_statement
    | for_statement
    | filter_statement
    | order_by_and_page_statement
    ;

// ---------------------------------------------------------------------
// match statement
match_statement
    : simple_match_statement
    | optional_match_statement
    ;

simple_match_statement : MATCH graph_pattern_binding_table;

optional_match_statement : OPTIONAL optional_operand;

optional_operand
    : simple_match_statement
    | LEFT_BRACE match_statement_block RIGHT_BRACE
    | LEFT_PAREN match_statement_block RIGHT_PAREN
    ;

match_statement_block : match_statement+;

// ---------------------------------------------------------------------
// call query statement
call_query_statement : call_procedure_statement;

// ---------------------------------------------------------------------
// filter statement
filter_statement : FILTER (where_clause | search_condition);

// ---------------------------------------------------------------------
// let statement
let_statement : LET let_variable_definition_list;

let_variable_definition_list : let_variable_definition (COMMA let_variable_definition)*;

let_variable_definition
    : value_variable_definition
    | binding_variable EQUALS_OPERATOR value_expression
    ;

// ---------------------------------------------------------------------
// for statement
for_statement : FOR for_item for_ordinality_or_offset?;

for_item : for_item_alias for_item_source;

for_item_alias : binding_variable IN;

for_item_source
    : list_value_expression
    | binding_table_reference_value_expression
    ;

for_ordinality_or_offset : WITH (ORDINALITY | OFFSET) binding_variable;

// ---------------------------------------------------------------------
// order by and page statement
order_by_and_page_statement
    : order_by_clause offset_clause? limit_clause?
    | offset_clause limit_clause?
    | limit_clause
    ;

// ---------------------------------------------------------------------
// primitive result statement
primitive_result_statement
    : return_statement order_by_and_page_statement?
    | FINISH
    ;

// ---------------------------------------------------------------------
// return statement
return_statement : RETURN return_statement_body;

return_statement_body
    : set_quantifier? (ASTERISK | return_item_list) group_by_clause?
    | NO BINDINGS
    ;

return_item_list : return_item (COMMA return_item)*;

return_item : aggregating_value_expression return_item_alias?;

return_item_alias : AS identifier;

// ---------------------------------------------------------------------
// select statement
select_statement
    : SELECT set_quantifier? (ASTERISK | select_item_list)
    (select_statement_body where_clause? group_by_clause? having_clause? order_by_clause? offset_clause? limit_clause?)?
    ;

select_item_list : select_item (COMMA select_item)*;

select_item : aggregating_value_expression select_item_alias?;

select_item_alias : AS identifier;

having_clause : HAVING search_condition;

select_statement_body : FROM (select_graph_match_list | select_query_specification);

select_graph_match_list : select_graph_match (COMMA select_graph_match)*;

select_graph_match : graph_expression match_statement;

select_query_specification
    : nested_query_specification
    | graph_expression nested_query_specification
    ;

// *********************************************************************
// call procedure statement and procedure call
call_procedure_statement : OPTIONAL? CALL procedure_call;

procedure_call
    : inline_procedure_call
    | named_procedure_call
    ;

// ---------------------------------------------------------------------
// inline procedure call
inline_procedure_call : variable_scope_clause? nested_procedure_specification;

variable_scope_clause : LEFT_PAREN binding_variable_reference_list? RIGHT_PAREN;

binding_variable_reference_list : binding_variable_reference (COMMA binding_variable_reference)*;

// ---------------------------------------------------------------------
// named procedure call
named_procedure_call : procedure_reference LEFT_PAREN procedure_argument_list? RIGHT_PAREN yield_clause?;

procedure_argument_list : procedure_argument (COMMA procedure_argument)*;

procedure_argument : value_expression;

// *********************************************************************
// at schema clause
at_schema_clause : AT schema_reference;

// ---------------------------------------------------------------------
// use graph clause
use_graph_clause : USE graph_expression;

// ---------------------------------------------------------------------
// graph pattern binding table
graph_pattern_binding_table : graph_pattern graph_pattern_yield_clause?;

graph_pattern_yield_clause : YIELD graph_pattern_yield_item_list;

graph_pattern_yield_item_list
    : graph_pattern_yield_item (COMMA graph_pattern_yield_item)*
    | NO BINDINGS
    ;

graph_pattern_yield_item
    : element_variable_reference
    | path_variable_reference
    ;

// ---------------------------------------------------------------------
// graph pattern
graph_pattern : match_mode? path_pattern_list keep_clause? graph_pattern_where_clause?;

match_mode
    : repeatable_elements_match_mode
    | different_edges_match_mode
    ;

repeatable_elements_match_mode : REPEATABLE element_bindings_or_elements;

different_edges_match_mode : DIFFERENT edge_bindings_or_edges;

element_bindings_or_elements
    : ELEMENT BINDINGS?
    | ELEMENTS
    ;

edge_bindings_or_edges
    : edge_synonym BINDINGS?
    | edges_synonym
    ;

path_pattern_list : path_pattern (COMMA path_pattern)*;

path_pattern : path_variable_declaration? path_pattern_prefix? path_pattern_expression;

path_variable_declaration : path_variable EQUALS_OPERATOR;

keep_clause : KEEP path_pattern_prefix;

graph_pattern_where_clause : WHERE search_condition;

// ---------------------------------------------------------------------
// insert graph pattern
insert_graph_pattern : insert_path_pattern_list;

insert_path_pattern_list : insert_path_pattern (COMMA insert_path_pattern)*;

insert_path_pattern : insert_node_pattern (insert_edge_pattern insert_node_pattern)*;

insert_node_pattern : LEFT_PAREN insert_element_pattern_filler? RIGHT_PAREN;

insert_edge_pattern
    : insert_edge_pointing_left
    | insert_edge_pointing_right
    | insert_edge_undirected
    ;

insert_edge_pointing_left : LEFT_ARROW_BRACKET insert_element_pattern_filler? RIGHT_BRACKET_MINUS;

insert_edge_pointing_right : MINUS_LEFT_BRACKET insert_element_pattern_filler? BRACKET_RIGHT_ARROW;

insert_edge_undirected : TILDE_LEFT_BRACKET insert_element_pattern_filler? RIGHT_BRACKET_TILDE;

insert_element_pattern_filler
    : element_variable_declaration label_and_property_set_specification?
    | element_variable_declaration? label_and_property_set_specification
    ;

label_and_property_set_specification
    : is_or_colon label_set_specification element_property_specification?
    | (is_or_colon label_set_specification)? element_property_specification
    ;

// ---------------------------------------------------------------------
// path pattern prefix
path_pattern_prefix
    : path_mode_prefix
    | path_search_prefix
    ;

path_mode_prefix : path_mode path_or_paths?;

path_mode
    : WALK
    | TRAIL
    | SIMPLE
    | ACYCLIC
    ;

path_search_prefix
    : all_path_search
    | any_path_search
    | shortest_path_search
    ;

all_path_search : ALL path_mode? path_or_paths?;

path_or_paths
    : PATH
    | PATHS
    ;

any_path_search : ANY number_of_paths? path_mode? path_or_paths?;

number_of_paths : non__negative_integer_specification;

shortest_path_search
    : all_shortest_path_search
    | any_shortest_path_search
    | counted_shortest_path_search
    | counted_shortest_group_search
    ;

all_shortest_path_search : ALL SHORTEST path_mode? path_or_paths?;

any_shortest_path_search : ANY SHORTEST path_mode? path_or_paths?;

counted_shortest_path_search : SHORTEST number_of_paths path_mode? path_or_paths?;

counted_shortest_group_search : SHORTEST number_of_groups? path_mode? path_or_paths? (GROUP | GROUPS);

number_of_groups : non__negative_integer_specification;

// ---------------------------------------------------------------------
// path pattern expression
path_pattern_expression
    : path_term
    | path_multiset_alternation
    | path_pattern_union
    ;

path_multiset_alternation : path_term MULTISET_ALTERNATION_OPERATOR path_term (MULTISET_ALTERNATION_OPERATOR path_term)*;

path_pattern_union : path_term VERTICAL_BAR path_term (VERTICAL_BAR path_term)*;

path_term
    : path_factor
    | path_concatenation
    ;

path_concatenation : path_factor path_term;

path_factor
    : path_primary
    | quantified_path_primary
    | questioned_path_primary
    ;

quantified_path_primary : path_primary graph_pattern_quantifier;

questioned_path_primary : path_primary QUESTION_MARK;

path_primary
    : element_pattern
    | parenthesized_path_pattern_expression
    | simplified_path_pattern_expression
    ;

element_pattern
    : node_pattern
    | edge_pattern
    ;

node_pattern : LEFT_PAREN element_pattern_filler RIGHT_PAREN;

element_pattern_filler : element_variable_declaration? is_label_expression? element_pattern_predicate?;

element_variable_declaration : TEMP? element_variable;

is_label_expression : is_or_colon label_expression;

is_or_colon
    : IS
    | COLON
    ;

element_pattern_predicate
    : element_pattern_where_clause
    | element_property_specification
    ;

element_pattern_where_clause : WHERE search_condition;

element_property_specification : LEFT_BRACE property_key_value_pair_list RIGHT_BRACE;

property_key_value_pair_list : property_key_value_pair (COMMA property_key_value_pair)*;

property_key_value_pair : property_name COLON value_expression;

edge_pattern
    : full_edge_pattern
    | abbreviated_edge_pattern
    ;

full_edge_pattern
    : full_edge_pointing_left
    | full_edge_undirected
    | full_edge_pointing_right
    | full_edge_left_or_undirected
    | full_edge_undirected_or_right
    | full_edge_left_or_right
    | full_edge_any_direction
    ;

full_edge_pointing_left : LEFT_ARROW_BRACKET element_pattern_filler RIGHT_BRACKET_MINUS;

full_edge_undirected : TILDE_LEFT_BRACKET element_pattern_filler RIGHT_BRACKET_TILDE;

full_edge_pointing_right : MINUS_LEFT_BRACKET element_pattern_filler BRACKET_RIGHT_ARROW;

full_edge_left_or_undirected : LEFT_ARROW_TILDE_BRACKET element_pattern_filler RIGHT_BRACKET_TILDE;

full_edge_undirected_or_right : TILDE_LEFT_BRACKET element_pattern_filler BRACKET_TILDE_RIGHT_ARROW;

full_edge_left_or_right : LEFT_ARROW_BRACKET element_pattern_filler BRACKET_RIGHT_ARROW;

full_edge_any_direction : MINUS_LEFT_BRACKET element_pattern_filler RIGHT_BRACKET_MINUS;

abbreviated_edge_pattern
    : LEFT_ARROW
    | TILDE
    | RIGHT_ARROW
    | LEFT_ARROW_TILDE
    | TILDE_RIGHT_ARROW
    | LEFT_MINUS_RIGHT
    | MINUS_SIGN
    ;

parenthesized_path_pattern_expression
    : LEFT_PAREN subpath_variable_declaration? path_mode_prefix? path_pattern_expression parenthesized_path_pattern_where_clause? RIGHT_PAREN
    ;

subpath_variable_declaration : subpath_variable EQUALS_OPERATOR;

parenthesized_path_pattern_where_clause : WHERE search_condition;

// ---------------------------------------------------------------------
// label expression
label_expression
    : label_term
    | label_disjunction
    ;

label_disjunction : label_term VERTICAL_BAR label_expression;

label_term
    : label_factor
    | label_conjunction
    ;

label_conjunction : label_factor AMPERSAND label_term;

label_factor
    : label_primary
    | label_negation
    ;

label_negation : EXCLAMATION_MARK label_primary;

label_primary
    : label_name
    | wildcard_label
    | parenthesized_label_expression
    ;

wildcard_label : PERCENT;

parenthesized_label_expression : LEFT_PAREN label_expression RIGHT_PAREN;

// ---------------------------------------------------------------------
// path variable reference
path_variable_reference : binding_variable_reference;

// ---------------------------------------------------------------------
// element variable reference
element_variable_reference : binding_variable_reference;

// ---------------------------------------------------------------------
// graph_pattern quantifier
graph_pattern_quantifier
    : ASTERISK
    | PLUS_SIGN
    | fixed_quantifier
    | general_quantifier
    ;

fixed_quantifier : LEFT_BRACE unsigned_integer RIGHT_BRACE;

general_quantifier : LEFT_BRACE lower_bound? COMMA upper_bound? RIGHT_BRACE;

lower_bound : unsigned_integer;

upper_bound : unsigned_integer;

// ---------------------------------------------------------------------
// simplified path pattern expression
simplified_path_pattern_expression
    : simplified_defaulting_left
    | simplified_defaulting_undirected
    | simplified_defaulting_right
    | simplified_defaulting_left_or_undirected
    | simplified_defaulting_undirected_or_right
    | simplified_defaulting_left_or_right
    | simplified_defaulting_any_direction
    ;

simplified_defaulting_left : LEFT_MINUS_SLASH simplified_contents SLASH_MINUS;

simplified_defaulting_undirected : TILDE_SLASH simplified_contents SLASH_TILDE;

simplified_defaulting_right : MINUS_SLASH simplified_contents SLASH_MINUS_RIGHT;

simplified_defaulting_left_or_undirected : LEFT_TILDE_SLASH simplified_contents SLASH_TILDE;

simplified_defaulting_undirected_or_right : TILDE_SLASH simplified_contents SLASH_TILDE_RIGHT;

simplified_defaulting_left_or_right : LEFT_MINUS_SLASH simplified_contents SLASH_MINUS_RIGHT;

simplified_defaulting_any_direction : MINUS_SLASH simplified_contents SLASH_MINUS;

simplified_contents
    : simplified_term
    | simplified_path_union
    | simplified_multiset_alternation
    ;

simplified_path_union : simplified_term VERTICAL_BAR simplified_term (VERTICAL_BAR simplified_term)*;

simplified_multiset_alternation
    : simplified_term MULTISET_ALTERNATION_OPERATOR simplified_term (MULTISET_ALTERNATION_OPERATOR simplified_term)*
    ;

simplified_term
    : simplified_factor_low
    | simplified_concatenation
    ;

simplified_concatenation : simplified_factor_low simplified_term;

simplified_factor_low
    : simplified_factor_high
    | simplified_conjunction
    ;

simplified_conjunction : simplified_factor_high AMPERSAND simplified_factor_low;

simplified_factor_high
    : simplified_tertiary
    | simplified_quantified
    | simplified_questioned
    ;

simplified_quantified : simplified_tertiary graph_pattern_quantifier;

simplified_questioned : simplified_tertiary QUESTION_MARK;

simplified_tertiary
    : simplified_direction_override
    | simplified_secondary
    ;

simplified_direction_override
    : simplified_override_left
    | simplified_override_undirected
    | simplified_override_right
    | simplified_override_left_or_undirected
    | simplified_override_undirected_or_right
    | simplified_override_left_or_right
    | simplified_override_any_direction
    ;

simplified_override_left : LEFT_ANGLE_BRACKET simplified_secondary;

simplified_override_undirected : TILDE simplified_secondary;

simplified_override_right : simplified_secondary RIGHT_ANGLE_BRACKET;

simplified_override_left_or_undirected : LEFT_ARROW_TILDE simplified_secondary;

simplified_override_undirected_or_right : TILDE simplified_secondary RIGHT_ANGLE_BRACKET;

simplified_override_left_or_right : LEFT_ANGLE_BRACKET simplified_secondary RIGHT_ANGLE_BRACKET;

simplified_override_any_direction : MINUS_SIGN simplified_secondary;

simplified_secondary
    : simplified_primary
    | simplified_negation
    ;

simplified_negation : EXCLAMATION_MARK simplified_primary;

simplified_primary
    : label_name
    | LEFT_PAREN simplified_contents RIGHT_PAREN
    ;

// ---------------------------------------------------------------------
// where clause
where_clause : WHERE search_condition;

// ---------------------------------------------------------------------
// yield clause
yield_clause : YIELD yield_item_list;

yield_item_list : yield_item (COMMA yield_item)*;

yield_item : yield_item_name yield_item_alias?;

yield_item_name : field_name;

yield_item_alias : AS binding_variable;

// ---------------------------------------------------------------------
// group by clause
group_by_clause : GROUP BY grouping_element_list;

grouping_element_list
    : grouping_element (COMMA grouping_element)*
    | empty_grouping_set
    ;

grouping_element : binding_variable_reference;

empty_grouping_set : LEFT_PAREN RIGHT_PAREN;


// ---------------------------------------------------------------------
// order by clause
order_by_clause : ORDER BY sort_specification_list;

// ---------------------------------------------------------------------
// sort specification list
sort_specification_list : sort_specification (COMMA sort_specification)*;

sort_specification : sort_key ordering_specification? null_ordering?;

sort_key : aggregating_value_expression;

ordering_specification
    : ASC
    | ASCENDING
    | DESC
    | DESCENDING
    ;

null_ordering
    : NULLS FIRST
    | NULLS LAST
    ;

// ---------------------------------------------------------------------
// limit clause
limit_clause : LIMIT non__negative_integer_specification;

// ---------------------------------------------------------------------
// offset clause
offset_clause : offset_synonym non__negative_integer_specification;

offset_synonym
    : OFFSET
    | SKIP_TOKEN
    ;

// *********************************************************************
// schema reference and catalog schema parent and name
schema_reference
    : absolute_catalog_schema_reference
    | relative_catalog_schema_reference
    | reference_parameter_specification
    ;

absolute_catalog_schema_reference
    : SOLIDUS
    | absolute_directory_path schema_name
    ;

catalog_schema_parent_and_name : absolute_directory_path schema_name;

relative_catalog_schema_reference
    : predefined_schema_reference
    | relative_directory_path schema_name
    ;

predefined_schema_reference
    : HOME_SCHEMA
    | CURRENT_SCHEMA
    | PERIOD
    ;

absolute_directory_path : SOLIDUS simple_directory_path?;

relative_directory_path : DOUBLE_PERIOD ((SOLIDUS DOUBLE_PERIOD)+ SOLIDUS simple_directory_path?)?;

simple_directory_path : (directory_name SOLIDUS)+;

// ---------------------------------------------------------------------
// graph reference and catalog graph parent and name
graph_reference
    : catalog_object_parent_reference graph_name
    | delimited_graph_name
    | home_graph
    | reference_parameter_specification
    ;

catalog_graph_parent_and_name : catalog_object_parent_reference? graph_name;

home_graph
    : HOME_PROPERTY_GRAPH
    | HOME_GRAPH
    ;

// ---------------------------------------------------------------------
// graph type reference and catalog graph type parent and name
graph_type_reference
    : catalog_graph_type_parent_and_name
    | reference_parameter_specification
    ;

catalog_graph_type_parent_and_name : catalog_object_parent_reference? graph_type_name;

// ---------------------------------------------------------------------
// binding table reference and catalog binding table parent and name
binding_table_reference
    : catalog_object_parent_reference binding_table_name
    | delimited_binding_table_name
    | reference_parameter_specification
    ;

catalog_binding_table_parent_and_name : catalog_object_parent_reference? binding_table_name;

// ---------------------------------------------------------------------
// procedure reference and catalog procedure parent and name
procedure_reference
    : catalog_procedure_parent_and_name
    | reference_parameter_specification
    ;

catalog_procedure_parent_and_name : catalog_object_parent_reference? procedure_name;

// ---------------------------------------------------------------------
// catalog object parent reference
catalog_object_parent_reference
    : schema_reference SOLIDUS? (object_name PERIOD)*
    | (object_name PERIOD)+
    ;

// ---------------------------------------------------------------------
// reference parameter specification
reference_parameter_specification : substituted_parameter_reference;

// ---------------------------------------------------------------------
// external object reference
external_object_reference : EXTERNALURI;

// *********************************************************************
// nested graph type specification
nested_graph_type_specification : LEFT_BRACE graph_type_specification_body RIGHT_BRACE;

graph_type_specification_body : element_type_list;

element_type_list : element_type_specification (COMMA element_type_specification)*;

element_type_specification
    : node_type_specification
    | edge_type_specification
    ;

// ---------------------------------------------------------------------
// node type specification
node_type_specification
    : node_type_pattern
    | node_type_phrase
    ;

node_type_pattern
    : (node_synonym TYPE? node_type_name)? LEFT_PAREN local_node_type_alias? node_type_filler? RIGHT_PAREN
    ;

node_type_phrase : node_synonym TYPE? node_type_phrase_filler (AS local_node_type_alias)?;

node_type_phrase_filler
    : node_type_name node_type_filler?
    | node_type_filler
    ;

node_type_filler
    : node_type_key_label_set node_type_implied_content?
    | node_type_implied_content
    ;

local_node_type_alias : REGULAR_IDENTIFIER;

node_type_implied_content
    : node_type_label_set
    | node_type_property_types
    | node_type_label_set node_type_property_types
    ;

node_type_key_label_set : label_set_phrase? implies;

node_type_label_set : label_set_phrase;

node_type_property_types : property_types_specification;

// ---------------------------------------------------------------------
// edge type specification
edge_type_specification
    : edge_type_pattern
    | edge_type_phrase
    ;

edge_type_pattern
    : (edge_kind? edge_synonym TYPE? edge_type_name)? (edge_type_pattern_directed | edge_type_pattern_undirected)
    ;

edge_type_phrase : edge_kind edge_synonym TYPE? edge_type_phrase_filler endpoint_pair_phrase;

edge_type_phrase_filler
    : edge_type_name edge_type_filler?
    | edge_type_filler
    ;

edge_type_filler
    : edge_type_key_label_set edge_type_implied_content?
    | edge_type_implied_content
    ;

edge_type_implied_content
    : edge_type_label_set
    | edge_type_property_types
    | edge_type_label_set edge_type_property_types
    ;

edge_type_key_label_set : label_set_phrase? implies;

edge_type_label_set : label_set_phrase;

edge_type_property_types : property_types_specification;

edge_type_pattern_directed
    : edge_type_pattern_pointing_right
    | edge_type_pattern_pointing_left
    ;

edge_type_pattern_pointing_right : source_node_type_reference arc_type_pointing_right destination_node_type_reference;

edge_type_pattern_pointing_left : destination_node_type_reference arc_type_pointing_left source_node_type_reference;

edge_type_pattern_undirected : source_node_type_reference arc_type_undirected destination_node_type_reference;

arc_type_pointing_right : MINUS_LEFT_BRACKET edge_type_filler BRACKET_RIGHT_ARROW;

arc_type_pointing_left : LEFT_ARROW_BRACKET edge_type_filler RIGHT_BRACKET_MINUS;

arc_type_undirected : TILDE_LEFT_BRACKET edge_type_filler RIGHT_BRACKET_TILDE;

source_node_type_reference
    : LEFT_PAREN source_node_type_alias RIGHT_PAREN
    | LEFT_PAREN node_type_filler? RIGHT_PAREN
    ;

destination_node_type_reference
    : LEFT_PAREN destination_node_type_alias RIGHT_PAREN
    | LEFT_PAREN node_type_filler? RIGHT_PAREN
    ;

edge_kind
    : DIRECTED
    | UNDIRECTED
    ;

endpoint_pair_phrase : CONNECTING endpoint_pair;

endpoint_pair
    : endpoint_pair_directed
    | endpoint_pair_undirected
    ;

endpoint_pair_directed
    : endpoint_pair_pointing_right
    | endpoint_pair_pointing_left
    ;

endpoint_pair_pointing_right
    : LEFT_PAREN source_node_type_alias connector_pointing_right destination_node_type_alias RIGHT_PAREN
    ;

endpoint_pair_pointing_left
    : LEFT_PAREN destination_node_type_alias LEFT_ARROW source_node_type_alias RIGHT_PAREN
    ;

endpoint_pair_undirected
    : LEFT_PAREN source_node_type_alias connector_undirected destination_node_type_alias RIGHT_PAREN
    ;

connector_pointing_right
    : TO
    | RIGHT_ARROW
    ;

connector_undirected
    : TO
    | TILDE
    ;

source_node_type_alias : REGULAR_IDENTIFIER;

destination_node_type_alias : REGULAR_IDENTIFIER;

// ---------------------------------------------------------------------
// label set phrase and label set specification
label_set_phrase
    : LABEL label_name
    | LABELS label_set_specification
    | is_or_colon label_set_specification
    ;

label_set_specification : label_name (AMPERSAND label_name)*;

// ---------------------------------------------------------------------
// property types specification
property_types_specification : LEFT_BRACE property_type_list? RIGHT_BRACE;

property_type_list : property_type (COMMA property_type)*;

// ---------------------------------------------------------------------
// property type
property_type : property_name typed? property_value_type;

// ---------------------------------------------------------------------
// property value type
property_value_type : value_type;

// ---------------------------------------------------------------------
// binding table type
binding_table_type : BINDING? TABLE field_types_specification;

// ---------------------------------------------------------------------
// value type
// changed from the original grammar to remove left recursion and ambiguity
// note: if one day some rule uses a rule larger then list_value_type_name
//       or larger then closed_dynamic_union_value_type
//       and smaller then the rule value_type, then there would be a bug
value_type : non__composite_value_type (VERTICAL_BAR non__composite_value_type)*;

non__composite_value_type : value_type_special_case list_value_type_name (LEFT_BRACKET max_length RIGHT_BRACKET)? not_null?;

value_type_special_case
    : predefined_type
    | constructed_value_type
    | dynamic_union_type
    ;

typed
    : DOUBLE_COLON
    | TYPED
    ;

predefined_type
    : boolean_type
    | character_string_type
    | byte_string_type
    | numeric_type
    | temporal_type
    | reference_value_type
    | immaterial_value_type
    ;

boolean_type : (BOOL | BOOLEAN) not_null?;

character_string_type
    : STRING (LEFT_PAREN (min_length COMMA)? max_length RIGHT_PAREN)? not_null?
    | CHAR (LEFT_PAREN fixed_length RIGHT_PAREN)? not_null?
    | VARCHAR (LEFT_PAREN max_length RIGHT_PAREN)? not_null?
    ;

byte_string_type
    : BYTES (LEFT_PAREN (min_length COMMA)? max_length RIGHT_PAREN)? not_null?
    | BINARY (LEFT_PAREN fixed_length RIGHT_PAREN)? not_null?
    | VARBINARY (LEFT_PAREN max_length RIGHT_PAREN)? not_null?
    ;

min_length : unsigned_integer;

max_length : unsigned_integer;

fixed_length : unsigned_integer;

// ---------------------------------------------------------------------
// numeric type
numeric_type
    : exact_numeric_type
    | approximate_numeric_type
    ;

exact_numeric_type
    : binary_exact_numeric_type
    | decimal_exact_numeric_type
    ;

binary_exact_numeric_type
    : signed_binary_exact_numeric_type
    | unsigned_binary_exact_numeric_type
    ;

signed_binary_exact_numeric_type
    : INT8 not_null?
    | INT16 not_null?
    | INT32 not_null?
    | INT64 not_null?
    | INT128 not_null?
    | INT256 not_null?
    | SMALLINT not_null?
    | INT (LEFT_PAREN precision RIGHT_PAREN)? not_null?
    | BIGINT not_null?
    | SIGNED? verbose_binary_exact_numeric_type
    ;

unsigned_binary_exact_numeric_type
    : UINT8 not_null?
    | UINT16 not_null?
    | UINT32 not_null?
    | UINT64 not_null?
    | UINT128 not_null?
    | UINT256 not_null?
    | USMALLINT not_null?
    | UINT (LEFT_PAREN precision RIGHT_PAREN)? not_null?
    | UBIGINT not_null?
    | UNSIGNED verbose_binary_exact_numeric_type
    ;

verbose_binary_exact_numeric_type
    : INTEGER8 not_null?
    | INTEGER16 not_null?
    | INTEGER32 not_null?
    | INTEGER64 not_null?
    | INTEGER128 not_null?
    | INTEGER256 not_null?
    | SMALL INTEGER not_null?
    | INTEGER (LEFT_PAREN precision RIGHT_PAREN)? not_null?
    | BIG INTEGER not_null?
    ;

decimal_exact_numeric_type : (DECIMAL | DEC) (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN not_null?)?;

precision : UNSIGNED_DECIMAL_INTEGER;

scale : UNSIGNED_DECIMAL_INTEGER;

approximate_numeric_type
    : FLOAT16 not_null?
    | FLOAT32 not_null?
    | FLOAT64 not_null?
    | FLOAT128 not_null?
    | FLOAT256 not_null?
    | FLOAT (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN)? not_null?
    | REAL not_null?
    | DOUBLE PRECISION? not_null?
    ;

// ---------------------------------------------------------------------
// temporal type
temporal_type
    : temporal_instant_type
    | temporal_duration_type
    ;

temporal_instant_type
    : datetime_type
    | localdatetime_type
    | date_type
    | time_type
    | localtime_type
    ;

datetime_type
    : ZONED DATETIME not_null?
    | TIMESTAMP WITH TIME ZONE not_null?
    ;

localdatetime_type
    : LOCAL DATETIME not_null?
    | TIMESTAMP (WITHOUT TIME ZONE)? not_null?
    ;

date_type : DATE not_null?;

time_type
    : ZONED TIME not_null?
    | TIME WITH TIME ZONE not_null?
    ;

localtime_type
    : LOCAL TIME not_null?
    | TIME WITHOUT TIME ZONE not_null?
    ;

temporal_duration_type : DURATION LEFT_PAREN temporal_duration_qualifier RIGHT_PAREN not_null?;

temporal_duration_qualifier
    : YEAR TO MONTH
    | DAY TO SECOND
    ;

// ---------------------------------------------------------------------
// reference value type
reference_value_type
    : graph_reference_value_type
    | binding_table_reference_value_type
    | node_reference_value_type
    | edge_reference_value_type
    ;

immaterial_value_type
    : null_type
    | empty_type
    ;

null_type : NULL;

empty_type
    : NULL not_null
    | NOTHING
    ;

graph_reference_value_type
    : open_graph_reference_value_type
    | closed_graph_reference_value_type
    ;

closed_graph_reference_value_type : PROPERTY? GRAPH nested_graph_type_specification not_null?;

open_graph_reference_value_type : ANY? PROPERTY? GRAPH not_null?;

binding_table_reference_value_type : binding_table_type not_null?;

node_reference_value_type
    : open_node_reference_value_type
    | closed_node_reference_value_type
    ;

closed_node_reference_value_type : node_type_specification not_null?;

open_node_reference_value_type : ANY? node_synonym not_null?;

edge_reference_value_type
    : open_edge_reference_value_type
    | closed_edge_reference_value_type
    ;

closed_edge_reference_value_type : edge_type_specification not_null?;

open_edge_reference_value_type : ANY? edge_synonym not_null?;

// ---------------------------------------------------------------------
// constructed value type
constructed_value_type
    : path_value_type
    | list_value_type
    | record_type
    ;

path_value_type : PATH not_null?;

list_value_type
    : list_value_type_name LEFT_ANGLE_BRACKET value_type RIGHT_ANGLE_BRACKET (LEFT_BRACKET max_length RIGHT_BRACKET)? not_null?
    | list_value_type_name (LEFT_BRACKET max_length RIGHT_BRACKET)? not_null?
//  | value_type list_value_type_name (LEFT_BRACKET max_length RIGHT_BRACKET)? not_null?
    ;

list_value_type_name : GROUP? list_value_type_name_synonym;

list_value_type_name_synonym
    : LIST
    | ARRAY
    ;

record_type
    : ANY? RECORD not_null?
    | RECORD? field_types_specification not_null?
    ;

field_types_specification : LEFT_BRACE field_type_list? RIGHT_BRACE;

field_type_list : field_type (COMMA field_type)*;

// ---------------------------------------------------------------------
// dynamic union type
dynamic_union_type
    : open_dynamic_union_type
    | dynamic_property_value_type
    | closed_dynamic_union_type
    ;

open_dynamic_union_type : ANY VALUE? not_null?;

dynamic_property_value_type : ANY? PROPERTY VALUE not_null?;

closed_dynamic_union_type
    : ANY VALUE? LEFT_ANGLE_BRACKET component_type_list RIGHT_ANGLE_BRACKET
//  | component_type_list
    ;

component_type_list : component_type (VERTICAL_BAR component_type)*;

component_type : value_type;

not_null : NOT NULL;

// ---------------------------------------------------------------------
// field type
field_type : field_name typed? value_type;

// *********************************************************************
// search condition
search_condition : boolean_value_expression;

// ---------------------------------------------------------------------
// predicate
predicate
    : comparison_predicate
    | exists_predicate
    | null_predicate
    | normalized_predicate
    | value_type_predicate
    | directed_predicate
    | labeled_predicate
    | source__destination_predicate
    | all_different_predicate
    | same_predicate
    | property_exists_predicate
    ;

// ---------------------------------------------------------------------
// comparison predicate
comparison_predicate : comparison_predicand comparison_predicate_part_2;

comparison_predicate_part_2 : comp_op comparison_predicand;

comp_op
    : EQUALS_OPERATOR
    | NOT_EQUALS_OPERATOR
    | less_than_operator
    | greater_than_operator
    | LESS_THAN_OR_EQUALS_OPERATOR
    | GREATER_THAN_OR_EQUALS_OPERATOR
    ;

comparison_predicand
    : common_value_expression
    | boolean_predicand
    ;

// ---------------------------------------------------------------------
// exists predicate
exists_predicate
    : EXISTS (LEFT_BRACE graph_pattern RIGHT_BRACE | LEFT_PAREN graph_pattern RIGHT_PAREN
        | LEFT_BRACE match_statement_block RIGHT_BRACE | LEFT_PAREN match_statement_block RIGHT_PAREN
        | nested_query_specification)
    ;

// ---------------------------------------------------------------------
// null predicate
null_predicate : value_expression_primary null_predicate_part_2;

null_predicate_part_2 : IS NOT? NULL;

// ---------------------------------------------------------------------
// value type predicate
value_type_predicate : value_expression_primary value_type_predicate_part_2;

value_type_predicate_part_2 : IS NOT? typed value_type;


// ---------------------------------------------------------------------
// normalized predicate
normalized_predicate : string_value_expression normalized_predicate_part_2;

normalized_predicate_part_2 : IS NOT? normal_form? NORMALIZED;

// ---------------------------------------------------------------------
// directed predicate
directed_predicate : element_variable_reference directed_predicate_part_2;

directed_predicate_part_2 : IS NOT? DIRECTED;

// ---------------------------------------------------------------------
// labeled predicate
labeled_predicate : element_variable_reference labeled_predicate_part_2;

labeled_predicate_part_2 : is_labeled_or_colon label_expression;

is_labeled_or_colon
    : IS NOT? LABELED
    | COLON
    ;

// ---------------------------------------------------------------------
// source/destination predicate
source__destination_predicate
    : node_reference source_predicate_part_2
    | node_reference destination_predicate_part_2
    ;

node_reference : element_variable_reference;

source_predicate_part_2 : IS NOT? SOURCE OF edge_reference;

destination_predicate_part_2 : IS NOT? DESTINATION OF edge_reference;

edge_reference : element_variable_reference;

// ---------------------------------------------------------------------
// all_different predicate
all_different_predicate : ALL_DIFFERENT LEFT_PAREN element_variable_reference COMMA element_variable_reference (COMMA element_variable_reference)* RIGHT_PAREN;

// ---------------------------------------------------------------------
// same predicate
same_predicate
    : SAME LEFT_PAREN element_variable_reference COMMA element_variable_reference (COMMA element_variable_reference)* RIGHT_PAREN
    ;

// ---------------------------------------------------------------------
// property_exists predicate
property_exists_predicate : PROPERTY_EXISTS LEFT_PAREN element_variable_reference COMMA property_name RIGHT_PAREN;

// *********************************************************************
// value_expression
value_expression
    : common_value_expression
    | boolean_value_expression
    ;

common_value_expression
    : numeric_value_expression
    | string_value_expression
    | datetime_value_expression
    | duration_value_expression
    | list_value_expression
    | record_expression
    | path_value_expression
    | reference_value_expression
    ;

// changed from original
// because as parser can't distinguish between node_reference_value_expression
// and edge_reference_value_expression
reference_value_expression
    : value_expression_primary
    | graph_reference_value_expression
    | binding_table_reference_value_expression
    ;

graph_reference_value_expression
    : PROPERTY? GRAPH graph_expression
    | value_expression_primary
    ;

binding_table_reference_value_expression
    : BINDING? TABLE binding_table_expression
    | value_expression_primary
    ;

node_reference_value_expression : value_expression_primary;

edge_reference_value_expression : value_expression_primary;

record_expression : value_expression_primary;

aggregating_value_expression : value_expression;

// ---------------------------------------------------------------------
// value expression primary
// changed from original to reduce left recursion
value_expression_primary
    : parenthesized_value_expression
    | non__parenthesized_value_expression_primary
    ;

parenthesized_value_expression : LEFT_PAREN value_expression RIGHT_PAREN;

non__parenthesized_value_expression_primary
    : non__parenthesized_value_expression_primary_special_case
    | binding_variable_reference
    ;

non__parenthesized_value_expression_primary_special_case
    : aggregate_function
    | unsigned_value_specification
    | list_value_constructor
    | record_constructor
    | path_value_constructor
    | property_reference
    | value_query_expression
    | case_expression
    | cast_specification
    | element_id_function
    | let_value_expression
    ;

// ---------------------------------------------------------------------
// value specification
value_specification
    : literal
    | general_value_specification
    ;

unsigned_value_specification
    : unsigned_literal
    | general_value_specification
    ;

non__negative_integer_specification
    : unsigned_integer
    | dynamic_parameter_specification
    ;

general_value_specification
    : dynamic_parameter_specification
    | SESSION_USER
    ;

// ---------------------------------------------------------------------
// dynamic parameter specification
dynamic_parameter_specification : general_parameter_reference;

// ---------------------------------------------------------------------
// let value expression
let_value_expression : LET let_variable_definition_list IN value_expression END;

// ---------------------------------------------------------------------
// value query expression
value_query_expression : VALUE nested_query_specification;

// ---------------------------------------------------------------------
// case expression
case_expression
    : case_abbreviation
    | case_specification
    ;

case_abbreviation
    : NULLIF LEFT_PAREN value_expression COMMA value_expression RIGHT_PAREN
    | COALESCE LEFT_PAREN value_expression (COMMA value_expression)+ RIGHT_PAREN
    ;

case_specification
    : simple_case
    | searched_case
    ;

simple_case : CASE case_operand simple_when_clause+ else_clause? END;

searched_case : CASE searched_when_clause+ else_clause? END;

simple_when_clause : WHEN when_operand_list THEN result;

searched_when_clause : WHEN search_condition THEN result;

else_clause : ELSE result;

case_operand
    : non__parenthesized_value_expression_primary
    | element_variable_reference
    ;

when_operand_list : when_operand (COMMA when_operand)*;

when_operand
    : non__parenthesized_value_expression_primary
    | comparison_predicate_part_2
    | null_predicate_part_2
    | value_type_predicate_part_2
    | normalized_predicate_part_2
    | directed_predicate_part_2
    | labeled_predicate_part_2
    | source_predicate_part_2
    | destination_predicate_part_2
    ;

result
    : result_expression
    | null_literal
    ;

result_expression : value_expression;

// ---------------------------------------------------------------------
// cast specification
cast_specification : CAST LEFT_PAREN cast_operand AS cast_target RIGHT_PAREN;

cast_operand
    : value_expression
    | null_literal
    ;

cast_target : value_type;

// ---------------------------------------------------------------------
// aggregate function
aggregate_function
    : COUNT LEFT_PAREN ASTERISK RIGHT_PAREN
    | general_set_function
    | binary_set_function
    ;

general_set_function : general_set_function_type LEFT_PAREN set_quantifier? value_expression RIGHT_PAREN;

binary_set_function : binary_set_function_type LEFT_PAREN dependent_value_expression COMMA independent_value_expression RIGHT_PAREN;

general_set_function_type
    : AVG
    | COUNT
    | MAX
    | MIN
    | SUM
    | COLLECT_LIST
    | STDDEV_SAMP
    | STDDEV_POP
    ;

set_quantifier
    : DISTINCT
    | ALL
    ;

binary_set_function_type
    : PERCENTILE_CONT
    | PERCENTILE_DISC
    ;

dependent_value_expression : set_quantifier? numeric_value_expression;

independent_value_expression : numeric_value_expression;

// ---------------------------------------------------------------------
// element_id function
element_id_function : ELEMENT_ID LEFT_PAREN element_variable_reference RIGHT_PAREN;

// ---------------------------------------------------------------------
// property reference
// changed from original to reduce left recursion
property_reference
    : property_source PERIOD property_name
    | property_reference PERIOD property_name
    ;

property_source
    : parenthesized_value_expression
    | binding_variable_reference
    | aggregate_function
    | unsigned_value_specification
    | list_value_constructor
    | record_constructor
    | path_value_constructor
    | value_query_expression
    | case_expression
    | cast_specification
    | element_id_function
    | let_value_expression
    ;

// ---------------------------------------------------------------------
// binding variable reference
binding_variable_reference : binding_variable;

// ---------------------------------------------------------------------
// path value expression
path_value_expression
    : path_value_concatenation
    | path_value_primary
    ;

path_value_concatenation :  path_value_primary CONCATENATION_OPERATOR path_value_expression;

path_value_primary : value_expression_primary;

// ---------------------------------------------------------------------
// path value constructor
path_value_constructor : path_value_constructor_by_enumeration;

path_value_constructor_by_enumeration : PATH LEFT_BRACKET path_element_list RIGHT_BRACKET;

path_element_list : path_element_list_start path_element_list_step*;

path_element_list_start : node_reference_value_expression;

path_element_list_step : COMMA edge_reference_value_expression COMMA node_reference_value_expression;

// ---------------------------------------------------------------------
// list value expression
list_value_expression
    : list_concatenation
    | list_primary
    ;

list_concatenation : list_primary CONCATENATION_OPERATOR list_value_expression;

list_primary
    : list_value_function
    | value_expression_primary
    ;

// ---------------------------------------------------------------------
// list value function
list_value_function
    : trim_list_function
    | elements_function
    ;

trim_list_function : TRIM LEFT_PAREN list_value_expression COMMA numeric_value_expression RIGHT_PAREN;

elements_function : ELEMENTS LEFT_PAREN path_value_expression RIGHT_PAREN;

// ---------------------------------------------------------------------
// list value constructor
list_value_constructor : list_value_constructor_by_enumeration;

list_value_constructor_by_enumeration : list_value_type_name? LEFT_BRACKET list_element_list? RIGHT_BRACKET;

list_element_list : list_element (COMMA list_element)*;

list_element : value_expression;

// ---------------------------------------------------------------------
// record constructor
record_constructor : RECORD? fields_specification;

fields_specification : LEFT_BRACE field_list? RIGHT_BRACE;

field_list : field (COMMA field)*;

// ---------------------------------------------------------------------
// field
field : field_name COLON value_expression;

// ---------------------------------------------------------------------
// boolean value expression
boolean_value_expression
    : boolean_term
    | boolean_value_expression OR boolean_term
    | boolean_value_expression XOR boolean_term
    ;

boolean_term
    : boolean_factor
    | boolean_term AND boolean_factor
    ;

boolean_factor : NOT? boolean_test;

boolean_test : boolean_primary (IS NOT? truth_value)?;

truth_value
    : TRUE
    | FALSE
    | UNKNOWN
    ;

boolean_primary
    : predicate
    | boolean_predicand
    ;

boolean_predicand
    : parenthesized_boolean_value_expression
    | non__parenthesized_value_expression_primary
    ;

parenthesized_boolean_value_expression : LEFT_PAREN boolean_value_expression RIGHT_PAREN;

// ---------------------------------------------------------------------
// numeric value expression
numeric_value_expression
    : term
    | numeric_value_expression PLUS_SIGN term
    | numeric_value_expression MINUS_SIGN term
    ;

term
    : factor
    | term ASTERISK factor
    | term SOLIDUS factor
    ;

factor
    : (PLUS_SIGN | MINUS_SIGN)? numeric_primary
    ;

numeric_primary
    : value_expression_primary
    | numeric_value_function
    ;

// ---------------------------------------------------------------------
// numeric value function
numeric_value_function
    : length_expression
    | cardinality_expression
    | absolute_value_expression
    | modulus_expression
    | trigonometric_function
    | general_logarithm_function
    | common_logarithm
    | natural_logarithm
    | exponential_function
    | power_function
    | square_root
    | floor_function
    | ceiling_function
    ;

length_expression
    : char_length_expression
    | byte_length_expression
    | path_length_expression
    ;

cardinality_expression
    : CARDINALITY LEFT_PAREN cardinality_expression_argument RIGHT_PAREN
    | SIZE LEFT_PAREN list_value_expression RIGHT_PAREN
    ;

cardinality_expression_argument
    : binding_table_reference_value_expression
    | path_value_expression
    | list_value_expression
    | record_expression
    ;

char_length_expression : (CHAR_LENGTH | CHARACTER_LENGTH) LEFT_PAREN character_string_value_expression RIGHT_PAREN;

byte_length_expression : (BYTE_LENGTH | OCTET_LENGTH) LEFT_PAREN byte_string_value_expression RIGHT_PAREN;

path_length_expression : PATH_LENGTH LEFT_PAREN path_value_expression RIGHT_PAREN;

absolute_value_expression : ABS LEFT_PAREN numeric_value_expression RIGHT_PAREN;

modulus_expression : MOD LEFT_PAREN numeric_value_expression_dividend COMMA numeric_value_expression_divisor RIGHT_PAREN;

numeric_value_expression_dividend : numeric_value_expression;

numeric_value_expression_divisor : numeric_value_expression;

trigonometric_function : trigonometric_function_name LEFT_PAREN numeric_value_expression RIGHT_PAREN;

trigonometric_function_name
    : SIN
    | COS
    | TAN
    | COT
    | SINH
    | COSH
    | TANH
    | ASIN
    | ACOS
    | ATAN
    | DEGREES
    | RADIANS
    ;

general_logarithm_function : LOG LEFT_PAREN general_logarithm_base COMMA general_logarithm_argument RIGHT_PAREN;

general_logarithm_base : numeric_value_expression;

general_logarithm_argument : numeric_value_expression;

common_logarithm : LOG10 LEFT_PAREN numeric_value_expression RIGHT_PAREN;

natural_logarithm : LN LEFT_PAREN numeric_value_expression RIGHT_PAREN;

exponential_function : EXP LEFT_PAREN numeric_value_expression RIGHT_PAREN;

power_function : POWER LEFT_PAREN numeric_value_expression_base COMMA numeric_value_expression_exponent RIGHT_PAREN;

numeric_value_expression_base : numeric_value_expression;

numeric_value_expression_exponent : numeric_value_expression;

square_root : SQRT LEFT_PAREN numeric_value_expression RIGHT_PAREN;

floor_function : FLOOR LEFT_PAREN numeric_value_expression RIGHT_PAREN;

ceiling_function : (CEIL | CEILING) LEFT_PAREN numeric_value_expression RIGHT_PAREN;

// ---------------------------------------------------------------------
// string value expression
string_value_expression
    : character_string_value_expression
    | byte_string_value_expression
    ;

character_string_value_expression
    : character_string_concatenation
    | character_string_primary
    ;

character_string_concatenation : character_string_primary CONCATENATION_OPERATOR character_string_concatenation;

character_string_primary
    : value_expression_primary
    | character_string_function
    ;

byte_string_value_expression
    : byte_string_concatenation
    | byte_string_primary
    ;

byte_string_primary
    : value_expression_primary
    | byte_string_function
    ;

byte_string_concatenation : byte_string_primary CONCATENATION_OPERATOR byte_string_value_expression;

// ---------------------------------------------------------------------
// character string function
character_string_function
    : substring_function
    | fold
    | trim_function
    | normalize_function
    ;

substring_function
    : (LEFT | RIGHT) LEFT_PAREN character_string_value_expression COMMA string_length RIGHT_PAREN
    ;

fold
    : (UPPER | LOWER) LEFT_PAREN character_string_value_expression RIGHT_PAREN
    ;

trim_function
    : single__character_trim_function
    | multi__character_trim_function
    ;

single__character_trim_function
    : TRIM LEFT_PAREN trim_operands RIGHT_PAREN
    ;

multi__character_trim_function
    : (BTRIM | LTRIM | RTRIM) LEFT_PAREN trim_source (COMMA trim_character_string)? RIGHT_PAREN
    ;

trim_operands
    : (trim_specification? trim_character_string? FROM)? trim_source
    ;

trim_source : character_string_value_expression;

trim_specification
    : LEADING
    | TRAILING
    | BOTH
    ;

trim_character_string : character_string_value_expression;

normalize_function
    : NORMALIZE LEFT_PAREN character_string_value_expression (COMMA normal_form)? RIGHT_PAREN
    ;

normal_form
    : NFC
    | NFD
    | NFKC
    | NFKD
    ;

string_length
    : numeric_value_expression
    ;

// ---------------------------------------------------------------------
// byte string function
byte_string_function
    : byte_string_substring_function
    | byte_string_trim_function
    ;

byte_string_substring_function
    : (LEFT | RIGHT) LEFT_PAREN byte_string_value_expression COMMA string_length RIGHT_PAREN
    ;

byte_string_trim_function
    : TRIM LEFT_PAREN byte_string_trim_operands RIGHT_PAREN
    ;

byte_string_trim_operands
    : (trim_specification? trim_byte_string? FROM)? byte_string_trim_source
    ;

byte_string_trim_source
    : byte_string_value_expression
    ;

trim_byte_string
    : byte_string_value_expression
    ;

// ---------------------------------------------------------------------
// datetime value expression
datetime_value_expression
    : datetime_primary
    | duration_value_expression PLUS_SIGN datetime_primary
    | datetime_value_expression PLUS_SIGN duration_term
    | datetime_value_expression MINUS_SIGN duration_term
    ;

datetime_primary
    : value_expression_primary
    | datetime_value_function
    ;

// ---------------------------------------------------------------------
// datetime value function
datetime_value_function
    : date_function
    | time_function
    | datetime_function
    | localtime_function
    | localdatetime_function
    ;

date_function
    : CURRENT_DATE
    | DATE LEFT_PAREN date_function_parameters? RIGHT_PAREN
    ;

time_function
    : CURRENT_TIME
    | ZONED_TIME LEFT_PAREN time_function_parameters? RIGHT_PAREN
    ;

localtime_function : LOCAL_TIME (LEFT_PAREN time_function_parameters? RIGHT_PAREN)?;

datetime_function
    : CURRENT_TIMESTAMP
    | ZONED_DATETIME LEFT_PAREN datetime_function_parameters? RIGHT_PAREN
    ;

localdatetime_function
    : LOCAL_TIMESTAMP
    | LOCAL_DATETIME LEFT_PAREN datetime_function_parameters? RIGHT_PAREN
    ;

date_function_parameters
    : date_string
    | record_constructor
    ;

time_function_parameters
    : time_string
    | record_constructor
    ;

datetime_function_parameters
    : datetime_string
    | record_constructor
    ;

// ---------------------------------------------------------------------
// duration value expression
// changed from original to reduce left recursion
duration_value_expression
    : duration_term
    | duration_value_expression PLUS_SIGN duration_term
    | duration_value_expression MINUS_SIGN duration_term
    | datetime_subtraction
    ;

duration_addition_and_subtraction
    : duration_value_expression PLUS_SIGN duration_term
    | duration_value_expression MINUS_SIGN duration_term
    ;

datetime_subtraction
    : DURATION_BETWEEN LEFT_PAREN datetime_subtraction_parameters RIGHT_PAREN temporal_duration_qualifier?
    ;

datetime_subtraction_parameters
    : datetime_value_expression COMMA datetime_value_expression
    ;

duration_term
    : duration_factor
    | duration_term ASTERISK factor
    | duration_term SOLIDUS factor
    | term ASTERISK duration_factor
    ;

duration_factor : (PLUS_SIGN | MINUS_SIGN)? duration_primary;

duration_primary
    : value_expression_primary
    | duration_value_function
    ;

// ---------------------------------------------------------------------
// duration value function
duration_value_function
    : duration_function
    | duration_absolute_value_function
    ;

duration_function : DURATION LEFT_PAREN duration_function_parameters RIGHT_PAREN;

duration_function_parameters
    : duration_string
    | record_constructor
    ;

duration_absolute_value_function : ABS LEFT_PAREN duration_value_expression RIGHT_PAREN;

// *********************************************************************
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

// *********************************************************************
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
    | list_literal
    | record_literal
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
// todo: support SQL__DATETIME_LITERAL and SQL__INTERVAL_LITERAL
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
// list literal
list_literal : list_value_constructor_by_enumeration;

// ---------------------------------------------------------------------
// record literal
record_literal : record_constructor;

// *********************************************************************
// token
token
    : non__delimiter_token
    | delimiter_token
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
    | non__reserved_word // non-reserved word can be used as an identifier
    ;

// note: this is not the same with the BNF,
// because EXTENDED_IDENTIFIER can't recognize the REGULAR_IDENTIFIER
separated_identifier
    : non__delimited_identifier
    | delimited_identifier
    ;

non__delimited_identifier
    : REGULAR_IDENTIFIER
    | EXTENDED_IDENTIFIER
    | non__reserved_word // non-reserved word can be used as an identifier
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
    | QUERY
    | RECORDS
    | REFERENCE
    | RENAME
    | REVOKE
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
    | DOUBLE_COLON
    | DOUBLE_PERIOD
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

node_synonym
    : NODE
    | VERTEX
    ;

// ---------------------------------------------------------------------
// implies
implies
    : RIGHT_DOUBLE_ARROW
    | IMPLIES
    ;

// *********************************************************************
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