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

//Table de symboles

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

int insert_in_table(symbole_t *symbole)
{
    char *nom = symbole->nom;
    symbole_t *research_result;
    research_result = research(nom);
    if (research_result != NULL)
    {
        fprintf(stdout, "le symbole existe déjà dans la table, insertion impossible\n");

        return 0;
    }
    else
    {
        int h;
        h = hash(nom);
        table[h] = symbole;
        fprintf(stdout, "le symbole %s a été inséré dans la table en %d\n", nom, h);
        return 1;
    }
}

symbole_t *research(char *nom)
{
    int i;
    for (i = 0; i < TAILLE; i++)
    {
        if (table[i] != NULL)
        {
            if (strcmp(table[i]->nom, nom) == 0)
            {
                fprintf(stdout, "symbol %s found in table, access to %d\n", nom, i);
                return table[i];
            }
            else if (table[i]->suivant != NULL)
            {
                symbole_t *current_symbole;
                current_symbole = table[i]->suivant;
                if (strcmp(current_symbole->nom, nom) == 0)
                {
                    fprintf(stdout, "symbol %s found in table, access to %d\n", nom, i);
                    return current_symbole;
                }
                else
                {
                    while (current_symbole->suivant != NULL)
                    {
                        if (strcmp(current_symbole->suivant->nom, nom) == 0)
                        {
                            fprintf(stdout, "symbol %s found in table, access to %d\n", nom, i);
                            return current_symbole->suivant;
                        }
                        current_symbole = current_symbole->suivant;
                    }
                }
            }
        }
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

int check_type_s(symbole_t *symbole, char *type)
{
    if (strcmp(symbole->type, type) == 0)
    {
        return 1;
    }
    return 0;
}

int check_type_t(tree_t *tree, char *type, int line)
{
    if (tree->node_type == VAR)
    {
        symbole_t *symbole = research(tree->node_name);
        if (symbole != NULL)
        {
            fprintf(stdout, "ici1\n");
            return 1;
        }
        else
        {
            fprintf(stdout, "ici2\n");
            return 0;
        }
    }
    else if (tree->node_type == APPEL)
    {
        fprintf(stdout, "ici3\n");
        return 0;
    }
    else if (tree->node_type == EXPR)
    {
        int result;
        result = cmp_type_expr(tree->fils, tree->fils->next_to, line);
        fprintf(stdout, "ici4\n");
        return result;
    }
    else
    {
        fprintf(stdout, "ici5\n");
        return 1;
    }
}

void print_symbole(symbole_t *symbole)
{
    while (symbole != NULL)
    {
        fprintf(stdout, "symbole : %s\n type : %s\n\n", symbole->nom, symbole->type);
        symbole = symbole->suivant;
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
        insert_symbole(head, symbole);
    }
}

symbole_t *create_symbole(char *nom)
{
    struct _symbole_t *new_symbole = (symbole_t *)malloc(sizeof(symbole_t));
    char *name;
    name = (char *)malloc(strlen(nom + 1) * sizeof(char));
    strcpy(name, nom);
    new_symbole->nom = name;
    new_symbole->type = NULL;
    new_symbole->suivant = NULL;
}

void throw_error(char *error, int line)
{
    fprintf(stderr, "erreur sémantique ligne : %d, %s\n", line, error);
    exit(1);
}

void print_table(symbole_t **table)
{
    int i;
    for (i = 0; i < TAILLE; i++)
    {
        if (table[i] != NULL)
        {
            fprintf(stdout, "%d\n", i);
            print_symbole(table[i]);
        }
        else
        {
            fprintf(stdout, "%d : null\n", i);
        }
    }
}

int cmp_type_affect(tree_t *t1, tree_t *t2, int line)
{
    symbole_t *s1;
    symbole_t *s2;
    s1 = research(t1->node_name);
    if (s1 == NULL)
    {
        throw_error("partie gauche non déclarée", line);
        return 0;
    }
    else
    {
        type_t type;
        type = t2->node_type;
        if (type == VAR)
        {
            s2 = research(t2->node_name);
            if (s2 != NULL)
            {
                return 1;
            }
            else
            {
                throw_error("partie droite non déclarée", line);
                return 0;
            }
        }
        else if (type == APPEL)
        {
            s2 = research(t2->node_name);
            if (s2 != NULL)
            {
                if (strcmp(get_type(s1), get_type(s2)) == 0)
                {
                    return 1;
                }
                else
                {
                    throw_error("types non équivalent", line);
                    return 0;
                }
            }
            else
            {
                throw_error("partie droite non déclarée", line);
                return 0;
            }
        }
        else if (type == EXPR)
        {
            int result;
            result = cmp_type_expr(t2->fils, t2->fils->next_to, line);
            return result;
        }
        else
        {
            return 1;
        }
    }
}

int cmp_type_expr(tree_t *t1, tree_t *t2, int line)
{
    symbole_t *s1;
    symbole_t *s2;
    if (t1->node_type == VAR)
    {
        s1 = research(t1->node_name);
        if (s1 == NULL)
        {
            fprintf(stdout, "ici6\n");
            return 0;
        }
        else
        {
            if (t2->node_type == VAR)
            {
                s2 = research(t1->node_name);
                if (s2 == NULL)
                {
                    fprintf(stdout, "ici7\n");
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
            else if (t2->node_type == APPEL)
            {
                fprintf(stdout, "ici8\n");
                return 0;
            }
            else if (t2->node_type == EXPR)
            {
                int result;
                result = cmp_type_expr(t2->fils, t2->fils->next_to, line);
                fprintf(stdout, "ici9\n");
                return result;
            }
            else
            {
                return 1;
            }
        }
    }
    else if (t1->node_type == APPEL)
    {
        fprintf(stdout, "ici10\n");
        return 0;
    }
    else if (t1->node_type == EXPR)
    {
        int result;
        result = cmp_type_expr(t1->fils, t1->fils->next_to, line);
        if (result == 1)
        {
            if (t2->node_type == VAR)
            {
                s2 = research(t2->node_name);
                if (s2 == NULL)
                {
                    fprintf(stdout, "ici11\n");
                    return 0;
                }
                else
                {
                    return 1;
                }
            }
            else if (t2->node_type == APPEL)
            {
                fprintf(stdout, "ici12\n");
                return 0;
            }
            else if (t2->node_type == EXPR)
            {
                int result;
                result = cmp_type_expr(t2->fils, t2->fils->next_to, line);
                fprintf(stdout, "ici13\n");
                return result;
            }
            else
            {
                return 1;
            }
        }
        else
        {
            fprintf(stdout, "ici14\n");
            return 0;
        }
    }
    else
    {
        return 1;
    }
}

void add_follower(symbole_t *s1, symbole_t *s2)
{
    s1->suivant = s2;
}