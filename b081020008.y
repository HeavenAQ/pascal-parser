%{ #include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "stack.h"
#define BUF_SIZE 1024

#define YYDEBUG 1
int yylex();
extern unsigned char_count, line_count, token_count, cur_char;
extern char* yytext;
int cur_error_line = 0;
Stack* identifier_stack;
Stack* identifier_tmp_stack;
Stack* expression_stack;
char* cur_lhs_identifier;
int cur_lhs_type;
int cur_rhs_type;
int check_lhs = 0;

void yyerror(char* message);
void store_identifiers();
void check_identifier(char* identifier);
void check_expression();
char* enum_to_type(int type);
%}
%error-verbose
%union {
    char* strval;
    enum { TYPE_STRING, TYPE_CHAR, TYPE_INT, TYPE_REAL, TYPE_BOOLEAN, TYPE_ARRAY } dtype;
    struct Node* nodeval;
}

%type <strval> IDENTIFIER INTEGER REAL_NUM STRING BOOLEAN DIGIT checked_identifier
%type <dtype> type DATA_TYPE
%type <nodeval> factor term expression
%token RESERVED_WORD DATA_TYPE IDENTIFIER INVALID_IDENTIFIER BOOLEAN
%token STRING
%token INTEGER REAL_NUM DIGIT
%token AND ARRAY myBEGIN CASE CONST DIV DO DOWNTO ELSE END myFILE FOR FUNCTION GOTO IF IN LABEL MOD NIL NOT OF OR PACKED PROCEDURE PROGRAM RECORD REPEAT SET THEN TO TYPE UNTIL VAR WHILE WITH ABSOLUTE CONTINUE OBJECT WRITE WRITELN  
%token SEMICOLON COLON COMMA DOT DOTDOT LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE PLUS MINUS MULTIPLY DIVIDE ASSIGN EQUAL NOT_EQUAL LESS_THAN GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL

%start program

%%

program: PROGRAM IDENTIFIER SEMICOLON declarations myBEGIN statements END DOT
       ;

declarations: VAR declaration_list
            ;

declaration_list: declaration SEMICOLON declaration_list
                | declaration SEMICOLON
                ;

declaration: identifier_list COLON type { store_identifiers(); destroy_stack(identifier_tmp_stack); init_stack(&identifier_tmp_stack);}
           | identifier_list COLON { yyerror("sytax error: data type missing"); }
           | error { yyerror(yymsg); }
           ;

identifier_list: IDENTIFIER { identifier_tmp_stack->push(identifier_tmp_stack, $1); }
               | identifier_list COMMA IDENTIFIER { identifier_tmp_stack->push(identifier_tmp_stack, $3);}
               ;

type: DATA_TYPE { 
        Node* tmp = identifier_tmp_stack->head;
        while(tmp != NULL) {
            tmp->type = $1;
            tmp = tmp->next;
        }
    } 
    | array_type  
    ;

array_type: ARRAY LBRACKET DIGIT DOTDOT DIGIT RBRACKET OF type { identifier_tmp_stack->head->is_array = true; identifier_tmp_stack->head->type = $8; }
          ;

statements: 
    // A sequence of statements separated by semicolons
    statement SEMICOLON statements
    | statement SEMICOLON
    ;

statement: 
    // Handle variable assignments and ensure type correctness
    assignment
    // Handle if statements
    | if_statement
    // Handle for loops
    | for_statement
    // Handle write statements
    | write_statement
    // Handle writeln statements
    | WRITELN
    // Error handling for invalid statements
    | error { yyerror(yymsg);}
    ;

assignment: 
    // Assignment for scalar variables, check if the identifier is declared
    IDENTIFIER { 
                check_identifier($1); 
                Node* tmp = identifier_stack->search(identifier_stack, $1);
                if (tmp) {
                    // Store LHS type and identifier for type checking
                    cur_lhs_type = tmp->type;
                    cur_lhs_identifier = $1;
                    check_lhs = 1;
                }
            } ASSIGN expression { check_expression(); }
    // Assignment for array elements, check if the identifier is declared
    | IDENTIFIER { 
                check_identifier($1); 
                Node* tmp = identifier_stack->search(identifier_stack, $1);
                if (tmp) {
                    // Store LHS type and identifier for type checking
                    cur_lhs_type = tmp->type;
                    cur_lhs_identifier = $1;
                    check_lhs = 1;
                }
            } LBRACKET expression { check_expression(); } RBRACKET ASSIGN expression { check_expression(); }
    ;

if_statement: 
    // If-else statement with else part
    IF expression THEN statement ELSE statement
    // If statement without else part
    | IF expression THEN statement
    ;

for_statement: 
    // For loop statement with checked identifier
    FOR checked_identifier ASSIGN expression TO expression DO myBEGIN statements END
    // For loop statement with a single statement body
    | FOR checked_identifier ASSIGN expression TO expression DO statement
    ;

checked_identifier: 
    // Check if the identifier in the for loop is declared
    IDENTIFIER { check_identifier($1); $$ = $1; }
    ;

write_statement: 
    // Write statement with a list of expressions to output
    WRITE LPAREN expression_list RPAREN
    ;

expression_list: 
    // A single expression in the write statement
    expression { destroy_stack(expression_stack); init_stack(&expression_stack); }
    // Multiple expressions in the write statement separated by commas
    | expression_list COMMA expression { destroy_stack(expression_stack); init_stack(&expression_stack); }
    ;

expression: 
    // Expressions involving addition, subtraction, OR, AND, and comparison operators
    expression PLUS term { check_expression(); }
    | expression MINUS term { check_expression(); }
    | expression OR term { check_expression(); }
    | expression AND term { check_expression(); }
    | expression EQUAL term { check_expression(); }
    | expression LESS_THAN term { check_expression(); }
    | expression GREATER_THAN term { check_expression(); }
    | expression LESS_THAN_EQUAL term { check_expression(); }
    | expression GREATER_THAN_EQUAL term { check_expression(); }
    | expression NOT_EQUAL term { check_expression(); }
    | NOT expression { check_expression(); }
    // Single term expression
    | term 
    ;

term: 
    // Term involving multiplication
    term MULTIPLY factor {
        if($3) {
            expression_stack->push(expression_stack, $3->data);
            expression_stack->head->type = $3->type;
        }
    } 
    // Term involving division
    | term DIVIDE factor {
        if($3) {
            expression_stack->push(expression_stack, $3->data);
            expression_stack->head->type = $3->type;
        }
    } 
    // Term involving modulus
    | term MOD factor {
        if($3) {
            expression_stack->push(expression_stack, $3->data);
            expression_stack->head->type = $3->type;
        }
    }
    // Single factor term
    | factor { 
        if($1) {
            expression_stack->push(expression_stack, $1->data);
            expression_stack->head->type = $1->type;
        }
    }
    ;

factor: 
    // Integer factor
    INTEGER { $$ = init_node($1); $$->type = TYPE_INT; } 
    // Digit factor
    | DIGIT { $$ = init_node($1); $$->type = TYPE_INT;}
    // Identifier factor, check if declared
    | IDENTIFIER { 
            check_identifier($1);
            $$ = identifier_stack->search(identifier_stack, $1);
        }
    // Array element factor, check if identifier is declared
    | IDENTIFIER LBRACKET expression RBRACKET { 
            check_identifier($1);
            $$ = identifier_stack->search(identifier_stack, $1);
        }
    // String factor
    | STRING { $$ = init_node($1); $$->type = TYPE_STRING; }
    // Real number factor
    | REAL_NUM { $$ = init_node($1); $$->type = TYPE_REAL; }
    // Boolean factor
    | BOOLEAN { $$ = init_node($1); $$->type = TYPE_BOOLEAN; }
    // Parenthesized expression
    | LPAREN expression RPAREN { $$ = $2; }
    ;
%%

void replace(char* str, char* old, char* new) {
    char* pos = strstr(str, old);
    if(pos) {
        int len = strlen(old);
        memmove(pos + strlen(new), pos + len, strlen(pos) - len + 1);
        memcpy(pos, new, strlen(new));
    }
}

int main(void) {
    int c = getchar();
    if(c == EOF) {
      puts("Error: No input");
      return 1;
    }   

    init_stack(&identifier_stack);
    init_stack(&identifier_tmp_stack);
    init_stack(&expression_stack);
    ungetc(c, stdin);
    yyparse();
    destroy_stack(identifier_stack);
    destroy_stack(identifier_tmp_stack);
    destroy_stack(expression_stack);
    return 0;
}

void yyerror(char* message) {
    if (line_count == cur_error_line) {
        return;
    }

    replace(message, "myBEGIN", "begin");
    replace(message, "EQUAL", "=");
    replace(message, "NOT_EQUAL", "<>");
    replace(message, "LESS_THAN", "<");
    replace(message, "GREATER_THAN", ">");
    replace(message, "LESS_THAN_EQUAL", "<=");
    replace(message, "GREATER_THAN_EQUAL", ">=");
    replace(message, "MULTIPLY", "*");
    replace(message, "DIVIDE", "/");
    replace(message, "LPAREN", "(");
    replace(message, "RPAREN", ")");
    replace(message, "LBRACKET", "[");
    replace(message, "RBRACKET", "]");
    replace(message, "LBRACE", "{");
    replace(message, "RBRACE", "}");
    replace(message, "SEMICOLON", ";");
    replace(message, "COLON", ":");
    replace(message, "COMMA", ",");
    replace(message, "DOT", ".");
    replace(message, "DOTDOT", "..");
    replace(message, "ASSIGN", ":=");
    fprintf(stderr, "Line %d, at char %d, %s\n > ", line_count, cur_char, message);
    cur_error_line = line_count;
}

void store_identifiers() {
    Node* tmp = identifier_tmp_stack->head;
    for(;tmp != NULL; tmp = tmp->next) {
        identifier_stack->push(identifier_stack, tmp->data);
        identifier_stack->head->type = tmp->type;
    }
}

void check_identifier(char* identifier) {
    Node* res = identifier_stack->search(identifier_stack, identifier);
    if(!res) {
        char* msg = (char*)malloc(BUF_SIZE);
        sprintf(msg, "undeclared identifier: %s", identifier);
        yyerror(msg);
        free(msg);
    }
}

char* enum_to_type(int type) {
    switch(type) {
        case TYPE_INT:
            return "integer";
        case TYPE_REAL:
            return "real";
        case TYPE_STRING:
            return "string";
        case TYPE_BOOLEAN:
            return "boolean";
        case TYPE_ARRAY:
            return "array";
        default:
            return "unknown";
    }
}

void check_expression() {
    // no expression to check, return
    if (!expression_stack->head) {
        return;
    }

    Node* tmp = expression_stack->head;
    while(tmp != NULL) {
        if(expression_stack->head->type != tmp->type) {
            char* msg = (char*)malloc(BUF_SIZE);
            sprintf(msg, "Invalid operation in expression: \"%s\" of type \"%s\" does not match \"%s\" of type \"%s\"", tmp->data, enum_to_type(tmp->type), expression_stack->head->data, enum_to_type(expression_stack->head->type));
            yyerror(msg);
            free(msg);
            break;
        }
        tmp = tmp->next;
    }

    // check if lhs type matches rhs type
    if(check_lhs && expression_stack->head) {
        if(cur_lhs_type != expression_stack->head->type) {
            char* msg = (char*)malloc(BUF_SIZE);
            sprintf(msg, "Invalid assignment: \"%s\" of type \"%s\" does not match \"%s\" of type \"%s", expression_stack->head->data, enum_to_type(expression_stack->head->type), cur_lhs_identifier, enum_to_type(cur_lhs_type));
            yyerror(msg);
            free(msg);
        }
        check_lhs = 0;
    }
    destroy_stack(expression_stack);
    init_stack(&expression_stack);
}
