%{
#include <stdbool.h>

/* Max size of string constants. */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT /* keep g++ happy. */

/* to assemble string constants. */
char string_const[MAX_STR_CONST]; 

extern int yylineno;

int str_length;
bool str_contains_null_char;

%}
 
 /* Declare start conditions. */
%START STRING

 /* Define names for regular expressions here. */
ALPHA   [a-zA-Z]
DIGIT   [0-9]
INC     "++"
DEC     "--"
LE      "<="
GE      ">="
EQ      "=="
NE      "!="
OR      "||"
AND     "&&"



%%
 /*
  * Single-character operators.
  */
"{" {
    printf("OPEN_CURLY_BRACKET "); 
    return (OPEN_CURLY_BRACKET); 
}
"}"	{
    printf("CLOSE_CURLY_BRACKET "); 
    return (CLOSE_CURLY_BRACKET); 
}
"[" {
    printf("OPEN_SQUARE_BRACKET "); 
    return (OPEN_SQUARE_BRACKET); 
}
"]" {
    printf("CLOSE_SQUARE_BRACKET "); 
    return (CLOSE_SQUARE_BRACKET); 
}
"("	{
    printf("OPEN_BRACKET "); 
    return (OPEN_BRACKET); 
}
")"	{
    printf("CLOSE_BRACKET "); 
    return (CLOSE_BRACKET); 
}
","	{
    printf("COMMA "); 
    return (COMMA); 
}
";"	{
    printf("SEMICOLON\n"); 
    return (SEMICOLON); 
}
"+"	{
    printf("PLUS "); 
    return (PLUS); 
}
"-"	{
    printf("MINUS "); 
    return (MINUS); 
}
"*"	{
    printf("MULTIPLICATION "); 
    return (MULTIPLICATION); 
}
"/"	{
    printf("DIVISION "); 
    return (DIVISION); 
}
"%"	{
    printf("MODULUS "); 
    return (MODULUS); 
}
"."	{
    printf("DOT "); 
    return (DOT); 
}
"<"	{
    printf("LESS "); 
    return (LESS); 
}
">" {
    printf("GREATER "); 
    return (GREATER); 
}
"!" {
    printf("NOT "); 
    return (NOT); 
}
"=" {
    printf("ASSIGN "); 
    return (ASSIGN); 
}



 /*
  * Multiple-character operators.
  */
{INC} {
    printf("INCREMENT ");
    return (INCREMENT); 
}
{DEC} {
    printf("DECREMENT ");
    return (DECREMENT); 
}
{LE} {
    printf("LESS_OR_EQUAL ");
    return (LESS_OR_EQUAL); 
}
{GE} {
    printf("GREATER_OR_EQUAL ");
    return (GREATER_OR_EQUAL); 
}
{EQ} {
    printf("EQUAL ");
    return (EQUAL); 
}
{NE} {
    printf("NOT_EQUAL ");
    return (NOT_EQUAL); 
}
{OR} {
    printf("OR ");
    return (OR); 
}
{AND} {
    printf("AND ");
    return (AND); 
}



 /*
  * Keywords.
  */
class {
    printf("CLASS ");
    return (CLASS); 
}
else {
    printf("ELSE ");
    return (ELSE); 
}
if {
    printf("IF ");
    return (IF); 
}
int {
    printf("INT ");
    return (INT); 
}
float {
    printf("FLOAT ");
    return (FLOAT); 
}
char {
    printf("CHAR ");
    return (CHAR); 
}
void {
    printf("VOID ");
    return (VOID); 
}
while {
    printf("WHILE ");
    return (WHILE); 
}
main {
    printf("MAIN ");
    return (MAIN); 
}

 /*
  * String constants (C syntax)
  * Escapce sequence \c is accepted for all characters c. Except for
  * \n \t \b \f, the result is c.
  */
 
 /* Stop reading string constant. */
<STRING>\" {
    if (str_length > 1 && str_contains_null_char) {
        printf("ERROR: string contains null character.");
        BEGIN 0;
        return (ERROR);  
    }

    /* yylval.symbol = string_const; */
    BEGIN 0;
    printf("STR_CONST ");
    return (STR_CONST);
}

 /* Start string constant. */
\" {
    memset(string_const, 0, sizeof string_const);
    str_length = 0;
    str_contains_null_char = false;
    BEGIN STRING;
}

 /* Handle string containing EOF. */
<STRING><<EOF>> {
    /* strcpy(yylval.error_msg, "EOF in string constant."); */
    printf("ERROR: EOF in string constant.");
    BEGIN 0;
    return (ERROR);
}

 /* If a string has begun and contains an scape
    character, handle it. Scape character can be
    anything but end of line. */
<STRING>\\. {
    if (str_length >= MAX_STR_CONST) {
        /* strcpy(yylval.error_msg, "String constant too long."); */
        printf("ERROR: String constant too long.");
        BEGIN 0;
        return (ERROR);
    }

    switch(yytext[1]) {
        case '\"':
            string_const[str_length++] = '\"';
            break;
        case '\\':
            string_const[str_length++] = '\\';
            break;
        case 'b':
            string_const[str_length++] = '\b';
            break;
        case 'f':
            string_const[str_length++] = '\f';
            break;
        case 'n':
            string_const[str_length++] = '\n';
            break;
        case 't':
            string_const[str_length++] = '\t';
            break;
        case '0':
            string_const[str_length++] = 0;
            str_contains_null_char = true;
            break;
        default:
            string_const[str_length++] = yytext[1];
    }
}

 /* Multiline string constant. */
<STRING>\\\n    { yylineno++; }

 /* Handle a string containing new line. */
<STRING>\n  {
    yylineno++;
    /* strcpy(yylval.error_msg, "Unterminated string constant."); */
    printf("ERROR: Unterminated string constant.");
    BEGIN 0;
    return (ERROR);
}

 /* A string can contain anything but end of line. */
<STRING>.   {
    if (str_length >= MAX_STR_CONST) {
        /* strcpy(yylval.error_msg, "String constant too long."); */
        printf("ERROR: String constant too long.");
        BEGIN 0;
        return (ERROR);
    }

    string_const[str_length++] = yytext[0];
}



 /*
  * Integers and identifiers.
  */
{DIGIT}+    {
    /* yylval.symbol = yytext; */
    printf("INT_CONST ");
    return (INT_CONST);
}

[A-Z][a-zA-Z0-9_]*  {
    /* yylval.symbol = yytext; */
    printf("CLASSID ");
    return (CLASSID);
}

[a-z][a-zA-Z0-9_]*  {
    /* yylval.symbol = yytext; */
    printf("OBJECTID ");
    return (OBJECTID);
}



 /*
  * Other errors.
  */
. {
    /* strcpy(yylval.error_msg, yytext); */
    printf("ERROR: Unkown error.");
    return (ERROR);
}

%%