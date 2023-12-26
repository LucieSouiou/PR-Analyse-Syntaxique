%{
#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
int yyerror(const char *s);
int yylex(void);
extern int lineno;
%}

%union {
    Node *node;
    char ident[64];
    char byte;
    int num;
}

%token <ident>TYPE;
%token <ident>EQ;
%token <ident>ORDER;
%token <ident>DIVSTAR;
%token <ident>ADDSUB;
%token <ident>OR;
%token <ident>AND;
%token <num>NUM;
%token <ident>CHARACTER;
%token <ident>ELSE;
%token <ident>IDENT;
%token <ident>VOID;
%token <ident>WHILE;
%token <ident>RETURN;
%token <ident>IF;
%expect 1 

%%
Prog:  DeclVars DeclFoncts
    ;
DeclVars:
       DeclVars TYPE Declarateurs ';'
    |
    ;
Declarateurs:
       Declarateurs ',' IDENT
    |  Declarateurs ',' DeclArray
    |  DeclArray
    |  IDENT
    ;
DeclArray:
        IDENT '[' NUM ']'
    ;
DeclFoncts:
       DeclFoncts DeclFonct
    |  DeclFonct
    ;
DeclFonct:
       EnTeteFonct Corps
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')'
    |  VOID IDENT '(' Parametres ')'
    ;
Parametres:
       VOID
    |  ListTypVar
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT
    |  ListTypVar ',' TYPE IDENT '[' ']'
    |  TYPE IDENT
    |  TYPE IDENT '[' ']'
    ;
Corps: '{' DeclVars SuiteInstr '}'
    ;
SuiteInstr:
       SuiteInstr Instr
    |
    ;
Instr:
       LValue '=' Exp ';'
    |  IF '(' Exp ')' Instr
    |  IF '(' Exp ')' Instr ELSE Instr
    |  WHILE '(' Exp ')' Instr
    |  IDENT '(' Arguments  ')' ';'
    |  RETURN Exp ';'
    |  RETURN ';'
    |  '{' SuiteInstr '}'
    |  ';'
    ;
Exp :  Exp OR TB
    |  TB
    ;
TB  :  TB AND FB
    |  FB
    ;
FB  :  FB EQ M
    |  M
    ;
M   :  M ORDER E
    |  E
    ;
E   :  E ADDSUB T
    |  T
    ;    
T   :  T DIVSTAR F 
    |  F
    ;
F   :  ADDSUB F
    |  '!' F
    |  '(' Exp ')'
    |  NUM
    |  CHARACTER
    |  LValue
    |  IDENT '(' Arguments ')'
    ;
LValue:
       IDENT
    |  IDENT '[' Exp ']'
    ;
Arguments:
       ListExp
    |
    ;
ListExp:
       ListExp ',' Exp
    |  Exp
    ;
%%
