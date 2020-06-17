%{

#include <stdio.h>
#include <stdlib.h

extern FILE *fp;

%}



%token OPEN_CURLY_BRACKET
%token CLOSE_CURLY_BRACKET
%token OPEN_SQUARE_BRACKET
%token CLOSE_SQUARE_BRACKET
%token OPEN_BRACKET
%token CLOSE_BRACKET
%token COMMA
%token SEMICOLON
%token PLUS
%token MINUS
%token MULTIPLICATION
%token DIVISION
%token MODULUS
%token DOT
%token LESS
%token GREATER
%token NOT
%token ASSIGN
%token INCREMENT
%token DECREMENT
%token LESS_OR_EQUAL
%token GREATER_OR_EQUAL
%token EQUAL
%token NOT_EQUAL
%token CLASS
%token ELSE
%token IF
%token INT
%token FLOAT
%token CHAR
%token VOID
%token DOUBLE
%token FOR
%token WHILE
%token MAIN
%token STR_CONST
%token INT_CONST
%token CLASSID
%token OBJECTID
%token ERROR
%token OR
%token AND

%left MULTIPLICATION
%left DIVISION
%left PLUS
%left MINUS
%left MODULUS
%left NOT
%left LESS
%left GREATER
%left OR
%left AND
%left LESS_OR_EQUAL
%left GREATER_OR_EQUAL
%left EQUAL
%left NOT_EQUAL

%right INCREMENT
%right DECREMENT

%right ASSIGN;



%%

start:  
    |   function
    |   declaration
    ;

declaration:
    |   type assignment SEMICOLON
    |   assignment SEMICOLON
    |   function_call SEMICOLON
    |   array_usage SEMICOLON
    |   type array_usage SEMICOLON
    |   error
    ;

assignment:
    |   OBJECTID ASSIGN assignment
    |   OBJECTID ASSIGN function_call
    |   OBJECTID ASSIGN array_usage
    |   array_usage ASSIGN assignment
    |   OBJECTID COMMA assignment
    |   INT_CONST assignment
    |   OBJECTID PLUS assignment
    |   OBJECTID MINUS assignment
    |   OBJECTID MULTIPLICATION assignment
    |   OBJECTID DIVISION assignment
    |   INT_CONST PLUS assignment
    |   INT_CONST MINUS assignment
    |   INT_CONST MULTIPLICATION assignment
    |   INT_CONST DIVISION assignment
    |   '\'' assignment '\''
    |   OPEN_BRACKET assignment CLOSE_BRACKET
    |   MINUS OPEN_BRACKET assignment CLOSE_BRACKET
    |   MINUS INT_CONST
    |   MINUS OBJECTID
    |   INT_CONST
    |   OBJECTID
    ;

function_call:  
    |   OBJECTID OPEN_BRACKET CLOSE_BRACKET
    |   OBJECTID OPEN_BRACKET assignment CLOSE_BRACKET
    ;

array_usage:
    |   OBJECTID OPEN_SQUARE_BRACKET assignment CLOSE_SQUARE_BRACKET
    ;

function:
    |   type OBJECTID OPEN_BRACKET argument_list CLOSE_BRACKET compound_statement
    ;

argument_list:
    |   argument_list
    |   argument_list COMMA argument
    |   argument
    ;

argument:
    |   type OBJECTID
    ;

type:   
    |   INT
    |   FLOAT
    |   CHAR
    |   VOID
    ;

compound_statement:
    |   OPEN_CURLY_BRACKET statement_list  CLOSE_CURLY_BRACKET
    ;

statement_list:
    |   statement_list statement
    ;

statement:
    |   while_statement
    |   if_statement
    |   declaration
    |   SEMICOLON
    ;

while_statement:    
    |   WHILE OPEN_BRACKET expression CLOSE_BRACKET statement
    |   WHILE OPEN_BRACKET expression CLOSE_BRACKET compound_statement
    ;

if_statement:
    |   IF OPEN_BRACKET expression CLOSE_BRACKET statement
    |   IF OPEN_BRACKET expression CLOSE_BRACKET compound_statement
    ;

increment_or_decrement: 
    |   OBJECTID INCREMENT
    |   OBJECTID DECREMENT
    ;

expression:
    |   expression LESS_OR_EQUAL expression
    |   expression GREATER_OR_EQUAL expression
    |   expression NOT_EQUAL expression
    |   expression EQUAL expression
    |   expression GREATER expression
    |   expression LESS expression
    |   increment_or_decrement
    |   array_usage
    ;

%%

#include "lex.yy.c"
#include <ctype.h>

int main(int argc, char *argv[])
{
    yyin = fopen(argv[1], "r");
	
    if (!yyparse()) {
		printf("\nCOMPLETADOO\n");
    } else {
		printf("\nFAILED\n");
    }
	
	fclose(yyin);
    return 0;
}
         
yyerror(char *s) {
	printf("%d : %s %s\n", yylineno, s, yytext );
}         