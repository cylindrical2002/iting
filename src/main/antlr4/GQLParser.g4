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
gqlProgram
    : programActivity sessionCloseCommand?
    | sessionCloseCommand
    ;

programActivity
    : sessionActivity
    | transactionActivity
    ;

sessionActivity
    : sessionResetCommand+
    | sessionSetCommand+ sessionResetCommand*
    ;

transactionActivity
    : startTransactionCommand (procedureSpecification endTransactionCommand?)?
    | procedureSpecification endTransactionCommand?
    | endTransactionCommand
    ;

endTransactionCommand
    : rollbackCommand
    | commitCommand
    ;

// *********************************************************************
// session set command
sessionSetCommand
    : SESSION SET (sessionSetSchemaClause | sessionSetGraphClause | sessionSetTimeZoneClause | sessionSetParameterClause)
    ;

sessionSetSchemaClause : SCHEMA schemaReference;

sessionSetGraphClause : PROPERTY? GRAPH graphExpression;

sessionSetTimeZoneClause : TIME ZONE setTimeZoneValue;

setTimeZoneValue : timeZoneString;

sessionSetParameterClause
    : sessionSetGraphParameterClause
    | sessionSetBindingTableParameterClause
    | sessionSetValueParameterClause
    ;

sessionSetGraphParameterClause : PROPERTY? GRAPH sessionSetParameterName optTypedGraphInitializer;

sessionSetBindingTableParameterClause : BINDING? TABLE sessionSetParameterName optTypedBindingTableInitializer;

sessionSetValueParameterClause : VALUE sessionSetParameterName optTypedValueInitializer;

sessionSetParameterName : (IF NOT EXISTS)? sessionParameterSpecification;

// ---------------------------------------------------------------------
// session reset command
sessionResetCommand : SESSION RESET sessionResetArguments?;

sessionResetArguments
    : ALL? (PARAMETERS | CHARACTERISTICS)
    | SCHEMA
    | PROPERTY? GRAPH
    | TIME ZONE
    | PARAMETER? sessionParameterSpecification
    ;

// ---------------------------------------------------------------------
// session close command
sessionCloseCommand : SESSION CLOSE;

// ---------------------------------------------------------------------
// session parameter specification
sessionParameterSpecification : generalParameterReference;

// *********************************************************************
// start transaction command
startTransactionCommand : START TRANSACTION transactionCharacteristics?;

// ---------------------------------------------------------------------
// transaction characteristics
transactionCharacteristics : transactionMode (COMMA transactionMode)*;

transactionMode
    : transactionAccessMode
//  | implementation_defined_access_mode
    ;

transactionAccessMode
    : READ ONLY
    | READ WRITE
    ;

// todo: define implementation_defined_access_mode IE002
// implementation-defined access mode is not defined in the grammar

// ---------------------------------------------------------------------
// rollback command
rollbackCommand : ROLLBACK;

// ---------------------------------------------------------------------
// commit command
commitCommand : COMMIT;

// *********************************************************************
// procedure specification
nestedProcedureSpecification : LEFT_BRACE procedureSpecification RIGHT_BRACE;

// changed from the original grammar
// because the parser can't distinguish between a catalog-modifying procedure specification
// and a data-modifying procedure specification
// and query specification
procedureSpecification : procedureBody;

catalogModifyingProcedureSpecification : procedureBody;

nestedDataModifyingProcedureSpecification : LEFT_BRACE dataModifyingProcedureSpecification RIGHT_BRACE;

dataModifyingProcedureSpecification : procedureBody;

nestedQuerySpecification : LEFT_BRACE querySpecification RIGHT_BRACE;

querySpecification : procedureBody;

// ---------------------------------------------------------------------
// procedure body
procedureBody : atSchemaClause? bindingVariableDefinitionBlock? statementBlock;

bindingVariableDefinitionBlock : bindingVariableDefinition+;

bindingVariableDefinition
    : graphVariableDefinition
    | bindingTableVariableDefinition
    | valueVariableDefinition
    ;

statementBlock : statement nextStatement*;

statement
    : linearCatalogModifyingStatement
    | linearDataModifyingStatement
    | compositeQueryStatement
    ;

nextStatement : NEXT yieldClause? statement;

// *********************************************************************
// graph variable definition
graphVariableDefinition : PROPERTY? GRAPH bindingVariable optTypedGraphInitializer;

optTypedGraphInitializer : (typed? graphReferenceValueType)? graphInitializer;

graphInitializer : EQUALS_OPERATOR graphExpression;

// ---------------------------------------------------------------------
// binding table variable definition
bindingTableVariableDefinition : BINDING? TABLE bindingVariable optTypedBindingTableInitializer;

optTypedBindingTableInitializer : (typed? bindingTableReferenceValueType)? bindingTableInitializer;

bindingTableInitializer : EQUALS_OPERATOR bindingTableExpression;

// ---------------------------------------------------------------------
// value variable definition
valueVariableDefinition : VALUE bindingVariable optTypedValueInitializer;

optTypedValueInitializer : (typed? valueType)? valueInitializer;

valueInitializer : EQUALS_OPERATOR valueExpression;

// *********************************************************************
// graph expression
graphExpression
    : objectExpressionPrimary
    | graphReference
    | objectNameOrBindingVariable
    | currentGraph
    ;

currentGraph
    : CURRENT_PROPERTY_GRAPH
    | CURRENT_GRAPH
    ;

// ---------------------------------------------------------------------
// binding table expression
bindingTableExpression
    : nestedBindingTableQuerySpecification
    | objectExpressionPrimary
    | bindingTableReference
    | objectNameOrBindingVariable
    ;

nestedBindingTableQuerySpecification : nestedQuerySpecification;

// ---------------------------------------------------------------------
// object expression primary
objectExpressionPrimary
    : VARIABLE valueExpressionPrimary
    | parenthesizedValueExpression
    | nonParenthesizedValueExpressionPrimarySpecialCase
    ;

// *********************************************************************
// linear catalog-modifying statement
linearCatalogModifyingStatement : simpleCatalogModifyingStatement+;

simpleCatalogModifyingStatement
    : primitiveCatalogModifyingStatement
    | callCatalogModifyingProcedureStatement
    ;

primitiveCatalogModifyingStatement
    : createSchemaStatement
    | dropSchemaStatement
    | createGraphStatement
    | dropGraphStatement
    | createGraphTypeStatement
    | dropGraphTypeStatement
    ;

// ---------------------------------------------------------------------
// create schema statement
createSchemaStatement : CREATE SCHEMA (IF NOT EXISTS)? catalogSchemaParentAndName;

// ---------------------------------------------------------------------
// drop schema statement
dropSchemaStatement : DROP SCHEMA (IF EXISTS)? catalogSchemaParentAndName;

// ---------------------------------------------------------------------
// create graph statement
createGraphStatement
    : CREATE (PROPERTY? GRAPH (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH) catalogGraphParentAndName (openGraphType | ofGraphType) graphSource?
    ;

openGraphType : typed? ANY (PROPERTY? GRAPH)?;

ofGraphType
    : graphTypeLikeGraph
    | typed? graphTypeReference
    | typed? (PROPERTY? GRAPH)? nestedGraphTypeSpecification
    ;

graphTypeLikeGraph : LIKE graphExpression;

graphSource : AS COPY OF graphExpression;

// ---------------------------------------------------------------------
// drop graph statement
dropGraphStatement : DROP PROPERTY? GRAPH (IF EXISTS)? catalogGraphParentAndName;

// ---------------------------------------------------------------------
// create graph type statement
createGraphTypeStatement
    : CREATE (PROPERTY? GRAPH TYPE (IF NOT EXISTS)? | OR REPLACE PROPERTY? GRAPH TYPE) catalogGraphTypeParentAndName graphTypeSource
    ;

graphTypeSource
    : AS? copyOfGraphType
    | graphTypeLikeGraph
    | AS? nestedGraphTypeSpecification
    ;

copyOfGraphType : COPY OF (graphTypeReference | externalObjectReference);

// ---------------------------------------------------------------------
// drop graph type statement
dropGraphTypeStatement : DROP PROPERTY? GRAPH TYPE (IF EXISTS)? catalogGraphTypeParentAndName;

// ---------------------------------------------------------------------
// call catalog-modifying procedure statement
callCatalogModifyingProcedureStatement : callProcedureStatement;

// *********************************************************************
// linear data-modifying statement
linearDataModifyingStatement
    : focusedLinearDataModifyingStatement
    | ambientLinearDataModifyingStatement
    ;

focusedLinearDataModifyingStatement
    : focusedLinearDataModifyingStatementBody
    | focusedNestedDataModifyingProcedureSpecification
    ;

focusedLinearDataModifyingStatementBody
    : useGraphClause simpleLinearDataAccessingStatement primitiveResultStatement?
    ;

focusedNestedDataModifyingProcedureSpecification
    : useGraphClause nestedDataModifyingProcedureSpecification
    ;

ambientLinearDataModifyingStatement
    : ambientLinearDataModifyingStatementBody
    | nestedDataModifyingProcedureSpecification
    ;

ambientLinearDataModifyingStatementBody
    : simpleLinearDataAccessingStatement primitiveResultStatement?
    ;

simpleLinearDataAccessingStatement : simpleDataAccessingStatement+;

simpleDataAccessingStatement
    : simpleQueryStatement
    | simpleDataModifyingStatement
    ;

simpleDataModifyingStatement
    : primitiveDataModifyingStatement
    | callDataModifyingProcedureStatement
    ;

primitiveDataModifyingStatement
    : insertStatement
    | setStatement
    | removeStatement
    | deleteStatement
    ;

// ---------------------------------------------------------------------
// insert statement
insertStatement : INSERT insertGraphPattern;

// ---------------------------------------------------------------------
// set statement
setStatement : SET setItemList;

setItemList : setItem (COMMA setItem)*;

setItem
    : setPropertyItem
    | setAllPropertiesItem
    | setLabelItem
    ;

setPropertyItem : bindingVariableReference PERIOD propertyName EQUALS_OPERATOR valueExpression;

setAllPropertiesItem : bindingVariableReference EQUALS_OPERATOR LEFT_BRACE propertyKeyValuePairList? RIGHT_BRACE;

setLabelItem : bindingVariableReference isOrColon labelName;

// ---------------------------------------------------------------------
// remove statement
removeStatement : REMOVE removeItemList;

removeItemList : removeItem (COMMA removeItem)*;

removeItem
    : removePropertyItem
    | removeLabelItem
    ;

removePropertyItem : bindingVariableReference PERIOD propertyName;

removeLabelItem : bindingVariableReference isOrColon labelName;

// ---------------------------------------------------------------------
// delete statement
deleteStatement : (DETACH | NODETACH)? DELETE deleteItemList;

deleteItemList : deleteItem (COMMA deleteItem)*;

deleteItem : valueExpression;

// ---------------------------------------------------------------------
// call data-modifying procedure statement
callDataModifyingProcedureStatement : callProcedureStatement;

// *********************************************************************
// composite query statement
compositeQueryStatement : compositeQueryExpression;

// ---------------------------------------------------------------------
// composite query expression
compositeQueryExpression
    : compositeQueryExpression queryConjunction compositeQueryPrimary
    | compositeQueryPrimary
    ;

queryConjunction
    : setOperator
    | OTHERWISE
    ;

setOperator
    : UNION setQuantifier?
    | EXCEPT setQuantifier?
    | INTERSECT setQuantifier?
    ;

compositeQueryPrimary : linearQueryStatement;

// ---------------------------------------------------------------------
// linear query statement and simple query statement
linearQueryStatement
    : focusedLinearQueryStatement
    | ambientLinearQueryStatement
    ;

focusedLinearQueryStatement
    : focusedLinearQueryStatementPart* focusedLinearQueryAndPrimitiveResultStatementPart
    | focusedPrimitiveResultStatement
    | focusedNestedQuerySpecification
    | selectStatement
    ;

focusedLinearQueryStatementPart : useGraphClause simpleLinearQueryStatement;

focusedLinearQueryAndPrimitiveResultStatementPart : useGraphClause simpleLinearQueryStatement primitiveResultStatement;

focusedPrimitiveResultStatement : useGraphClause primitiveResultStatement;

focusedNestedQuerySpecification : useGraphClause nestedQuerySpecification;

ambientLinearQueryStatement
    : simpleLinearQueryStatement? primitiveResultStatement
    | nestedQuerySpecification
    ;

simpleLinearQueryStatement : simpleQueryStatement+;

simpleQueryStatement
    : primitiveQueryStatement
    | callQueryStatement
    ;

primitiveQueryStatement
    : matchStatement
    | letStatement
    | forStatement
    | filterStatement
    | orderByAndPageStatement
    ;

// ---------------------------------------------------------------------
// match statement
matchStatement
    : simpleMatchStatement
    | optionalMatchStatement
    ;

simpleMatchStatement : MATCH graphPatternBindingTable;

optionalMatchStatement : OPTIONAL optionalOperand;

optionalOperand
    : simpleMatchStatement
    | LEFT_BRACE matchStatementBlock RIGHT_BRACE
    | LEFT_PAREN matchStatementBlock RIGHT_PAREN
    ;

matchStatementBlock : matchStatement+;

// ---------------------------------------------------------------------
// call query statement
callQueryStatement : callProcedureStatement;

// ---------------------------------------------------------------------
// filter statement
filterStatement : FILTER (whereClause | searchCondition);

// ---------------------------------------------------------------------
// let statement
letStatement : LET letVariableDefinitionList;

letVariableDefinitionList : letVariableDefinition (COMMA letVariableDefinition)*;

letVariableDefinition
    : valueVariableDefinition
    | bindingVariable EQUALS_OPERATOR valueExpression
    ;

// ---------------------------------------------------------------------
// for statement
forStatement : FOR forItem forOrdinalityOrOffset?;

forItem : forItemAlias forItemSource;

forItemAlias : bindingVariable IN;

forItemSource
    : listValueExpression
    | bindingTableReferenceValueExpression
    ;

forOrdinalityOrOffset : WITH (ORDINALITY | OFFSET) bindingVariable;

// ---------------------------------------------------------------------
// order by and page statement
orderByAndPageStatement
    : orderByClause offsetClause? limitClause?
    | offsetClause limitClause?
    | limitClause
    ;

// ---------------------------------------------------------------------
// primitive result statement
primitiveResultStatement
    : returnStatement orderByAndPageStatement?
    | FINISH
    ;

// ---------------------------------------------------------------------
// return statement
returnStatement : RETURN returnStatementBody;

returnStatementBody
    : setQuantifier? (ASTERISK | returnItemList) groupByClause?
    | NO BINDINGS
    ;

returnItemList : returnItem (COMMA returnItem)*;

returnItem : aggregatingValueExpression returnItemAlias?;

returnItemAlias : AS identifier;

// ---------------------------------------------------------------------
// select statement
selectStatement
    : SELECT setQuantifier? (ASTERISK | selectItemList)
    (selectStatementBody whereClause? groupByClause? havingClause? orderByClause? offsetClause? limitClause?)?
    ;

selectItemList : selectItem (COMMA selectItem)*;

selectItem : aggregatingValueExpression selectItemAlias?;

selectItemAlias : AS identifier;

havingClause : HAVING searchCondition;

selectStatementBody : FROM (selectGraphMatchList | selectQuerySpecification);

selectGraphMatchList : selectGraphMatch (COMMA selectGraphMatch)*;

selectGraphMatch : graphExpression matchStatement;

selectQuerySpecification
    : nestedQuerySpecification
    | graphExpression nestedQuerySpecification
    ;

// *********************************************************************
// call procedure statement and procedure call
callProcedureStatement : OPTIONAL? CALL procedureCall;

procedureCall
    : inlineProcedureCall
    | namedProcedureCall
    ;

// ---------------------------------------------------------------------
// inline procedure call
inlineProcedureCall : variableScopeClause? nestedProcedureSpecification;

variableScopeClause : LEFT_PAREN bindingVariableReferenceList? RIGHT_PAREN;

bindingVariableReferenceList : bindingVariableReference (COMMA bindingVariableReference)*;

// ---------------------------------------------------------------------
// named procedure call
namedProcedureCall : procedureReference LEFT_PAREN procedureArgumentList? RIGHT_PAREN yieldClause?;

procedureArgumentList : procedureArgument (COMMA procedureArgument)*;

procedureArgument : valueExpression;

// *********************************************************************
// at schema clause
atSchemaClause : AT schemaReference;

// ---------------------------------------------------------------------
// use graph clause
useGraphClause : USE graphExpression;

// ---------------------------------------------------------------------
// graph pattern binding table
graphPatternBindingTable : graphPattern graphPatternYieldClause?;

graphPatternYieldClause : YIELD graphPatternYieldItemList;

graphPatternYieldItemList
    : graphPatternYieldItem (COMMA graphPatternYieldItem)*
    | NO BINDINGS
    ;

graphPatternYieldItem
    : elementVariableReference
    | pathVariableReference
    ;

// ---------------------------------------------------------------------
// graph pattern
graphPattern : matchMode? pathPatternList keepClause? graphPatternWhereClause?;

matchMode
    : repeatableElementsMatchMode
    | differentEdgesMatchMode
    ;

repeatableElementsMatchMode : REPEATABLE elementBindingsOrElements;

differentEdgesMatchMode : DIFFERENT edgeBindingsOrEdges;

elementBindingsOrElements
    : ELEMENT BINDINGS?
    | ELEMENTS
    ;

edgeBindingsOrEdges
    : edgeSynonym BINDINGS?
    | edgesSynonym
    ;

pathPatternList : pathPattern (COMMA pathPattern)*;

pathPattern : pathVariableDeclaration? pathPatternPrefix? pathPatternExpression;

pathVariableDeclaration : pathVariable EQUALS_OPERATOR;

keepClause : KEEP pathPatternPrefix;

graphPatternWhereClause : WHERE searchCondition;

// ---------------------------------------------------------------------
// insert graph pattern
insertGraphPattern : insertPathPatternList;

insertPathPatternList : insertPathPattern (COMMA insertPathPattern)*;

insertPathPattern : insertNodePattern (insertEdgePattern insertNodePattern)*;

insertNodePattern : LEFT_PAREN insertElementPatternFiller? RIGHT_PAREN;

insertEdgePattern
    : insertEdgePointingLeft
    | insertEdgePointingRight
    | insertEdgeUndirected
    ;

insertEdgePointingLeft : LEFT_ARROW_BRACKET insertElementPatternFiller? RIGHT_BRACKET_MINUS;

insertEdgePointingRight : MINUS_LEFT_BRACKET insertElementPatternFiller? BRACKET_RIGHT_ARROW;

insertEdgeUndirected : TILDE_LEFT_BRACKET insertElementPatternFiller? RIGHT_BRACKET_TILDE;

insertElementPatternFiller
    : elementVariableDeclaration labelAndPropertySetSpecification?
    | elementVariableDeclaration? labelAndPropertySetSpecification
    ;

labelAndPropertySetSpecification
    : isOrColon labelSetSpecification elementPropertySpecification?
    | (isOrColon labelSetSpecification)? elementPropertySpecification
    ;

// ---------------------------------------------------------------------
// path pattern prefix
pathPatternPrefix
    : pathModePrefix
    | pathSearchPrefix
    ;

pathModePrefix : pathMode pathOrPaths?;

pathMode
    : WALK
    | TRAIL
    | SIMPLE
    | ACYCLIC
    ;

pathSearchPrefix
    : allPathSearch
    | anyPathSearch
    | shortestPathSearch
    ;

allPathSearch : ALL pathMode? pathOrPaths?;

pathOrPaths
    : PATH
    | PATHS
    ;

anyPathSearch : ANY numberOfPaths? pathMode? pathOrPaths?;

numberOfPaths : nonNegativeIntegerSpecification;

shortestPathSearch
    : allShortestPathSearch
    | anyShortestPathSearch
    | countedShortestPathSearch
    | countedShortestGroupSearch
    ;

allShortestPathSearch : ALL SHORTEST pathMode? pathOrPaths?;

anyShortestPathSearch : ANY SHORTEST pathMode? pathOrPaths?;

countedShortestPathSearch : SHORTEST numberOfPaths pathMode? pathOrPaths?;

countedShortestGroupSearch : SHORTEST numberOfGroups? pathMode? pathOrPaths? (GROUP | GROUPS);

numberOfGroups : nonNegativeIntegerSpecification;

// ---------------------------------------------------------------------
// path pattern expression
pathPatternExpression
    : pathTerm
    | pathMultisetAlternation
    | pathPatternUnion
    ;

pathMultisetAlternation : pathTerm MULTISET_ALTERNATION_OPERATOR pathTerm (MULTISET_ALTERNATION_OPERATOR pathTerm)*;

pathPatternUnion : pathTerm VERTICAL_BAR pathTerm (VERTICAL_BAR pathTerm)*;

pathTerm
    : pathFactor
    | pathConcatenation
    ;

pathConcatenation : pathFactor pathTerm;

pathFactor
    : pathPrimary
    | quantifiedPathPrimary
    | questionedPathPrimary
    ;

quantifiedPathPrimary : pathPrimary graphPatternQuantifier;

questionedPathPrimary : pathPrimary QUESTION_MARK;

pathPrimary
    : elementPattern
    | parenthesizedPathPatternExpression
    | simplifiedPathPatternExpression
    ;

elementPattern
    : nodePattern
    | edgePattern
    ;

nodePattern : LEFT_PAREN elementPatternFiller RIGHT_PAREN;

elementPatternFiller : elementVariableDeclaration? isLabelExpression? elementPatternPredicate?;

elementVariableDeclaration : TEMP? elementVariable;

isLabelExpression : isOrColon labelExpression;

isOrColon
    : IS
    | COLON
    ;

elementPatternPredicate
    : elementPatternWhereClause
    | elementPropertySpecification
    ;

elementPatternWhereClause : WHERE searchCondition;

elementPropertySpecification : LEFT_BRACE propertyKeyValuePairList RIGHT_BRACE;

propertyKeyValuePairList : propertyKeyValuePair (COMMA propertyKeyValuePair)*;

propertyKeyValuePair : propertyName COLON valueExpression;

edgePattern
    : fullEdgePattern
    | abbreviatedEdgePattern
    ;

fullEdgePattern
    : fullEdgePointingLeft
    | fullEdgeUndirected
    | fullEdgePointingRight
    | fullEdgeLeftOrUndirected
    | fullEdgeUndirectedOrRight
    | fullEdgeLeftOrRight
    | fullEdgeAnyDirection
    ;

fullEdgePointingLeft : LEFT_ARROW_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS;

fullEdgeUndirected : TILDE_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE;

fullEdgePointingRight : MINUS_LEFT_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW;

fullEdgeLeftOrUndirected : LEFT_ARROW_TILDE_BRACKET elementPatternFiller RIGHT_BRACKET_TILDE;

fullEdgeUndirectedOrRight : TILDE_LEFT_BRACKET elementPatternFiller BRACKET_TILDE_RIGHT_ARROW;

fullEdgeLeftOrRight : LEFT_ARROW_BRACKET elementPatternFiller BRACKET_RIGHT_ARROW;

fullEdgeAnyDirection : MINUS_LEFT_BRACKET elementPatternFiller RIGHT_BRACKET_MINUS;

abbreviatedEdgePattern
    : LEFT_ARROW
    | TILDE
    | RIGHT_ARROW
    | LEFT_ARROW_TILDE
    | TILDE_RIGHT_ARROW
    | LEFT_MINUS_RIGHT
    | MINUS_SIGN
    ;

parenthesizedPathPatternExpression
    : LEFT_PAREN subpathVariableDeclaration? pathModePrefix? pathPatternExpression parenthesizedPathPatternWhereClause? RIGHT_PAREN
    ;

subpathVariableDeclaration : subpathVariable EQUALS_OPERATOR;

parenthesizedPathPatternWhereClause : WHERE searchCondition;

// ---------------------------------------------------------------------
// label expression
labelExpression
    : labelTerm
    | labelDisjunction
    ;

labelDisjunction : labelTerm VERTICAL_BAR labelExpression;

labelTerm
    : labelFactor
    | labelConjunction
    ;

labelConjunction : labelFactor AMPERSAND labelTerm;

labelFactor
    : labelPrimary
    | labelNegation
    ;

labelNegation : EXCLAMATION_MARK labelPrimary;

labelPrimary
    : labelName
    | wildcardLabel
    | parenthesizedLabelExpression
    ;

wildcardLabel : PERCENT;

parenthesizedLabelExpression : LEFT_PAREN labelExpression RIGHT_PAREN;

// ---------------------------------------------------------------------
// path variable reference
pathVariableReference : bindingVariableReference;

// ---------------------------------------------------------------------
// element variable reference
elementVariableReference : bindingVariableReference;

// ---------------------------------------------------------------------
// graph_pattern quantifier
graphPatternQuantifier
    : ASTERISK
    | PLUS_SIGN
    | fixedQuantifier
    | generalQuantifier
    ;

fixedQuantifier : LEFT_BRACE unsignedInteger RIGHT_BRACE;

generalQuantifier : LEFT_BRACE lowerBound? COMMA upperBound? RIGHT_BRACE;

lowerBound : unsignedInteger;

upperBound : unsignedInteger;

// ---------------------------------------------------------------------
// simplified path pattern expression
simplifiedPathPatternExpression
    : simplifiedDefaultingLeft
    | simplifiedDefaultingUndirected
    | simplifiedDefaultingRight
    | simplifiedDefaultingLeftOrUndirected
    | simplifiedDefaultingUndirectedOrRight
    | simplifiedDefaultingLeftOrRight
    | simplifiedDefaultingAnyDirection
    ;

simplifiedDefaultingLeft : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS;

simplifiedDefaultingUndirected : TILDE_SLASH simplifiedContents SLASH_TILDE;

simplifiedDefaultingRight : MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT;

simplifiedDefaultingLeftOrUndirected : LEFT_TILDE_SLASH simplifiedContents SLASH_TILDE;

simplifiedDefaultingUndirectedOrRight : TILDE_SLASH simplifiedContents SLASH_TILDE_RIGHT;

simplifiedDefaultingLeftOrRight : LEFT_MINUS_SLASH simplifiedContents SLASH_MINUS_RIGHT;

simplifiedDefaultingAnyDirection : MINUS_SLASH simplifiedContents SLASH_MINUS;

simplifiedContents
    : simplifiedTerm
    | simplifiedPathUnion
    | simplifiedMultisetAlternation
    ;

simplifiedPathUnion : simplifiedTerm VERTICAL_BAR simplifiedTerm (VERTICAL_BAR simplifiedTerm)*;

simplifiedMultisetAlternation
    : simplifiedTerm MULTISET_ALTERNATION_OPERATOR simplifiedTerm (MULTISET_ALTERNATION_OPERATOR simplifiedTerm)*
    ;

simplifiedTerm
    : simplifiedFactorLow
    | simplifiedConcatenation
    ;

simplifiedConcatenation : simplifiedFactorLow simplifiedTerm;

simplifiedFactorLow
    : simplifiedFactorHigh
    | simplifiedConjunction
    ;

simplifiedConjunction : simplifiedFactorHigh AMPERSAND simplifiedFactorLow;

simplifiedFactorHigh
    : simplifiedTertiary
    | simplifiedQuantified
    | simplifiedQuestioned
    ;

simplifiedQuantified : simplifiedTertiary graphPatternQuantifier;

simplifiedQuestioned : simplifiedTertiary QUESTION_MARK;

simplifiedTertiary
    : simplifiedDirectionOverride
    | simplifiedSecondary
    ;

simplifiedDirectionOverride
    : simplifiedOverrideLeft
    | simplifiedOverrideUndirected
    | simplifiedOverrideRight
    | simplifiedOverrideLeftOrUndirected
    | simplifiedOverrideUndirectedOrRight
    | simplifiedOverrideLeftOrRight
    | simplifiedOverrideAnyDirection
    ;

simplifiedOverrideLeft : LEFT_ANGLE_BRACKET simplifiedSecondary;

simplifiedOverrideUndirected : TILDE simplifiedSecondary;

simplifiedOverrideRight : simplifiedSecondary RIGHT_ANGLE_BRACKET;

simplifiedOverrideLeftOrUndirected : LEFT_ARROW_TILDE simplifiedSecondary;

simplifiedOverrideUndirectedOrRight : TILDE simplifiedSecondary RIGHT_ANGLE_BRACKET;

simplifiedOverrideLeftOrRight : LEFT_ANGLE_BRACKET simplifiedSecondary RIGHT_ANGLE_BRACKET;

simplifiedOverrideAnyDirection : MINUS_SIGN simplifiedSecondary;

simplifiedSecondary
    : simplifiedPrimary
    | simplifiedNegation
    ;

simplifiedNegation : EXCLAMATION_MARK simplifiedPrimary;

simplifiedPrimary
    : labelName
    | LEFT_PAREN simplifiedContents RIGHT_PAREN
    ;

// ---------------------------------------------------------------------
// where clause
whereClause : WHERE searchCondition;

// ---------------------------------------------------------------------
// yield clause
yieldClause : YIELD yieldItemList;

yieldItemList : yieldItem (COMMA yieldItem)*;

yieldItem : yieldItemName yieldItemAlias?;

yieldItemName : fieldName;

yieldItemAlias : AS bindingVariable;

// ---------------------------------------------------------------------
// group by clause
groupByClause : GROUP BY groupingElementList;

groupingElementList
    : groupingElement (COMMA groupingElement)*
    | emptyGroupingSet
    ;

groupingElement : bindingVariableReference;

emptyGroupingSet : LEFT_PAREN RIGHT_PAREN;


// ---------------------------------------------------------------------
// order by clause
orderByClause : ORDER BY sortSpecificationList;

// ---------------------------------------------------------------------
// sort specification list
sortSpecificationList : sortSpecification (COMMA sortSpecification)*;

sortSpecification : sortKey orderingSpecification? nullOrdering?;

sortKey : aggregatingValueExpression;

orderingSpecification
    : ASC
    | ASCENDING
    | DESC
    | DESCENDING
    ;

nullOrdering
    : NULLS FIRST
    | NULLS LAST
    ;

// ---------------------------------------------------------------------
// limit clause
limitClause : LIMIT nonNegativeIntegerSpecification;

// ---------------------------------------------------------------------
// offset clause
offsetClause : offsetSynonym nonNegativeIntegerSpecification;

offsetSynonym
    : OFFSET
    | SKIP_TOKEN
    ;

// *********************************************************************
// schema reference and catalog schema parent and name
schemaReference
    : absoluteCatalogSchemaReference
    | relativeCatalogSchemaReference
    | referenceParameterSpecification
    ;

absoluteCatalogSchemaReference
    : SOLIDUS
    | absoluteDirectoryPath schemaName
    ;

catalogSchemaParentAndName : absoluteDirectoryPath schemaName;

relativeCatalogSchemaReference
    : predefinedSchemaReference
    | relativeDirectoryPath schemaName
    ;

predefinedSchemaReference
    : HOME_SCHEMA
    | CURRENT_SCHEMA
    | PERIOD
    ;

absoluteDirectoryPath : SOLIDUS simpleDirectoryPath?;

relativeDirectoryPath : DOUBLE_PERIOD ((SOLIDUS DOUBLE_PERIOD)+ SOLIDUS simpleDirectoryPath?)?;

simpleDirectoryPath : (directoryName SOLIDUS)+;

// ---------------------------------------------------------------------
// graph reference and catalog graph parent and name
graphReference
    : catalogObjectParentReference graphName
    | delimitedGraphName
    | homeGraph
    | referenceParameterSpecification
    ;

catalogGraphParentAndName : catalogObjectParentReference? graphName;

homeGraph
    : HOME_PROPERTY_GRAPH
    | HOME_GRAPH
    ;

// ---------------------------------------------------------------------
// graph type reference and catalog graph type parent and name
graphTypeReference
    : catalogGraphTypeParentAndName
    | referenceParameterSpecification
    ;

catalogGraphTypeParentAndName : catalogObjectParentReference? graphTypeName;

// ---------------------------------------------------------------------
// binding table reference and catalog binding table parent and name
bindingTableReference
    : catalogObjectParentReference bindingTableName
    | delimitedBindingTableName
    | referenceParameterSpecification
    ;

catalogBindingTableParentAndName : catalogObjectParentReference? bindingTableName;

// ---------------------------------------------------------------------
// procedure reference and catalog procedure parent and name
procedureReference
    : catalogProcedureParentAndName
    | referenceParameterSpecification
    ;

catalogProcedureParentAndName : catalogObjectParentReference? procedureName;

// ---------------------------------------------------------------------
// catalog object parent reference
catalogObjectParentReference
    : schemaReference SOLIDUS? (objectName PERIOD)*
    | (objectName PERIOD)+
    ;

// ---------------------------------------------------------------------
// reference parameter specification
referenceParameterSpecification : substitutedParameterReference;

// ---------------------------------------------------------------------
// external object reference
externalObjectReference : EXTERNALURI;

// *********************************************************************
// nested graph type specification
nestedGraphTypeSpecification : LEFT_BRACE graphTypeSpecificationBody RIGHT_BRACE;

graphTypeSpecificationBody : elementTypeList;

elementTypeList : elementTypeSpecification (COMMA elementTypeSpecification)*;

elementTypeSpecification
    : nodeTypeSpecification
    | edgeTypeSpecification
    ;

// ---------------------------------------------------------------------
// node type specification
nodeTypeSpecification
    : nodeTypePattern
    | nodeTypePhrase
    ;

nodeTypePattern
    : (nodeSynonym TYPE? nodeTypeName)? LEFT_PAREN localNodeTypeAlias? nodeTypeFiller? RIGHT_PAREN
    ;

nodeTypePhrase : nodeSynonym TYPE? nodeTypePhraseFiller (AS localNodeTypeAlias)?;

nodeTypePhraseFiller
    : nodeTypeName nodeTypeFiller?
    | nodeTypeFiller
    ;

nodeTypeFiller
    : nodeTypeKeyLabelSet nodeTypeImpliedContent?
    | nodeTypeImpliedContent
    ;

localNodeTypeAlias : REGULAR_IDENTIFIER;

nodeTypeImpliedContent
    : nodeTypeLabelSet
    | nodeTypePropertyTypes
    | nodeTypeLabelSet nodeTypePropertyTypes
    ;

nodeTypeKeyLabelSet : labelSetPhrase? implies;

nodeTypeLabelSet : labelSetPhrase;

nodeTypePropertyTypes : propertyTypesSpecification;

// ---------------------------------------------------------------------
// edge type specification
edgeTypeSpecification
    : edgeTypePattern
    | edgeTypePhrase
    ;

edgeTypePattern
    : (edgeKind? edgeSynonym TYPE? edgeTypeName)? (edgeTypePatternDirected | edgeTypePatternUndirected)
    ;

edgeTypePhrase : edgeKind edgeSynonym TYPE? edgeTypePhraseFiller endpointPairPhrase;

edgeTypePhraseFiller
    : edgeTypeName edgeTypeFiller?
    | edgeTypeFiller
    ;

edgeTypeFiller
    : edgeTypeKeyLabelSet edgeTypeImpliedContent?
    | edgeTypeImpliedContent
    ;

edgeTypeImpliedContent
    : edgeTypeLabelSet
    | edgeTypePropertyTypes
    | edgeTypeLabelSet edgeTypePropertyTypes
    ;

edgeTypeKeyLabelSet : labelSetPhrase? implies;

edgeTypeLabelSet : labelSetPhrase;

edgeTypePropertyTypes : propertyTypesSpecification;

edgeTypePatternDirected
    : edgeTypePatternPointingRight
    | edgeTypePatternPointingLeft
    ;

edgeTypePatternPointingRight : sourceNodeTypeReference arcTypePointingRight destinationNodeTypeReference;

edgeTypePatternPointingLeft : destinationNodeTypeReference arcTypePointingLeft sourceNodeTypeReference;

edgeTypePatternUndirected : sourceNodeTypeReference arcTypeUndirected destinationNodeTypeReference;

arcTypePointingRight : MINUS_LEFT_BRACKET edgeTypeFiller BRACKET_RIGHT_ARROW;

arcTypePointingLeft : LEFT_ARROW_BRACKET edgeTypeFiller RIGHT_BRACKET_MINUS;

arcTypeUndirected : TILDE_LEFT_BRACKET edgeTypeFiller RIGHT_BRACKET_TILDE;

sourceNodeTypeReference
    : LEFT_PAREN sourceNodeTypeAlias RIGHT_PAREN
    | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
    ;

destinationNodeTypeReference
    : LEFT_PAREN destinationNodeTypeAlias RIGHT_PAREN
    | LEFT_PAREN nodeTypeFiller? RIGHT_PAREN
    ;

edgeKind
    : DIRECTED
    | UNDIRECTED
    ;

endpointPairPhrase : CONNECTING endpointPair;

endpointPair
    : endpointPairDirected
    | endpointPairUndirected
    ;

endpointPairDirected
    : endpointPairPointingRight
    | endpointPairPointingLeft
    ;

endpointPairPointingRight
    : LEFT_PAREN sourceNodeTypeAlias connectorPointingRight destinationNodeTypeAlias RIGHT_PAREN
    ;

endpointPairPointingLeft
    : LEFT_PAREN destinationNodeTypeAlias LEFT_ARROW sourceNodeTypeAlias RIGHT_PAREN
    ;

endpointPairUndirected
    : LEFT_PAREN sourceNodeTypeAlias connectorUndirected destinationNodeTypeAlias RIGHT_PAREN
    ;

connectorPointingRight
    : TO
    | RIGHT_ARROW
    ;

connectorUndirected
    : TO
    | TILDE
    ;

sourceNodeTypeAlias : REGULAR_IDENTIFIER;

destinationNodeTypeAlias : REGULAR_IDENTIFIER;

// ---------------------------------------------------------------------
// label set phrase and label set specification
labelSetPhrase
    : LABEL labelName
    | LABELS labelSetSpecification
    | isOrColon labelSetSpecification
    ;

labelSetSpecification : labelName (AMPERSAND labelName)*;

// ---------------------------------------------------------------------
// property types specification
propertyTypesSpecification : LEFT_BRACE propertyTypeList? RIGHT_BRACE;

propertyTypeList : propertyType (COMMA propertyType)*;

// ---------------------------------------------------------------------
// property type
propertyType : propertyName typed? propertyValueType;

// ---------------------------------------------------------------------
// property value type
propertyValueType : valueType;

// ---------------------------------------------------------------------
// binding table type
bindingTableType : BINDING? TABLE fieldTypesSpecification;

// ---------------------------------------------------------------------
// value type
// changed from the original grammar to remove left recursion and ambiguity
// note: if one day some rule uses a rule larger then list_value_type_name
//       or larger then closed_dynamic_union_value_type
//       and smaller then the rule value_type, then there would be a bug
valueType : nonCompositeValueType (VERTICAL_BAR nonCompositeValueType)*;

nonCompositeValueType : valueTypeSpecialCase listValueTypeName (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?;

valueTypeSpecialCase
    : predefinedType
    | constructedValueType
    | dynamicUnionType
    ;

typed
    : DOUBLE_COLON
    | TYPED
    ;

predefinedType
    : booleanType
    | characterStringType
    | byteStringType
    | numericType
    | temporalType
    | referenceValueType
    | immaterialValueType
    ;

booleanType : (BOOL | BOOLEAN) notNull?;

characterStringType
    : STRING (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
    | CHAR (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
    | VARCHAR (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
    ;

byteStringType
    : BYTES (LEFT_PAREN (minLength COMMA)? maxLength RIGHT_PAREN)? notNull?
    | BINARY (LEFT_PAREN fixedLength RIGHT_PAREN)? notNull?
    | VARBINARY (LEFT_PAREN maxLength RIGHT_PAREN)? notNull?
    ;

minLength : unsignedInteger;

maxLength : unsignedInteger;

fixedLength : unsignedInteger;

// ---------------------------------------------------------------------
// numeric type
numericType
    : exactNumericType
    | approximateNumericType
    ;

exactNumericType
    : binaryExactNumericType
    | decimalExactNumericType
    ;

binaryExactNumericType
    : signedBinaryExactNumericType
    | unsignedBinaryExactNumericType
    ;

signedBinaryExactNumericType
    : INT8 notNull?
    | INT16 notNull?
    | INT32 notNull?
    | INT64 notNull?
    | INT128 notNull?
    | INT256 notNull?
    | SMALLINT notNull?
    | INT (LEFT_PAREN precision RIGHT_PAREN)? notNull?
    | BIGINT notNull?
    | SIGNED? verboseBinaryExactNumericType
    ;

unsignedBinaryExactNumericType
    : UINT8 notNull?
    | UINT16 notNull?
    | UINT32 notNull?
    | UINT64 notNull?
    | UINT128 notNull?
    | UINT256 notNull?
    | USMALLINT notNull?
    | UINT (LEFT_PAREN precision RIGHT_PAREN)? notNull?
    | UBIGINT notNull?
    | UNSIGNED verboseBinaryExactNumericType
    ;

verboseBinaryExactNumericType
    : INTEGER8 notNull?
    | INTEGER16 notNull?
    | INTEGER32 notNull?
    | INTEGER64 notNull?
    | INTEGER128 notNull?
    | INTEGER256 notNull?
    | SMALL INTEGER notNull?
    | INTEGER (LEFT_PAREN precision RIGHT_PAREN)? notNull?
    | BIG INTEGER notNull?
    ;

decimalExactNumericType : (DECIMAL | DEC) (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN notNull?)?;

precision : UNSIGNED_DECIMAL_INTEGER;

scale : UNSIGNED_DECIMAL_INTEGER;

approximateNumericType
    : FLOAT16 notNull?
    | FLOAT32 notNull?
    | FLOAT64 notNull?
    | FLOAT128 notNull?
    | FLOAT256 notNull?
    | FLOAT (LEFT_PAREN precision (COMMA scale)? RIGHT_PAREN)? notNull?
    | REAL notNull?
    | DOUBLE PRECISION? notNull?
    ;

// ---------------------------------------------------------------------
// temporal type
temporalType
    : temporalInstantType
    | temporalDurationType
    ;

temporalInstantType
    : datetimeType
    | localdatetimeType
    | dateType
    | timeType
    | localtimeType
    ;

datetimeType
    : ZONED DATETIME notNull?
    | TIMESTAMP WITH TIME ZONE notNull?
    ;

localdatetimeType
    : LOCAL DATETIME notNull?
    | TIMESTAMP (WITHOUT TIME ZONE)? notNull?
    ;

dateType : DATE notNull?;

timeType
    : ZONED TIME notNull?
    | TIME WITH TIME ZONE notNull?
    ;

localtimeType
    : LOCAL TIME notNull?
    | TIME WITHOUT TIME ZONE notNull?
    ;

temporalDurationType : DURATION LEFT_PAREN temporalDurationQualifier RIGHT_PAREN notNull?;

temporalDurationQualifier
    : YEAR TO MONTH
    | DAY TO SECOND
    ;

// ---------------------------------------------------------------------
// reference value type
referenceValueType
    : graphReferenceValueType
    | bindingTableReferenceValueType
    | nodeReferenceValueType
    | edgeReferenceValueType
    ;

immaterialValueType
    : nullType
    | emptyType
    ;

nullType : NULL;

emptyType
    : NULL notNull
    | NOTHING
    ;

graphReferenceValueType
    : openGraphReferenceValueType
    | closedGraphReferenceValueType
    ;

closedGraphReferenceValueType : PROPERTY? GRAPH nestedGraphTypeSpecification notNull?;

openGraphReferenceValueType : ANY? PROPERTY? GRAPH notNull?;

bindingTableReferenceValueType : bindingTableType notNull?;

nodeReferenceValueType
    : openNodeReferenceValueType
    | closedNodeReferenceValueType
    ;

closedNodeReferenceValueType : nodeTypeSpecification notNull?;

openNodeReferenceValueType : ANY? nodeSynonym notNull?;

edgeReferenceValueType
    : openEdgeReferenceValueType
    | closedEdgeReferenceValueType
    ;

closedEdgeReferenceValueType : edgeTypeSpecification notNull?;

openEdgeReferenceValueType : ANY? edgeSynonym notNull?;

// ---------------------------------------------------------------------
// constructed value type
constructedValueType
    : pathValueType
    | listValueType
    | recordType
    ;

pathValueType : PATH notNull?;

listValueType
    : listValueTypeName LEFT_ANGLE_BRACKET valueType RIGHT_ANGLE_BRACKET (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?
    | listValueTypeName (LEFT_BRACKET maxLength RIGHT_BRACKET)? notNull?
//  | value_type list_value_type_name (LEFT_BRACKET max_length RIGHT_BRACKET)? not_null?
    ;

listValueTypeName : GROUP? listValueTypeNameSynonym;

listValueTypeNameSynonym
    : LIST
    | ARRAY
    ;

recordType
    : ANY? RECORD notNull?
    | RECORD? fieldTypesSpecification notNull?
    ;

fieldTypesSpecification : LEFT_BRACE fieldTypeList? RIGHT_BRACE;

fieldTypeList : fieldType (COMMA fieldType)*;

// ---------------------------------------------------------------------
// dynamic union type
dynamicUnionType
    : openDynamicUnionType
    | dynamicPropertyValueType
    | closedDynamicUnionType
    ;

openDynamicUnionType : ANY VALUE? notNull?;

dynamicPropertyValueType : ANY? PROPERTY VALUE notNull?;

closedDynamicUnionType
    : ANY VALUE? LEFT_ANGLE_BRACKET componentTypeList RIGHT_ANGLE_BRACKET
//  | component_type_list
    ;

componentTypeList : componentType (VERTICAL_BAR componentType)*;

componentType : valueType;

notNull : NOT NULL;

// ---------------------------------------------------------------------
// field type
fieldType : fieldName typed? valueType;

// *********************************************************************
// search condition
searchCondition : booleanValueExpression;

// ---------------------------------------------------------------------
// predicate
predicate
    : comparisonPredicate
    | existsPredicate
    | nullPredicate
    | normalizedPredicate
    | valueTypePredicate
    | directedPredicate
    | labeledPredicate
    | sourceDestinationPredicate
    | allDifferentPredicate
    | samePredicate
    | propertyExistsPredicate
    ;

// ---------------------------------------------------------------------
// comparison predicate
comparisonPredicate : comparisonPredicand comparisonPredicatePart2;

comparisonPredicatePart2 : compOp comparisonPredicand;

compOp
    : EQUALS_OPERATOR
    | NOT_EQUALS_OPERATOR
    | lessThanOperator
    | greaterThanOperator
    | LESS_THAN_OR_EQUALS_OPERATOR
    | GREATER_THAN_OR_EQUALS_OPERATOR
    ;

comparisonPredicand
    : commonValueExpression
    | booleanPredicand
    ;

// ---------------------------------------------------------------------
// exists predicate
existsPredicate
    : EXISTS (LEFT_BRACE graphPattern RIGHT_BRACE | LEFT_PAREN graphPattern RIGHT_PAREN
        | LEFT_BRACE matchStatementBlock RIGHT_BRACE | LEFT_PAREN matchStatementBlock RIGHT_PAREN
        | nestedQuerySpecification)
    ;

// ---------------------------------------------------------------------
// null predicate
nullPredicate : valueExpressionPrimary nullPredicatePart2;

nullPredicatePart2 : IS NOT? NULL;

// ---------------------------------------------------------------------
// value type predicate
valueTypePredicate : valueExpressionPrimary valueTypePredicatePart2;

valueTypePredicatePart2 : IS NOT? typed valueType;


// ---------------------------------------------------------------------
// normalized predicate
normalizedPredicate : stringValueExpression normalizedPredicatePart2;

normalizedPredicatePart2 : IS NOT? normalForm? NORMALIZED;

// ---------------------------------------------------------------------
// directed predicate
directedPredicate : elementVariableReference directedPredicatePart2;

directedPredicatePart2 : IS NOT? DIRECTED;

// ---------------------------------------------------------------------
// labeled predicate
labeledPredicate : elementVariableReference labeledPredicatePart2;

labeledPredicatePart2 : isLabeledOrColon labelExpression;

isLabeledOrColon
    : IS NOT? LABELED
    | COLON
    ;

// ---------------------------------------------------------------------
// source/destination predicate
sourceDestinationPredicate
    : nodeReference sourcePredicatePart2
    | nodeReference destinationPredicatePart2
    ;

nodeReference : elementVariableReference;

sourcePredicatePart2 : IS NOT? SOURCE OF edgeReference;

destinationPredicatePart2 : IS NOT? DESTINATION OF edgeReference;

edgeReference : elementVariableReference;

// ---------------------------------------------------------------------
// all_different predicate
allDifferentPredicate : ALL_DIFFERENT LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN;

// ---------------------------------------------------------------------
// same predicate
samePredicate
    : SAME LEFT_PAREN elementVariableReference COMMA elementVariableReference (COMMA elementVariableReference)* RIGHT_PAREN
    ;

// ---------------------------------------------------------------------
// property_exists predicate
propertyExistsPredicate : PROPERTY_EXISTS LEFT_PAREN elementVariableReference COMMA propertyName RIGHT_PAREN;

// *********************************************************************
// value_expression
valueExpression
    : commonValueExpression
    | booleanValueExpression
    ;

commonValueExpression
    : numericValueExpression
    | stringValueExpression
    | datetimeValueExpression
    | durationValueExpression
    | listValueExpression
    | recordExpression
    | pathValueExpression
    | referenceValueExpression
    ;

// changed from original
// because as parser can't distinguish between node_reference_value_expression
// and edge_reference_value_expression
referenceValueExpression
    : valueExpressionPrimary
    | graphReferenceValueExpression
    | bindingTableReferenceValueExpression
    ;

graphReferenceValueExpression
    : PROPERTY? GRAPH graphExpression
    | valueExpressionPrimary
    ;

bindingTableReferenceValueExpression
    : BINDING? TABLE bindingTableExpression
    | valueExpressionPrimary
    ;

nodeReferenceValueExpression : valueExpressionPrimary;

edgeReferenceValueExpression : valueExpressionPrimary;

recordExpression : valueExpressionPrimary;

aggregatingValueExpression : valueExpression;

// ---------------------------------------------------------------------
// value expression primary
// changed from original to reduce left recursion
valueExpressionPrimary
    : parenthesizedValueExpression
    | nonParenthesizedValueExpressionPrimary
    ;

parenthesizedValueExpression : LEFT_PAREN valueExpression RIGHT_PAREN;

nonParenthesizedValueExpressionPrimary
    : nonParenthesizedValueExpressionPrimarySpecialCase
    | bindingVariableReference
    ;

nonParenthesizedValueExpressionPrimarySpecialCase
    : aggregateFunction
    | unsignedValueSpecification
    | listValueConstructor
    | recordConstructor
    | pathValueConstructor
    | propertyReference
    | valueQueryExpression
    | caseExpression
    | castSpecification
    | elementIdFunction
    | letValueExpression
    ;

// ---------------------------------------------------------------------
// value specification
valueSpecification
    : literal
    | generalValueSpecification
    ;

unsignedValueSpecification
    : unsignedLiteral
    | generalValueSpecification
    ;

nonNegativeIntegerSpecification
    : unsignedInteger
    | dynamicParameterSpecification
    ;

generalValueSpecification
    : dynamicParameterSpecification
    | SESSION_USER
    ;

// ---------------------------------------------------------------------
// dynamic parameter specification
dynamicParameterSpecification : generalParameterReference;

// ---------------------------------------------------------------------
// let value expression
letValueExpression : LET letVariableDefinitionList IN valueExpression END;

// ---------------------------------------------------------------------
// value query expression
valueQueryExpression : VALUE nestedQuerySpecification;

// ---------------------------------------------------------------------
// case expression
caseExpression
    : caseAbbreviation
    | caseSpecification
    ;

caseAbbreviation
    : NULLIF LEFT_PAREN valueExpression COMMA valueExpression RIGHT_PAREN
    | COALESCE LEFT_PAREN valueExpression (COMMA valueExpression)+ RIGHT_PAREN
    ;

caseSpecification
    : simpleCase
    | searchedCase
    ;

simpleCase : CASE caseOperand simpleWhenClause+ elseClause? END;

searchedCase : CASE searchedWhenClause+ elseClause? END;

simpleWhenClause : WHEN whenOperandList THEN result;

searchedWhenClause : WHEN searchCondition THEN result;

elseClause : ELSE result;

caseOperand
    : nonParenthesizedValueExpressionPrimary
    | elementVariableReference
    ;

whenOperandList : whenOperand (COMMA whenOperand)*;

whenOperand
    : nonParenthesizedValueExpressionPrimary
    | comparisonPredicatePart2
    | nullPredicatePart2
    | valueTypePredicatePart2
    | normalizedPredicatePart2
    | directedPredicatePart2
    | labeledPredicatePart2
    | sourcePredicatePart2
    | destinationPredicatePart2
    ;

result
    : resultExpression
    | nullLiteral
    ;

resultExpression : valueExpression;

// ---------------------------------------------------------------------
// cast specification
castSpecification : CAST LEFT_PAREN castOperand AS castTarget RIGHT_PAREN;

castOperand
    : valueExpression
    | nullLiteral
    ;

castTarget : valueType;

// ---------------------------------------------------------------------
// aggregate function
aggregateFunction
    : COUNT LEFT_PAREN ASTERISK RIGHT_PAREN
    | generalSetFunction
    | binarySetFunction
    ;

generalSetFunction : generalSetFunctionType LEFT_PAREN setQuantifier? valueExpression RIGHT_PAREN;

binarySetFunction : binarySetFunctionType LEFT_PAREN dependentValueExpression COMMA independentValueExpression RIGHT_PAREN;

generalSetFunctionType
    : AVG
    | COUNT
    | MAX
    | MIN
    | SUM
    | COLLECT_LIST
    | STDDEV_SAMP
    | STDDEV_POP
    ;

setQuantifier
    : DISTINCT
    | ALL
    ;

binarySetFunctionType
    : PERCENTILE_CONT
    | PERCENTILE_DISC
    ;

dependentValueExpression : setQuantifier? numericValueExpression;

independentValueExpression : numericValueExpression;

// ---------------------------------------------------------------------
// element_id function
elementIdFunction : ELEMENT_ID LEFT_PAREN elementVariableReference RIGHT_PAREN;

// ---------------------------------------------------------------------
// property reference
// changed from original to reduce left recursion
propertyReference
    : propertySource PERIOD propertyName
    | propertyReference PERIOD propertyName
    ;

propertySource
    : parenthesizedValueExpression
    | bindingVariableReference
    | aggregateFunction
    | unsignedValueSpecification
    | listValueConstructor
    | recordConstructor
    | pathValueConstructor
    | valueQueryExpression
    | caseExpression
    | castSpecification
    | elementIdFunction
    | letValueExpression
    ;

// ---------------------------------------------------------------------
// binding variable reference
bindingVariableReference : bindingVariable;

// ---------------------------------------------------------------------
// path value expression
pathValueExpression
    : pathValueConcatenation
    | pathValuePrimary
    ;

pathValueConcatenation :  pathValuePrimary CONCATENATION_OPERATOR pathValueExpression;

pathValuePrimary : valueExpressionPrimary;

// ---------------------------------------------------------------------
// path value constructor
pathValueConstructor : pathValueConstructorByEnumeration;

pathValueConstructorByEnumeration : PATH LEFT_BRACKET pathElementList RIGHT_BRACKET;

pathElementList : pathElementListStart pathElementListStep*;

pathElementListStart : nodeReferenceValueExpression;

pathElementListStep : COMMA edgeReferenceValueExpression COMMA nodeReferenceValueExpression;

// ---------------------------------------------------------------------
// list value expression
listValueExpression
    : listConcatenation
    | listPrimary
    ;

listConcatenation : listPrimary CONCATENATION_OPERATOR listValueExpression;

listPrimary
    : listValueFunction
    | valueExpressionPrimary
    ;

// ---------------------------------------------------------------------
// list value function
listValueFunction
    : trimListFunction
    | elementsFunction
    ;

trimListFunction : TRIM LEFT_PAREN listValueExpression COMMA numericValueExpression RIGHT_PAREN;

elementsFunction : ELEMENTS LEFT_PAREN pathValueExpression RIGHT_PAREN;

// ---------------------------------------------------------------------
// list value constructor
listValueConstructor : listValueConstructorByEnumeration;

listValueConstructorByEnumeration : listValueTypeName? LEFT_BRACKET listElementList? RIGHT_BRACKET;

listElementList : listElement (COMMA listElement)*;

listElement : valueExpression;

// ---------------------------------------------------------------------
// record constructor
recordConstructor : RECORD? fieldsSpecification;

fieldsSpecification : LEFT_BRACE fieldList? RIGHT_BRACE;

fieldList : field (COMMA field)*;

// ---------------------------------------------------------------------
// field
field : fieldName COLON valueExpression;

// ---------------------------------------------------------------------
// boolean value expression
booleanValueExpression
    : booleanTerm
    | booleanValueExpression OR booleanTerm
    | booleanValueExpression XOR booleanTerm
    ;

booleanTerm
    : booleanFactor
    | booleanTerm AND booleanFactor
    ;

booleanFactor : NOT? booleanTest;

booleanTest : booleanPrimary (IS NOT? truthValue)?;

truthValue
    : TRUE
    | FALSE
    | UNKNOWN
    ;

booleanPrimary
    : predicate
    | booleanPredicand
    ;

booleanPredicand
    : parenthesizedBooleanValueExpression
    | nonParenthesizedValueExpressionPrimary
    ;

parenthesizedBooleanValueExpression : LEFT_PAREN booleanValueExpression RIGHT_PAREN;

// ---------------------------------------------------------------------
// numeric value expression
numericValueExpression
    : term
    | numericValueExpression PLUS_SIGN term
    | numericValueExpression MINUS_SIGN term
    ;

term
    : factor
    | term ASTERISK factor
    | term SOLIDUS factor
    ;

factor
    : (PLUS_SIGN | MINUS_SIGN)? numericPrimary
    ;

numericPrimary
    : valueExpressionPrimary
    | numericValueFunction
    ;

// ---------------------------------------------------------------------
// numeric value function
numericValueFunction
    : lengthExpression
    | cardinalityExpression
    | absoluteValueExpression
    | modulusExpression
    | trigonometricFunction
    | generalLogarithmFunction
    | commonLogarithm
    | naturalLogarithm
    | exponentialFunction
    | powerFunction
    | squareRoot
    | floorFunction
    | ceilingFunction
    ;

lengthExpression
    : charLengthExpression
    | byteLengthExpression
    | pathLengthExpression
    ;

cardinalityExpression
    : CARDINALITY LEFT_PAREN cardinalityExpressionArgument RIGHT_PAREN
    | SIZE LEFT_PAREN listValueExpression RIGHT_PAREN
    ;

cardinalityExpressionArgument
    : bindingTableReferenceValueExpression
    | pathValueExpression
    | listValueExpression
    | recordExpression
    ;

charLengthExpression : (CHAR_LENGTH | CHARACTER_LENGTH) LEFT_PAREN characterStringValueExpression RIGHT_PAREN;

byteLengthExpression : (BYTE_LENGTH | OCTET_LENGTH) LEFT_PAREN byteStringValueExpression RIGHT_PAREN;

pathLengthExpression : PATH_LENGTH LEFT_PAREN pathValueExpression RIGHT_PAREN;

absoluteValueExpression : ABS LEFT_PAREN numericValueExpression RIGHT_PAREN;

modulusExpression : MOD LEFT_PAREN numericValueExpressionDividend COMMA numericValueExpressionDivisor RIGHT_PAREN;

numericValueExpressionDividend : numericValueExpression;

numericValueExpressionDivisor : numericValueExpression;

trigonometricFunction : trigonometricFunctionName LEFT_PAREN numericValueExpression RIGHT_PAREN;

trigonometricFunctionName
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

generalLogarithmFunction : LOG LEFT_PAREN generalLogarithmBase COMMA generalLogarithmArgument RIGHT_PAREN;

generalLogarithmBase : numericValueExpression;

generalLogarithmArgument : numericValueExpression;

commonLogarithm : LOG10 LEFT_PAREN numericValueExpression RIGHT_PAREN;

naturalLogarithm : LN LEFT_PAREN numericValueExpression RIGHT_PAREN;

exponentialFunction : EXP LEFT_PAREN numericValueExpression RIGHT_PAREN;

powerFunction : POWER LEFT_PAREN numericValueExpressionBase COMMA numericValueExpressionExponent RIGHT_PAREN;

numericValueExpressionBase : numericValueExpression;

numericValueExpressionExponent : numericValueExpression;

squareRoot : SQRT LEFT_PAREN numericValueExpression RIGHT_PAREN;

floorFunction : FLOOR LEFT_PAREN numericValueExpression RIGHT_PAREN;

ceilingFunction : (CEIL | CEILING) LEFT_PAREN numericValueExpression RIGHT_PAREN;

// ---------------------------------------------------------------------
// string value expression
stringValueExpression
    : characterStringValueExpression
    | byteStringValueExpression
    ;

characterStringValueExpression
    : characterStringConcatenation
    | characterStringPrimary
    ;

characterStringConcatenation : characterStringPrimary CONCATENATION_OPERATOR characterStringConcatenation;

characterStringPrimary
    : valueExpressionPrimary
    | characterStringFunction
    ;

byteStringValueExpression
    : byteStringConcatenation
    | byteStringPrimary
    ;

byteStringPrimary
    : valueExpressionPrimary
    | byteStringFunction
    ;

byteStringConcatenation : byteStringPrimary CONCATENATION_OPERATOR byteStringValueExpression;

// ---------------------------------------------------------------------
// character string function
characterStringFunction
    : substringFunction
    | fold
    | trimFunction
    | normalizeFunction
    ;

substringFunction
    : (LEFT | RIGHT) LEFT_PAREN characterStringValueExpression COMMA stringLength RIGHT_PAREN
    ;

fold
    : (UPPER | LOWER) LEFT_PAREN characterStringValueExpression RIGHT_PAREN
    ;

trimFunction
    : singleCharacterTrimFunction
    | multiCharacterTrimFunction
    ;

singleCharacterTrimFunction
    : TRIM LEFT_PAREN trimOperands RIGHT_PAREN
    ;

multiCharacterTrimFunction
    : (BTRIM | LTRIM | RTRIM) LEFT_PAREN trimSource (COMMA trimCharacterString)? RIGHT_PAREN
    ;

trimOperands
    : (trimSpecification? trimCharacterString? FROM)? trimSource
    ;

trimSource : characterStringValueExpression;

trimSpecification
    : LEADING
    | TRAILING
    | BOTH
    ;

trimCharacterString : characterStringValueExpression;

normalizeFunction
    : NORMALIZE LEFT_PAREN characterStringValueExpression (COMMA normalForm)? RIGHT_PAREN
    ;

normalForm
    : NFC
    | NFD
    | NFKC
    | NFKD
    ;

stringLength
    : numericValueExpression
    ;

// ---------------------------------------------------------------------
// byte string function
byteStringFunction
    : byteStringSubstringFunction
    | byteStringTrimFunction
    ;

byteStringSubstringFunction
    : (LEFT | RIGHT) LEFT_PAREN byteStringValueExpression COMMA stringLength RIGHT_PAREN
    ;

byteStringTrimFunction
    : TRIM LEFT_PAREN byteStringTrimOperands RIGHT_PAREN
    ;

byteStringTrimOperands
    : (trimSpecification? trimByteString? FROM)? byteStringTrimSource
    ;

byteStringTrimSource
    : byteStringValueExpression
    ;

trimByteString
    : byteStringValueExpression
    ;

// ---------------------------------------------------------------------
// datetime value expression
datetimeValueExpression
    : datetimePrimary
    | durationValueExpression PLUS_SIGN datetimePrimary
    | datetimeValueExpression PLUS_SIGN durationTerm
    | datetimeValueExpression MINUS_SIGN durationTerm
    ;

datetimePrimary
    : valueExpressionPrimary
    | datetimeValueFunction
    ;

// ---------------------------------------------------------------------
// datetime value function
datetimeValueFunction
    : dateFunction
    | timeFunction
    | datetimeFunction
    | localtimeFunction
    | localdatetimeFunction
    ;

dateFunction
    : CURRENT_DATE
    | DATE LEFT_PAREN dateFunctionParameters? RIGHT_PAREN
    ;

timeFunction
    : CURRENT_TIME
    | ZONED_TIME LEFT_PAREN timeFunctionParameters? RIGHT_PAREN
    ;

localtimeFunction : LOCAL_TIME (LEFT_PAREN timeFunctionParameters? RIGHT_PAREN)?;

datetimeFunction
    : CURRENT_TIMESTAMP
    | ZONED_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
    ;

localdatetimeFunction
    : LOCAL_TIMESTAMP
    | LOCAL_DATETIME LEFT_PAREN datetimeFunctionParameters? RIGHT_PAREN
    ;

dateFunctionParameters
    : dateString
    | recordConstructor
    ;

timeFunctionParameters
    : timeString
    | recordConstructor
    ;

datetimeFunctionParameters
    : datetimeString
    | recordConstructor
    ;

// ---------------------------------------------------------------------
// duration value expression
// changed from original to reduce left recursion
durationValueExpression
    : durationTerm
    | durationValueExpression PLUS_SIGN durationTerm
    | durationValueExpression MINUS_SIGN durationTerm
    | datetimeSubtraction
    ;

durationAdditionAndSubtraction
    : durationValueExpression PLUS_SIGN durationTerm
    | durationValueExpression MINUS_SIGN durationTerm
    ;

datetimeSubtraction
    : DURATION_BETWEEN LEFT_PAREN datetimeSubtractionParameters RIGHT_PAREN temporalDurationQualifier?
    ;

datetimeSubtractionParameters
    : datetimeValueExpression COMMA datetimeValueExpression
    ;

durationTerm
    : durationFactor
    | durationTerm ASTERISK factor
    | durationTerm SOLIDUS factor
    | term ASTERISK durationFactor
    ;

durationFactor : (PLUS_SIGN | MINUS_SIGN)? durationPrimary;

durationPrimary
    : valueExpressionPrimary
    | durationValueFunction
    ;

// ---------------------------------------------------------------------
// duration value function
durationValueFunction
    : durationFunction
    | durationAbsoluteValueFunction
    ;

durationFunction : DURATION LEFT_PAREN durationFunctionParameters RIGHT_PAREN;

durationFunctionParameters
    : durationString
    | recordConstructor
    ;

durationAbsoluteValueFunction : ABS LEFT_PAREN durationValueExpression RIGHT_PAREN;

// *********************************************************************
// name, variable
authorizationIdentifier : identifier;

objectName : identifier;

objectNameOrBindingVariable : REGULAR_IDENTIFIER;

directoryName : identifier;

schemaName : identifier;

graphName
    : REGULAR_IDENTIFIER
    | delimitedGraphName
    ;

delimitedGraphName : delimitedIdentifier;

graphTypeName : identifier;

nodeTypeName : identifier;

edgeTypeName : identifier;

bindingTableName
    : REGULAR_IDENTIFIER
    | delimitedBindingTableName
    ;

delimitedBindingTableName : delimitedIdentifier;

procedureName : identifier;

labelName : identifier;

propertyName : identifier;

fieldName : identifier;

parameterName : separatedIdentifier;

graphPatternVariable
    : elementVariable
    | pathOrSubpathVariable
    ;

pathOrSubpathVariable
    : pathVariable
    | subpathVariable
    ;

elementVariable : bindingVariable;

pathVariable : bindingVariable;

subpathVariable : REGULAR_IDENTIFIER;

bindingVariable : REGULAR_IDENTIFIER;

// *********************************************************************
// literal
literal
    : signedNumericLiteral
    | generalLiteral
    ;

unsignedLiteral
    : unsignedNumericLiteral
    | generalLiteral
    ;

generalLiteral
    : booleanLiteral
    | characterStringLiteral
    | BYTE_STRING_LITERAL
    | temporalLiteral
    | durationLiteral
    | nullLiteral
    | listLiteral
    | recordLiteral
    ;

// ---------------------------------------------------------------------
// boolean literal
booleanLiteral
    : TRUE
    | FALSE
    | UNKNOWN
    ;

// ---------------------------------------------------------------------
// character string literal
characterStringLiteral
    : singleQuotedCharacterSequence
    | doubleQuotedCharacterSequence
    ;

singleQuotedCharacterSequence
    : SINGLE_QUOTED_CHARACTER_SEQUENCE
    | NO_ESCAPE_SINGLE_QUOTED_CHARACTER_SEQUENCE
    ;

doubleQuotedCharacterSequence
    : DOUBLE_QUOTED_CHARACTER_SEQUENCE
    | NO_ESCAPE_DOUBLE_QUOTED_CHARACTER_SEQUENCE
    ;

accentQuotedCharacterSequence
    : ACCENT_QUOTED_CHARACTER_SEQUENCE
    | NO_ESCAPE_ACCENT_QUOTED_CHARACTER_SEQUENCE
    ;

// ---------------------------------------------------------------------
// numeric literal
signedNumericLiteral
    : (PLUS_SIGN | MINUS_SIGN)? unsignedNumericLiteral
    ;

unsignedNumericLiteral
    : exactNumericLiteral
    | approximateNumericLiteral
    ;

exactNumericLiteral
    : EXACT_NUMERIC_LITERAL
    | UNSIGNED_DECIMAL_IN_COMMON_NOTATION
    | unsignedInteger
    ;

approximateNumericLiteral
    : APPROXIMATE_NUMERIC_LITERAL
    | UNSIGNED_DECIMAL_IN_SCIENTIFIC_NOTATION
    ;

unsignedInteger
    : UNSIGNED_DECIMAL_INTEGER
    | UNSIGNED_HEXADECIMAL_INTEGER
    | UNSIGNED_OCTAL_INTEGER
    | UNSIGNED_BINARY_INTEGER
    ;

// ---------------------------------------------------------------------
// temporal literal
// todo: support SQL_DATETIME_LITERAL and SQL_INTERVAL_LITERAL
temporalLiteral
    : dateLiteral
    | timeLiteral
    | datetimeLiteral
//  | SQL_DATETIME_LITERAL
    ;

dateLiteral : DATE dateString;

timeLiteral : TIME timeString;

datetimeLiteral : (DATETIME | TIMESTAMP) datetimeString;

dateString : characterStringLiteral;

timeString : characterStringLiteral;

datetimeString : characterStringLiteral;

timeZoneString : characterStringLiteral;

durationLiteral
    : DURATION durationString
//  | SQL_INTERVAL_LITERAL
    ;

durationString : characterStringLiteral;

// ---------------------------------------------------------------------
// null literal
nullLiteral
    : NULL
    ;

// ---------------------------------------------------------------------
// list literal
listLiteral : listValueConstructorByEnumeration;

// ---------------------------------------------------------------------
// record literal
recordLiteral : recordConstructor;

// *********************************************************************
// token
token
    : nonDelimiterToken
    | delimiterToken
    ;

nonDelimiterToken
    : REGULAR_IDENTIFIER
    | substitutedParameterReference
    | generalParameterReference
    | keyword
    | unsignedNumericLiteral
    | BYTE_STRING_LITERAL
    | MULTISET_ALTERNATION_OPERATOR
    ;

// ---------------------------------------------------------------------
// identifier
identifier
    : REGULAR_IDENTIFIER
    | delimitedIdentifier
    | nonReservedWord // non-reserved word can be used as an identifier
    ;

// note: this is not the same with the BNF,
// because EXTENDED_IDENTIFIER can't recognize the REGULAR_IDENTIFIER
separatedIdentifier
    : nonDelimitedIdentifier
    | delimitedIdentifier
    ;

nonDelimitedIdentifier
    : REGULAR_IDENTIFIER
    | EXTENDED_IDENTIFIER
    | nonReservedWord // non-reserved word can be used as an identifier
    ;

delimitedIdentifier
    : doubleQuotedCharacterSequence
    | accentQuotedCharacterSequence
    ;

// ---------------------------------------------------------------------
// parameter reference
substitutedParameterReference : DOUBLE_DOLLAR_SIGN parameterName;

generalParameterReference : DOLLAR_SIGN parameterName;

// ---------------------------------------------------------------------
// keyword
keyword
    : reservedWord
    | nonReservedWord
    ;

nonReservedWord
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

reservedWord
    : preReservedWord
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

preReservedWord
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
delimiterToken
    : gqlSpecialCharacter
    | BRACKET_RIGHT_ARROW
    | BRACKET_TILDE_RIGHT_ARROW
    | characterStringLiteral
    | CONCATENATION_OPERATOR
    | dateString
    | datetimeString
    | delimitedIdentifier
    | DOUBLE_COLON
    | DOUBLE_PERIOD
    | durationString
    | greaterThanOperator
    | GREATER_THAN_OR_EQUALS_OPERATOR
    | LEFT_ARROW
    | LEFT_ARROW_BRACKET
    | LEFT_ARROW_TILDE
    | LEFT_ARROW_TILDE_BRACKET
    | LEFT_MINUS_RIGHT
    | LEFT_MINUS_SLASH
    | LEFT_TILDE_SLASH
    | lessThanOperator
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
    | timeString
    ;

greaterThanOperator : RIGHT_ANGLE_BRACKET;

lessThanOperator : LEFT_ANGLE_BRACKET;

// ---------------------------------------------------------------------
// synonym
edgeSynonym
    : EDGE
    | RELATIONSHIP
    ;

edgesSynonym
    : EDGES
    | RELATIONSHIPS
    ;

nodeSynonym
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
gqlSpecialCharacter
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