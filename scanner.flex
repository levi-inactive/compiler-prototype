%{

#include scanner.h

/* Max size of string constants. */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT /* keep g++ happy. */

/* to assemble string constants. */
char string_const[MAX_STR_CONST]; 

extern int curr_lineno;

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
"{"         { return (OPEN_CURLY_BRACKET); }
"}"			{ return (CLOSE_CURLY_BRACKET); }
"("			{ return (OPEN_BRACKET); }
")"			{ return (CLOSE_BRACKET); }
","			{ return ','; }
";"			{ return ';'; }
"+"			{ return '+'; }
"-"			{ return '-'; }
"*"			{ return '*'; }
"/"			{ return '/'; }
"%"			{ return '%'; }
"."			{ return '.'; }
"<"			{ return '<'; }
">"         { return '>'; }
"!"         { return '!'; }



 /*
  * Multiple-character operators.
  */
{INC}     { return (INCREMENT); }
{DEC}     { return (DECREMENT); }
{LE}      { return (LESS_OR_EQUAL); }
{GE}      { return (GREATER_OR_EQUAL); }
{EQ}      { return (EQUAL); }
{NE}      { return (NOT_EQUAL); }
{OR}      { return (OR); }
{AND}     { return (AND); }



 /*
  * Keywords.
  */
class   { return (CLASS); }
else    { return (ELSE); }
if      { return (IF); }
int	    { return (INT); }
float   { return (FLOAT); }
char    { return (CHAR); }
void    { return (VOID); }
for 	{ return (FOR); }
while	{ return (WHILE); }
printf  { return (PRINTF); }
main    { return (MAIN); }

 /*
  * String constants (C syntax)
  * Escapce sequence \c is accepted for all characters c. Except for
  * \n \t \b \f, the result is c.
  */
 
 /* Stop reading string constant. */
<STRING>\" {
    if (str_length > 1 && str_contains_null_char) {
        strcpy(yyval.error_msg, "String contains null character.");
        BEGIN 0;
        return (ERROR);  
    }

    yyval.symbol = string_const;
    BEGIN 0;
    return (STR_CONST);
}

 /* Start string constant. */
\" {
    memset(string_const, 0, sizeof string_const);
    str_length = 0;
    str_contains_null_char = flase;
    BEGIN STRING;
}

 /* Handle string containing EOF. */
<STRING><<EOF>> {
    strcpy(yyval.error_msg, "EOF in string constant.");
    BEGIN 0;
    return (ERROR);
}

 /* If a string has begun and contains an scape
    character, handle it. Scape character can be
    anything but end of line. */
<STRING>\\. {
    if (str_length >= MAX_STR_CONST) {
        strcpy(yyval.error_msg, "String constant too long.");
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
<STRING>\\\n    { curr_lineno++; }

 /* Handle a string containing new line. */
<STRING>\n  {
    curr_lineno++;
    strcpy(yyval.error_msg, "Unterminated string constant.");
    BEGIN 0;
    return (ERROR);
}

 /* A string can contain anything but end of line. */
<STRING>.   {
    if (str_length >= MAX_STR_CONST) {
        strcpy(yyval.error_msg, "String constant too long.");
        BEGIN 0;
        return (ERROR);
    }

    string_const[str_length++] = yytext[0];
}



 /*
  * Integers and identifiers.
  */
{DIGIT}+    {
    yyval.symbol = yytext;
    return (INT_CONST);
}

[A-Z][a-zA-Z0-9_]*  {
    yyval.symbol = yytext;
    return (TYPEID);
}

[a-z][a-zA-Z0-9_]*  {
    yyval.symbol = yytext;
    return (OBJECTID);
}



 /*
  * Other errors.
  */
. {
    strcpy(yyval.error_msg, yytext);
    return (ERROR);
}

%%