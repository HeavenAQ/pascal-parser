%{
#include<stdio.h>
#include"y.tab.h"
unsigned char_count = 0, line_count = 1, token_count = 0, cur_char = 1;
unsigned preceeding_num = 0;
int is_new_line = 1;
int space_count = 0;
int start_printing_space = 0;

void check_reserved_word();
void check_symbol();
void check_ID();
void check_invalid_ID();
void check_string();
void check_invalid_string();
void check_multi_comment_start();
void check_multi_comment();
void check_multi_comment_end();
void check_invalid_multi_comment();
int check_integer();
void check_invalid_integer();
int check_real_number();
void check_invalid_real_number();
void handle_new_line();
void check_line_header();
void check_data_type();
void check_print_header();
int check_positive_negative();
void check_boolean();
void check_digit();

%}
STRING \'([^\'\r\n]|\'\')*\'
SPACE [ \t]
EOL [\r][\n]|[\n]

AND         [Aa][Nn][Dd]
ARRAY       [Aa][Rr][Rr][Aa][Yy]
BEGIN       [Bb][Ee][Gg][Ii][Nn]
CASE        [Cc][Aa][Ss][Ee]
CONST       [Cc][Oo][Nn][Ss][Tt]
DIV         [Dd][Ii][Vv]
DO          [Dd][Oo]
DOWNTO      [Dd][Oo][Ww][Nn][Tt][Oo]
ELSE        [Ee][Ll][Ss][Ee]
END         [Ee][Nn][Dd]
FILE        [Ff][Ii][Ll][Ee]
FOR         [Ff][Oo][Rr]
FUNCTION    [Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]
GOTO        [Gg][Oo][Tt][Oo]
IF          [Ii][Ff]
IN          [Ii][Nn]
LABEL       [Ll][Aa][Bb][Ee][Ll]
MOD         [Mm][Oo][Dd]
NIL         [Nn][Ii][Ll]
NOT         [Nn][Oo][Tt]
OF          [Oo][Ff]
OR          [Oo][Rr]
PACKED      [Pp][Aa][Cc][Kk][Ee][Dd]
PROCEDURE   [Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]
PROGRAM     [Pp][Rr][Oo][Gg][Rr][Aa][Mm]
RECORD      [Rr][Ee][Cc][Oo][Rr][Dd]
REPEAT      [Rr][Ee][Pp][Ee][Aa][Tt]
SET         [Ss][Ee][Tt]
THEN        [Tt][Hh][Ee][Nn]
TO          [Tt][Oo]
TYPE        [Tt][Yy][Pp][Ee]
UNTIL       [Uu][Nn][Tt][Ii][Ll]
VAR         [Vv][Aa][Rr]
WHILE       [Ww][Hh][Ii][Ll][Ee]
WITH        [Ww][Ii][Tt][Hh]
ABSOLUTE    [Aa][Bb][Ss][Oo][Ll][Uu][Tt][Ee]
CONTINUE    [Cc][Oo][Nn][Tt][Ii][Nn][Uu][Ee]
OBJECT      [Oo][Bb][Jj][Ee][Cc][Tt]
WRITE       [Ww][Rr][Ii][Tt][Ee]
WRITELN     [Ww][Rr][Ii][Tt][Ee][Ll][Nn]
BOOLEAN  [Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]

SEMICOLON [;]
COLON :
DOT [\.]
COMMA [,]
DOTDOT [\.][\.]
LPAREN [(]
RPAREN [)]
LBRACKET [\[]
RBRACKET [\]]
LBRACE [\{]
RBRACE [\}]
PLUS     [\+]
MINUS    [\-]
MULTIPLY [\*]
DIVIDE   [/]
ASSIGN  :=
LESS_THAN_EQUAL  <=
GREATER_THAN_EQUAL >=
EQUAL =
NOT_EQUAL <>
GREATER_THAN >
LESS_THAN <

%x MULTI_COMMENT
BEGIN_MULTI_COMMENT "(*"
END_MULTI_COMMENT "*)"

CHAR_TYPE [Cc][Hh][Aa][Rr] 
INTEGER_TYPE  [Ii][Nn][Tt][Ee][Gg][Ee][Rr]
REAL_TYPE [Rr][Ee][Aa][Ll]
BOOLEAN_TYPE [Bb][Oo][Oo][Ll][Ee][Aa][Nn]
STRING_TYPE [Ss][Tt][Rr][Ii][Nn][Gg]
DATA_TYPE {CHAR_TYPE}|{INTEGER_TYPE}|{REAL_TYPE}|{BOOLEAN_TYPE}|{STRING_TYPE}

IDENTIFIER ([A-Za-z_][A-Za-z_0-9]+|[A-Za-z]) 
DIGIT ([0-9]+|[1-9][0-9]+)
INTEGER	[\+\-]?{DIGIT}
INVALID_INTEGER [\+\-]*[0-9]+
REAL_NUM ({INTEGER}|({INTEGER}\.([0-9]+|[0])))([eE]{INTEGER}+)?	
INVALID_REAL_NUM	[\+\-]?((([0-9]+)|([0-9]*\.[0-9]*))([eE][\-\+]?(([0-9]+)|([0-9]*\.[0-9]*)))?)

%%
{BEGIN_MULTI_COMMENT} { BEGIN(MULTI_COMMENT); check_multi_comment_start(); }
<MULTI_COMMENT>{END_MULTI_COMMENT} { BEGIN(INITIAL); check_multi_comment_end(); }
<MULTI_COMMENT>[^*]+|"*" { check_multi_comment(); }
<MULTI_COMMENT>{END_MULTI_COMMENT}[^ \r\n]+ { BEGIN(INITIAL); check_invalid_multi_comment(); }


{AND}         { check_reserved_word(); return AND;}
{ARRAY}       { check_reserved_word(); return ARRAY;}
{BEGIN}       { check_reserved_word(); return myBEGIN;}
{CASE}        { check_reserved_word(); return CASE;}
{CONST}       { check_reserved_word(); return CONST;}
{DIV}         { check_reserved_word(); return DIV;}
{DO}          { check_reserved_word(); return DO;}
{DOWNTO}      { check_reserved_word(); return DOWNTO;}
{ELSE}        { check_reserved_word(); return ELSE;}
{END}         { check_reserved_word(); return END;}
{FILE}        { check_reserved_word(); return myFILE;}
{FOR}         { check_reserved_word(); return FOR;}
{FUNCTION}    { check_reserved_word(); return FUNCTION;}
{GOTO}        { check_reserved_word(); return GOTO;}
{IF}          { check_reserved_word(); return IF;}
{IN}          { check_reserved_word(); return IN;}
{LABEL}       { check_reserved_word(); return LABEL;}
{MOD}         { check_reserved_word(); return MOD;}
{NIL}         { check_reserved_word(); return NIL;}
{NOT}         { check_reserved_word(); return NOT;}
{OF}          { check_reserved_word(); return OF;}
{OR}          { check_reserved_word(); return OR;}
{PACKED}      { check_reserved_word(); return PACKED;}
{PROCEDURE}   { check_reserved_word(); return PROCEDURE;}
{PROGRAM}     { check_reserved_word(); return PROGRAM;}
{RECORD}      { check_reserved_word(); return RECORD;}
{REPEAT}      { check_reserved_word(); return REPEAT;}
{SET}         { check_reserved_word(); return SET;}
{THEN}        { check_reserved_word(); return THEN;}
{TO}          { check_reserved_word(); return TO;}
{TYPE}        { check_reserved_word(); return TYPE;}
{UNTIL}       { check_reserved_word(); return UNTIL;}
{VAR}         { check_reserved_word(); return VAR;}
{WHILE}       { check_reserved_word(); return WHILE;}
{WITH}        { check_reserved_word(); return WITH;}
{ABSOLUTE}    { check_reserved_word(); return ABSOLUTE;}
{CONTINUE}    { check_reserved_word(); return CONTINUE;}
{OBJECT}      { check_reserved_word(); return OBJECT;}
{WRITE}       { check_reserved_word(); return WRITE;}
{WRITELN}     { check_reserved_word(); return WRITELN;}

{SEMICOLON} { check_symbol(); return SEMICOLON;}
{COLON} { check_symbol(); return COLON;}
{COMMA} { check_symbol(); return COMMA;}
{LBRACKET} { check_symbol(); return LBRACKET;}
{RBRACKET} { check_symbol(); return RBRACKET;}
{DOTDOT} { check_symbol(); return DOTDOT;}
{LPAREN} { check_symbol(); return LPAREN;}
{RPAREN} { check_symbol(); return RPAREN;}
{DOT} { check_symbol(); return DOT;}
{ASSIGN} { check_symbol(); return ASSIGN;}
{PLUS} { check_symbol(); return PLUS;}
{MINUS} { check_symbol(); return MINUS;}
{MULTIPLY} { check_symbol(); return MULTIPLY;}
{DIVIDE} { check_symbol(); return DIVIDE;}
{LESS_THAN_EQUAL} { check_symbol(); return LESS_THAN_EQUAL;}
{GREATER_THAN_EQUAL} { check_symbol(); return GREATER_THAN_EQUAL;}
{NOT_EQUAL} { check_symbol(); return NOT_EQUAL;}
{GREATER_THAN} { check_symbol(); return GREATER_THAN;}
{LESS_THAN} { check_symbol(); return LESS_THAN;}
{EQUAL} { check_symbol(); return EQUAL;}


{DATA_TYPE} { check_data_type(); return DATA_TYPE;}

{DIGIT} { check_digit(); return DIGIT;}
{INTEGER} { return check_integer(); }
{INVALID_INTEGER} { check_invalid_integer(); }
{REAL_NUM} { return check_real_number(); }
{BOOLEAN} { check_boolean(); return BOOLEAN;}

{STRING} { check_string(); return STRING;}

{IDENTIFIER} { check_ID(); return(IDENTIFIER); }

{SPACE} { 
    space_count++; 
    cur_char++; 
    if(start_printing_space == 1) {
        printf("%s", yytext); 
    }
}
{EOL}  { handle_new_line(); }
%%

void check_reserved_word()
{
    check_print_header();
    printf("%s", yytext);
	char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

void check_data_type()
{
    check_print_header();
    printf("%s", yytext);
    if(yytext[0] == 's' || yytext[0] == 'S') {
        yylval.dtype = 0;
    } else if(yytext[0] == 'c' || yytext[0] == 'C') {
        yylval.dtype = 1;
    } else if(yytext[0] == 'i' || yytext[0] == 'I') {
        yylval.dtype = 2;
    } else if(yytext[0] == 'r' || yytext[0] == 'R') {
        yylval.dtype = 3;
    } else if(yytext[0] == 'b' || yytext[0] == 'B') {
        yylval.dtype = 4;
    }
	char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

void check_symbol()
{
    check_print_header();
    printf("%s", yytext);
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

void check_ID() {
    if (strlen(yytext) > 15) {
        return check_invalid_ID();
    }
    check_print_header();
    printf("%s", yytext);
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;

    // store id as char *
    yylval.strval = (char *)malloc(strlen(yytext) + 1);
    sscanf(yytext, "%s", yylval.strval);
}

void check_invalid_ID() {
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

void check_string() {
    check_print_header();
    if (strlen(yytext) > 30) {
        return check_invalid_string();
    }

    // handle single quote
    printf("%s", yytext);
    char_count += yyleng;
	for(int i = 1; i < yyleng; i++) {
		if(i < yyleng - 1 && yytext[i] == '\'' && yytext[i + 1] == '\'')
		{
            for(int j = i; j < yyleng-1; j++)
                yytext[j] = yytext[j + 1];
            yytext[yyleng-1]= '\0';
        }
    }

    // store string as char *
    yylval.strval = (char *)malloc(strlen(yytext) + 1);
    sscanf(yytext, "%s", yylval.strval);

    // increment token count
    token_count++;
    cur_char += yyleng;
}

void check_invalid_string() {
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

void check_multi_comment_start() {
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

void check_invalid_multi_comment() {
    char_count += yyleng;
    cur_char += yyleng;
}

void check_multi_comment_end() {
    char_count += yyleng;
    cur_char += yyleng;
}

void check_multi_comment() {
    char_count += yyleng;
    for (int i = 0; i < yyleng; i++) {
        if (yytext[i] == '\n') {
            line_count++;
            cur_char = 1;
          }
      }
    cur_char += yyleng;
}

int check_integer() {
    check_print_header();
    if (preceeding_num == 1) {
        return check_positive_negative();
    } 
    printf("%s", yytext);
    char_count += yyleng;
    preceeding_num = 1;
    token_count++;
    cur_char += yyleng - 1;

    // store integer as string
    yylval.strval = (char *)malloc(strlen(yytext) + 1);
    sscanf(yytext, "%s", yylval.strval);
    return INTEGER;
}

void check_invalid_integer() {
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

int check_real_number() {
    check_print_header();
    char_count += yyleng;
    if (preceeding_num == 1) {
        return check_positive_negative();
    }
    preceeding_num = 1;
    token_count++;
    cur_char += yyleng - 1;

    // store real number as string
    yylval.strval = (char *)malloc(strlen(yytext) + 1);
    sscanf(yytext, "%s", yylval.strval);
    return REAL_NUM;
}

void check_invalid_real_number() {
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;
}

int check_positive_negative() {
    check_print_header();
    token_count++;
    cur_char++;

    // put back the characters from the 2nd characters to the last character
    for(int i = 1; i < yyleng; i++) {
        unput(yytext[i]);
    }

    // check if the operator is plus or negative
    printf("%c", yytext[0]);
    if (yytext[0] == '+') {
        return PLUS;
    } else if (yytext[0] == '-') {
        return MINUS;
    }
    return 0;
}

void check_digit() {
    check_print_header();
    printf("%s", yytext);
    token_count++;
    cur_char += yyleng;

    // store digit as string
    yylval.strval = (char *)malloc(strlen(yytext) + 1);
    sscanf(yytext, "%s", yylval.strval);
}

void check_boolean() {
    check_print_header();
    printf("%s", yytext);
    char_count += yyleng;
    token_count++;
    cur_char += yyleng;

    // store boolean as string
    yylval.strval = (char *)malloc(strlen(yytext) + 1);
    sscanf(yytext, "%s", yylval.strval);
}

int yywrap(){
    return 1;
}

void check_line_header() {
    printf("Line %d: ", line_count);
    for(int i = 0; i < space_count; i++) {
        printf(" ");
    }
    start_printing_space = 1;
    space_count = 0;
}

void check_print_header() {
    if(is_new_line) {
        check_line_header();
        is_new_line = 0;
    } 
}

void handle_new_line() {
    if (!is_new_line) {
        puts("");
    }
    line_count++; 
    cur_char = 1;
    preceeding_num = 0; 
    is_new_line = 1; 
    space_count = 0;
    start_printing_space = 0;
}
