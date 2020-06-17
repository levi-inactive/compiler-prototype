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
%START LINE_COMMENT BLOCK_COMMENT STRING

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
  * Whitespace.
  */
[ \t]   {};
\n      { yylineno = yylineno + 1; }



 /*
  * Comments.
  */

 /* Begin line comment. */
\/\/ {
    printf("LINE_COMMENT ");
    BEGIN LINE_COMMENT;
}

 /* If a LINE_COMMENT has begun and contains a line jump,
    end the LINE_COMMENT and incremment current line number. */
<LINE_COMMENT>\n    {
    BEGIN 0;
    curr_lineno++;
    printf("\n");
}

 /* Match any character but newline \n.
    No need to take action. */
<LINE_COMMENT>.     {}

 /* Begin block comment. */
"\/\*" {
    printf("BLOCK_COMMENT ");
    BEGIN BLOCK_COMMENT;
}

 /* If a BLOCK_COMMENT has begun and contains a line jump,
    incremment current line number. */
<BLOCK_COMMENT>\n       { curr_lineno++; }

 /* If a BLOCK_COMMENT has begun and contains a closing block
   comment element, end the BLOCK_COMMENT. */
<BLOCK_COMMENT>"\*\/"    { BEGIN 0; }

 /* Handle BLOCK_COMMENT containing EOF. */
<BLOCK_COMMENT><<EOF>> {
    /* strcpy(cool_yylval.error_msg, "EOF in comment"); */
    printf("\nERROR: EOF in comment.\n");
	BEGIN 0;
    return (ERROR);
}

 /* Match any character but newline.
    No need to take action. */
<BLOCK_COMMENT>.    {}

 /* Handle unmatched block comment ending. */
"\*)"   {
    strcpy(cool_yylval.error_msg, "Unmatched *)");
    return (ERROR);
}



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
        printf("\nERROR: string contains null character.\n");
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
    printf("\nERROR: EOF in string constant.\n");
    BEGIN 0;
    return (ERROR);
}

 /* If a string has begun and contains an scape
    character, handle it. Scape character can be
    anything but end of line. */
<STRING>\\. {
    if (str_length >= MAX_STR_CONST) {
        /* strcpy(yylval.error_msg, "String constant too long."); */
        printf("\nERROR: String constant too long.\n");
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
    printf("\nERROR: Unterminated string constant.\n");
    BEGIN 0;
    return (ERROR);
}

 /* A string can contain anything but end of line. */
<STRING>.   {
    if (str_length >= MAX_STR_CONST) {
        /* strcpy(yylval.error_msg, "String constant too long."); */
        printf("\nERROR: String constant too long.\n");
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
    printf("\nERROR: Unknown error caused by : %s.\n", yytext[0]);
    return (ERROR);
}

%%