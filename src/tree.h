/* tree.h */

typedef enum {
  Prog_e,
  TYPE_e,
  EQ_e,
  ORDER_e,
  DIVSTAR_e,
  ADDSUB_e,
  ADDSUB_UN_e,
  OR_e,
  AND_e,
  NUM_e,
  CHARACTER_e,
  IF_e,
  ELSE_e,
  IDENT_e,
  VOID_e,
  WHILE_e,
  RETURN_e,
  DeclVars_e,
  Declarateurs_e,
  DeclFoncts_e,
  EnTeteFonct_e,
  Corps_e,
  Parametres_e,
  ListTypVar_e,
  SuiteInstr_e,
  Instr_e,
  Exp_e,
  TB_e,
  FB_e,
  M_e,
  E_e,
  T_e,
  F_e,
  LValue_e,
  Arguments_e,
  ListExp_e,
  Negatif_e,
  Assign_e,
  ARRAY_e,
  AppelFonc_e
  /* list all other node labels, if any */
  /* The list must coincide with the string array in tree.c */
  /* To avoid listing them twice, see https://stackoverflow.com/a/10966395 */
} label_t;

typedef struct Node {
  label_t label;
  struct Node *firstChild, *nextSibling;
  int lineno;
} Node;

Node *makeNode(label_t label);
void addSibling(Node *node, Node *sibling);
void addChild(Node *parent, Node *child);
void deleteTree(Node*node);
void printTree(Node *node);

#define FIRSTCHILD(node) node->firstChild
#define SECONDCHILD(node) node->firstChild->nextSibling
#define THIRDCHILD(node) node->firstChild->nextSibling->nextSibling
