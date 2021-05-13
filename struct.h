#ifndef _STRUCT_H
#define _STRUCT_H

#define TAILLE 163

typedef enum
{
    FONCTION,
    EXT,
    APPEL,
    COND,
    RET,
    BRK,
    HEAD,
    NONE
} type_t;

typedef struct _param_t
{
    char *type;
    char *nom;
} param_t;

typedef struct _liste_t
{
    param_t param;
    struct _liste_t *suivant;
} liste_t;

typedef struct _tree_t
{
    char *node_name;
    type_t node_type;
    int node_number;
    struct _tree_t *fils;
    struct _tree_t *next_to;
} tree_t;

typedef struct _symbole_t
{
    char *nom;
    char *type;
    int valeur;
    struct _symbole_t *suivant;
} symbole_t;

tree_t *init_tree(char *node_name, tree_t *fils, type_t type);
void insert_node(tree_t *list_node, tree_t *node);
void print_tabs(int count);
void print_tree_recursive(tree_t *tree, int level);
void print_tree(tree_t *t);
FILE *create_file();
void close_file(FILE *fp);
void node_gen(tree_t *tree, FILE *fp, int *count);
void print_node(tree_t *tree, FILE *fp);
void link_rec(tree_t *tree, tree_t *father, FILE *fp);
void print_link(tree_t *tree, tree_t *father, FILE *fp);
void link_gen(tree_t *tree, FILE *fp);
void dot_gen(tree_t *tree, int *counter);
int hash(char *nom);
void table_reset();
symbole_t *insert(char *nom);
symbole_t *search(char *nom);
void add_type(symbole_t *symbole, char *type);
void add_type_on_list(symbole_t *symbole, char *type);
char *get_type(symbole_t *symbole);
void add_value(symbole_t *symbole, int valeur);
int check_type(symbole_t *symbole, char *type);
void print_table(symbole_t *table);
void insert_symbole(symbole_t *list_symbole, symbole_t *symbole);
symbole_t *create_head(char *nom);
symbole_t *table[TAILLE];

#endif
