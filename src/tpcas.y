%{
#include "tree.h"
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
int yyerror(const char *s);
int yylex(void);
extern int lineno;
extern int charno;
extern FILE* yyin;
Node* root;
%}

%union {
    Node *node;
    char ident[64];
    int num;
}

%type <node> Prog DeclVars Declarateurs DeclArray
DeclFoncts DeclFonct EnTeteFonct Parametres
ListTypVar Corps SuiteInstr Instr 
Exp TB FB M E T F LValue Arguments ListExp

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
    {
        root = makeNode(Prog_e);
        strcpy(root->text, "Prog");
        addChild(root, $1);
        addChild(root, $2);
    }
    ;

DeclVars:
       DeclVars TYPE Declarateurs ';' {
        $$ = $1;
        Node* type = makeNode(TYPE_e);
        strcpy(type->text, "Type : ");
        strcat(type->text, $2);
        addChild($1, type);
        addChild(type, $3);
       }
    | {
        $$ = makeNode(DeclVars_e);
        strcpy($$->text, "DeclVars");
    }
    ;
Declarateurs:
       Declarateurs ',' IDENT {
        $$ = $1;
        Node* temp = makeNode(IDENT_e);
        strcpy(temp->text, $3);
        addSibling($$, temp);
       }
    |  Declarateurs ',' DeclArray {
        $$ = $1;
        addSibling($1, $3);
    }
    |  DeclArray {
        $$ = $1;
    }
    |  IDENT {
        $$ = makeNode(IDENT_e);
        strcpy($$->text, $1);
    }
    ;
DeclArray:
        IDENT '[' NUM ']' {
            $$ = makeNode(ARRAY_e);
            sprintf($$->text, "%s[%d]", $1, $3);

            addChild($$, makeNode(IDENT_e));
            strcpy($$->firstChild->text, $1);
            addChild($$, makeNode(NUM_e));
            sprintf(SECONDCHILD($$)->text, "%d", $3);
        }
    ;
DeclFoncts:
       DeclFoncts DeclFonct {
        $$ = $1;
        addSibling($$, $2);
       }
    |  DeclFonct {$$ = $1;}
    ;
DeclFonct:
       EnTeteFonct Corps {
        $$ = makeNode(DeclFoncts_e);
        strcpy($$->text, "DeclFonct");
        addChild($$, $1);
        addChild($$, $2);
       }
    ;
EnTeteFonct:
       TYPE IDENT '(' Parametres ')' {
        $$ = makeNode(EnTeteFonct_e);
        strcpy($$->text, "EnTeteFonct");
        addChild($$, makeNode(TYPE_e));
        sprintf(FIRSTCHILD($$)->text, "Type : %s", $1);
        addChild($$, makeNode(IDENT_e));
        strcpy(SECONDCHILD($$)->text, $2);
        addChild($$, $4);
    }
    |  VOID IDENT '(' Parametres ')' {
        $$ = makeNode(EnTeteFonct_e);
        addChild($$, makeNode(VOID_e));
        strcpy(FIRSTCHILD($$)->text, $1);
        addChild($$, makeNode(IDENT_e));
        strcpy(SECONDCHILD($$)->text, $2);
        addChild($$, $4);
    }
    ;
Parametres:
       VOID {
        $$ = makeNode(Parametres_e);
        strcpy($$->text, "Parametres");
        addChild($$, makeNode(VOID_e));
        strcpy(FIRSTCHILD($$)->text, $1);
        }
    |  ListTypVar {
        $$ = makeNode(Parametres_e);
        strcpy($$->text, "Parametres");
        addChild($$, $1);
    }
    ;
ListTypVar:
       ListTypVar ',' TYPE IDENT {
        $$ = $1;
        Node* type = makeNode(TYPE_e);
        sprintf(type->text, "Type : %s", $3);
        addChild(type, makeNode(IDENT_e));
        strcpy(FIRSTCHILD(type)->text, $4);
        addChild($$, type);
       }
    |  ListTypVar ',' TYPE IDENT '[' ']' {
        $$ = $1;
        Node* type = makeNode(TYPE_e);
        sprintf(type->text, "Type : %s", $3);
        addChild(type, makeNode(IDENT_e));
        sprintf(FIRSTCHILD(type)->text, "%s[]",$4);
        addChild($$, type);
    }
    |  TYPE IDENT {
        $$ = makeNode(TYPE_e);
        sprintf($$->text, "Type : %s", $1);
        addChild($$, makeNode(IDENT_e));
        strcpy(FIRSTCHILD($$)->text, $2);
    }
    |  TYPE IDENT '[' ']' {
        $$ = makeNode(TYPE_e);
        sprintf($$->text, "Type : %s", $1);
        addChild($$, makeNode(IDENT_e));
        sprintf(FIRSTCHILD($$)->text, "%s[]",$2);
    }
    ;
Corps: '{' DeclVars SuiteInstr '}' {
        $$ = makeNode(Corps_e);
        strcpy($$->text, "Corps");
        addChild($$, $2);
        addChild($$, $3);
    }
    ;
SuiteInstr:
       SuiteInstr Instr {
        if ($1 == NULL){
            $$ = $2;
        }
        else {
            $$ = $1;
            addSibling($$, $2);
        }
       }
    | {$$ = NULL;}
    ;
Instr:
       LValue '=' Exp ';' {
        $$ = makeNode(Assign_e);
        strcpy($$->text, "Assign");
        addChild($$, $1);
        addChild($$, $3);
       }
    |  IF '(' Exp ')' Instr {
        $$ = makeNode(IF_e);
        strcpy($$->text, "IF");
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IF '(' Exp ')' Instr ELSE Instr {
        $$ = makeNode(IF_e);
        strcpy($$->text, "IF");
        addChild($$, $3);
        addChild($$, $5);
        addChild($$, $7);
    }
    |  WHILE '(' Exp ')' Instr {
        $$ = makeNode(WHILE_e);
        strcpy($$->text, "WHILE");
        addChild($$, $3);
        addChild($$, $5);
    }
    |  IDENT '(' Arguments  ')' ';' {
        $$ = makeNode(AppelFonc_e);
        strcpy($$->text, "AppelFonc");
        addChild($$, makeNode(IDENT_e));
        strcpy(FIRSTCHILD($$)->text, $1);
        addChild($$, $3);
    }
    |  RETURN Exp ';' {
        $$ = makeNode(RETURN_e);
        strcpy($$->text, "RETURN");
        addChild($$, $2);
    }
    |  RETURN ';' {
        $$ = makeNode(RETURN_e);
        strcpy($$->text, "RETURN");
        }
    |  '{' SuiteInstr '}' {$$ = $2;}
    |  ';' {$$ = NULL;}
    ;
Exp :  Exp OR TB {
        $$ = makeNode(OR_e);
        strcpy($$->text, "OR");
        addChild($$, $1);
        addChild($$, $3);
    }
    |  TB {
        $$ = $1;
    }
    ;
TB  :  TB AND FB {
        $$ = makeNode(AND_e);
        strcpy($$->text, "AND");
        addChild($$, $1);
        addChild($$, $3);
    }
    |  FB {
        $$ = $1;
    }
    ;
FB  :  FB EQ M {
        $$ = makeNode(EQ_e);
        strcpy($$->text, "EQ");
        addChild($$, $1);
        addChild($$, $3);
    }
    |  M {
        $$ = $1;
    }
    ;
M   :  M ORDER E {
        $$ = makeNode(ORDER_e);
        strcpy($$->text, "ORDER");
        addChild($$, $1);
        addChild($$, $3);
    }
    |  E {
        $$ = $1;
    }
    ;
E   :  E ADDSUB T {
        $$ = makeNode(ADDSUB_e);
        strcpy($$->text, "ADDSUB");
        addChild($$, $1);
        addChild($$, $3);
    }
    |  T {
        $$ = $1;
    }
    ;    
T   :  T DIVSTAR F {
        $$ = makeNode(DIVSTAR_e);
        strcpy($$->text, "DIVSTAR");
        addChild($$, $1);
        addChild($$, $3);
    }
    |  F {
        $$ = $1;
    }
    ;
F   :  ADDSUB F {
        $$ = makeNode(ADDSUB_UN_e);
        strcpy($$->text, "Addsub Unitaire");
        addChild($$, $2);
    }
    |  '!' F {
        $$ = makeNode(Negatif_e);
        strcpy($$->text, "!");
        addChild($$, $2);
    }
    |  '(' Exp ')' {
        $$ = $2;
    }
    |  NUM {
        $$ = makeNode(NUM_e);
        sprintf($$->text, "%d", $1);
        }
    |  CHARACTER {
        $$ = makeNode(CHARACTER_e);
        sprintf($$->text, "%s", $1);
        }
    |  LValue {$$ = $1;}
    |  IDENT '(' Arguments ')' {
        $$ = makeNode(AppelFonc_e);
        strcpy($$->text, "AppelFonc");
        addChild($$, makeNode(IDENT_e));
        strcpy(FIRSTCHILD($$)->text, $1);
        addChild($$, $3);
    } 
    ;
LValue:
       IDENT {
        $$ = makeNode(IDENT_e);
        strcpy($$->text, $1);
        }
    |  IDENT '[' Exp ']' {
        $$ = makeNode(IDENT_e);
        strcpy($$->text, $1);
        strcat($$->text, "[]");
        addChild($$, $3);
    } 
    ;
Arguments:
       ListExp {
        $$ = makeNode(Arguments_e);
        strcpy($$->text, "Arguments");
        addChild($$, $1);
       }
    | {$$ = NULL;}
    ;
ListExp:
       ListExp ',' Exp {
        $$ = $1;
        addSibling($$, $3);
       }
    |  Exp {
        $$ = $1;
    }
    ;
%%


int yyerror(const char *s) {
    fprintf(stderr, "%s on line %d at character %d\n", s, lineno, charno);
    return 1;
}


void help() {
    printf("This program is able to detect syntax errors in a C file provided.\n");
    printf("Usage : ./bin/tpcas [filepath] [-t/--tree] [-h/--help]\n");
    printf(" - file path (mandatory) : first non-optional argument, provides the file path to analyze.\n");
    printf(" - -t / --tree (optional) : prints code tree if the file provided has no syntax error.\n");
    printf(" - -h / --help (optional) : shows you this help message (only)");
}


int main(int argc, char* argv[]) {
    int opt;
    int tree = 0;

    static struct option long_options[] = {
        {"help", no_argument, 0, 'h'},
        {"tree", no_argument, 0, 1},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "ht", long_options, NULL)) != -1) {
        switch (opt) {
            case 'h':
                help();
                return EXIT_SUCCESS;
            case 't':
                tree = 1;
                break;
            default:
                fprintf(stderr, "Unknown option %c. Use -h or --help for help.\n", opt);
                return EXIT_FAILURE;
        }
    }

    if (argv[optind] != NULL) {
        if ((yyin = fopen(argv[optind], "r"))) {
            fprintf(stderr, "File not found. Use -h or --help for help.\n");
            return EXIT_FAILURE;
        }
    }
    else {
        fprintf(stderr, "No filename given. Reading standard input. Use -h or --help for help.\n");
    }

    

    int res = yyparse();
    if (res == 0 && tree) printTree(root);

    return res;
}
