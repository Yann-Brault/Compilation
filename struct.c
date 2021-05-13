#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "struct.h"
#include "y.tab.h"

tree_t *init_tree(char *node_name, tree_t *fils, type_t type)
{
    struct _tree_t *new_tree = (tree_t *)malloc(sizeof(tree_t));
    char *name;
    name = (char *)malloc(strlen(node_name + 1) * sizeof(char));
    strcpy(name, node_name);
    new_tree->node_name = name;
    new_tree->node_type = type;
    new_tree->fils = fils;
    new_tree->next_to = NULL;
    return new_tree;
}

void insert_node(tree_t *list_node, tree_t *node)
{
    tree_t *head = list_node->next_to;
    if (head == NULL)
    {
        list_node->next_to = node;
    }
    else
    {
        insert_node(head, node);
    }
}

//print
void print_tabs(int count)
{
    for (int i = 0; i < count; i++)
    {
        putchar('\t');
    }
}

void print_tree_recursive(tree_t *tree, int level)
{
    while (tree != NULL)
    {
        print_tabs(level);
        printf("Node : %s\n", tree->node_name);
        if (tree->fils != NULL)
        {
            print_tabs(level);
            printf("fils : \n");
            print_tree_recursive(tree->fils, level + 1);
        }
        tree = tree->next_to;
        printf("\n");
    }
}

void print_tree(tree_t *tree)
{
    print_tree_recursive(tree, 0);
}

//dot gen

FILE *create_file()
{
    FILE *fp = fopen("graph.dot", "w");
    fprintf(fp, "digraph mon_programme {\n");
    return fp;
}

void close_file(FILE *fp)
{
    fprintf(fp, "}\n");
    fclose(fp);
}

void node_gen(tree_t *tree, FILE *fp, int *count)
{
    while (tree != NULL)
    {
        *count = *count + 1;
        tree->node_number = *count;
        print_node(tree, fp);
        if (tree->fils != NULL)
        {
            node_gen(tree->fils, fp, count);
        }
        tree = tree->next_to;
    }
}

void print_node(tree_t *tree, FILE *fp)
{
    type_t type = tree->node_type;
    char *name = tree->node_name;
    int number = tree->node_number;
    switch (type)
    {
    case FONCTION:
        fprintf(fp, "node_%d [label=\"%s\"shape=invtrapezium color=blue];\n", number, name);
        break;
    case APPEL:
        fprintf(fp, "node_%d [label=\"%s\"shape=septagon];\n", number, name);
        break;
    case COND:
        fprintf(fp, "node_%d [label=\"%s\"shape=diamond];\n", number, name);
        break;
    case RET:
        fprintf(fp, "node_%d [label=\"%s\"shape=trapezium color=blue];\n", number, name);
        break;
    case BRK:
        fprintf(fp, "node_%d [label=\"%s\"shape=box];\n", number, name);
        break;
    case NONE:
        fprintf(fp, "node_%d [label=\"%s\"shape=ellipse];\n", number, name);
        break;
    default:
        break;
    }
}

void link_rec(tree_t *tree, tree_t *father, FILE *fp)
{
    while (tree != NULL)
    {
        if (tree->fils != NULL)
        {
            link_rec(tree->fils, tree, fp);
        }
        if (father != NULL)
        {
            if (tree->node_number != father->node_number)
            {
                print_link(tree, father, fp);
            }
        }
        tree = tree->next_to;
    }
}

void print_link(tree_t *tree, tree_t *father, FILE *fp)
{

    if (tree->node_type != EXT)
    {
        if (tree->node_type != HEAD)
        {
            fprintf(fp, "node_%d -> node_%d;\n", father->node_number, tree->node_number);
        }
    }
}

void link_gen(tree_t *t, FILE *fp)
{
    link_rec(t, t, fp);
}

void dot_gen(tree_t *tree, int *counter)
{
    FILE *fp = create_file();
    node_gen(tree, fp, counter);
    fprintf(fp, "\n");
    link_gen(tree, fp);
    close_file(fp);
}

int hash(char *nom)
{
    int i, r;
    int taille = strlen(nom);
    r = 0;
    for (i = 0; i < TAILLE; i++)
    {
        r = ((r << 8) + nom[i]) % TAILLE;
    }
    return r;
}

void table_reset()
{
    int i;
    for (i = 0; i < TAILLE; i++)
    {
        table[i] = NULL;
    }
}

symbole_t *insert(char *nom)
{
    int h;
    symbole_t *s;
    symbole_t *precedent;
    h = hash(nom);
    s = table[h];
    precedent = NULL;
    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0)
        {
            return s;
        }
        precedent = s;
        s = s->suivant;
    }
    if (precedent == NULL)
    {
        table[h] = (symbole_t *)malloc(sizeof(symbole_t));
        s = table[h];
    }
    else
    {
        precedent->suivant = (symbole_t *)malloc(sizeof(symbole_t));
        s = precedent->suivant;
    }
    s->nom = strdup(nom);
    s->suivant = NULL;
    return s;
}

symbole_t *search(char *nom)
{
    int h;
    symbole_t *s;
    symbole_t *precedent;
    h = hash(nom);
    s = table[h];
    precedent = NULL;
    while (s != NULL)
    {
        if (strcmp(s->nom, nom) == 0)
        {
            return s;
        }
        precedent = s;
        s = s->suivant;
    }
    return NULL;
}

void add_type(symbole_t *symbole, char *type)
{
    symbole->type = type;
}

void add_type_on_list(symbole_t *symbole, char *type)
{
    while (symbole != NULL)
    {
        add_type(symbole, type);
        symbole = symbole->suivant;
    }
}

char *get_type(symbole_t *symbole)
{
    char *type;
    type = (char *)malloc((strlen(symbole->type + 1) * sizeof(char)));
    strcpy(type, symbole->type);
    return type;
}

void add_value(symbole_t *symbole, int valeur)
{
    symbole->valeur = valeur;
}

int check_type(symbole_t *symbole, char *type)
{
    if (strcmp(symbole->type, type) == 0)
    {
        return 1;
    }
    return 0;
}

void print_table(symbole_t *table)
{
    while (table != NULL)
    {
        fprintf(stdout, "symbole : %s \n type : %s \n value : %d \n\n", table->nom, table->type, table->valeur);
        table = table->suivant;
    }
}

void insert_symbole(symbole_t *list_symbole, symbole_t *symbole)
{
    symbole_t *head = list_symbole->suivant;
    if (head == NULL)
    {
        list_symbole->suivant = symbole;
    }
    else
    {
        insert_node(head, symbole);
    }
}

symbole_t *create_head(char *nom)
{
    symbole_t *new_symbol;
    new_symbol = (symbole_t *)malloc
}