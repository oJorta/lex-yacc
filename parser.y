%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

typedef struct variavel {
    char* nome;
    int tipo; // 0: NUMERO, 1: CADEIA
    union {
        int valor_num;
        char* valor_str;
    };
    struct variavel* prox;
} variavel;

typedef struct escopo {
    variavel* variaveis;
    struct escopo* prox;
} escopo;

escopo* escopo_atual = NULL;

void empilha_escopo();
void desempilha_escopo();
variavel* encontra_variavel(char* nome);
variavel* encontra_variavel_no_escopo_atual(char* nome);
void adiciona_variavel(char* nome, int tipo);
void inicializa_variavel(variavel* var, double valor_num, char* valor_str);

%}

%union {
    int dval;
    char* sval;
}

%token PRINT BLOCO FIM NUMERO CADEIA
%token <sval> IDENTIFICADOR ID_BLOCO
%token <dval> NUMERO
%token <sval> CADEIA

%type <dval> expr
%type <sval> exprcadeia

%%

programa:
    bloco
    ;

bloco:
    BLOCO ID_BLOCO { empilha_escopo(); } conteudo_bloco FIM ID_BLOCO { desempilha_escopo(); }
    ;

conteudo_bloco:
    | conteudo_bloco comando
    | conteudo_bloco bloco
    ;

comando:
    PRINT IDENTIFICADOR ';' { 
        variavel* var = encontra_variavel($2);
        if (var) {
            if (var->tipo == 0) printf("%d\n", var->valor_num);
            else printf("%s\n", var->valor_str);
        } else {
            printf("Erro: Variável não declarada\n");
        }
    }
    | atribuicao
    | declaracao
    ;

atribuicao:
    IDENTIFICADOR '=' IDENTIFICADOR '+' IDENTIFICADOR ';' {
        variavel* var = encontra_variavel($1);
        variavel* aux_var = encontra_variavel($3);
        variavel* aux_var2 = encontra_variavel($5);

        if (var && aux_var && aux_var2) {
            if (var->tipo == aux_var->tipo && aux_var->tipo == aux_var2->tipo) {
                if (var->tipo == 1) {
                    char* concat_str = (char*)malloc(strlen(aux_var->valor_str) + strlen(aux_var2->valor_str) + 1);
                    strcpy(concat_str, aux_var->valor_str);
                    strcat(concat_str, aux_var2->valor_str);
                    var->valor_str = concat_str;
                }
                else if (var->tipo == 0) {
                    var->valor_num = aux_var->valor_num + aux_var2->valor_num;
                }
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            if (!var) printf("Erro: Variável não declarada\n");
            if (!aux_var) printf("Erro: Variável não declarada\n");
            if (!aux_var2) printf("Erro: Variável não declarada\n");
        }
    }
    | IDENTIFICADOR '=' NUMERO '+' IDENTIFICADOR ';' {
        variavel* var = encontra_variavel($1);
        variavel* aux_var = encontra_variavel($5);

        if (var && aux_var) {
            if (var->tipo == aux_var->tipo) {
                if (var->tipo == 0) {
                    var->valor_num = $3 + aux_var->valor_num;
                }
                else if (var->tipo == 1) {
                    printf("Erro: Atribuição entre tipos incompatíveis\n");
                }
            } else {
                printf("Erro: Atribuição entre tipos incompatíveis\n");
            }
        } else {
            if (!var) printf("Erro: Variável não declarada\n");
            if (!aux_var) printf("Erro: Variável não declarada\n");
        }
    }
    | IDENTIFICADOR '=' IDENTIFICADOR '+' NUMERO ';' {
        variavel* var = encontra_variavel($1);
        variavel* aux_var = encontra_variavel($3);

        if (var && aux_var) {
            if (var->tipo == aux_var->tipo) {
                if (var->tipo == 0) {
                    var->valor_num = $5 + aux_var->valor_num;
                }
                else if (var->tipo == 1) {
                    printf("Erro: Atribuição entre tipos incompatíveis\n");
                }
            } else {
                printf("Erro: Atribuição entre tipos incompatíveis\n");
            }
        } else {
            if (!var) printf("Erro: Variável não declarada\n");
            if (!aux_var) printf("Erro: Variável não declarada\n");
        }
    }
    | IDENTIFICADOR '=' NUMERO '+' NUMERO ';' {
        variavel* var = encontra_variavel($1);
        if (var) {
            if (var->tipo == 0) {
                var->valor_num = $3 + $5;
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            printf("Erro: Variável não declarada\n");
        }
    }

    | IDENTIFICADOR '=' CADEIA '+' IDENTIFICADOR ';' {
        variavel* var = encontra_variavel($1);
        variavel* aux_var = encontra_variavel($5);

        if (var && aux_var) {
            if (var->tipo == 1 && aux_var->tipo == 1) {
                char* concat_str = (char*)malloc(strlen($3) + strlen(aux_var->valor_str) + 1);
                strcpy(concat_str, $3);
                strcat(concat_str, aux_var->valor_str);
                free(var->valor_str);
                var->valor_str = concat_str;
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            if (!var) printf("Erro: Variável não declarada\n");
            if (!aux_var) printf("Erro: Variável não declarada\n");
        }
    }

    | IDENTIFICADOR '=' IDENTIFICADOR '+' CADEIA ';' {
        variavel* var = encontra_variavel($1);
        variavel* aux_var = encontra_variavel($3);

        if (var && aux_var) {
            if (var->tipo == aux_var->tipo) {
                if (var->tipo == 1) {
                    char* concat_str = (char*)malloc(strlen($3) + strlen(strdup($5)) + 1);
                    strcpy(concat_str, $3);
                    strcat(concat_str, strdup($5));
                    var->valor_str = concat_str;
                }
                else if (var->tipo == 0) {
                    printf("Erro: tipos não compatíveis\n");
                }
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            if (!var) printf("Erro: Variável não declarada\n");
            if (!aux_var) printf("Erro: Variável não declarada\n");
        }
    }
    | IDENTIFICADOR '=' CADEIA '+' CADEIA ';' {
        variavel* var = encontra_variavel($1);
        if (var) {
            if (var->tipo == 1) {
                char* concat_str = (char*)malloc(strlen(strdup($3)) + strlen(strdup($5)) + 1);
                strcpy(concat_str, $3);
                strcat(concat_str, $5);
                var->valor_str = concat_str;
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            printf("Erro: Variável não declarada\n");
        }
    }
    

    | IDENTIFICADOR '=' expr ';' {
        variavel* var = encontra_variavel($1);
        if (var) {
            if (var->tipo == 0) {
                var->valor_num = $3;
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            printf("Erro: Variável não declarada\n");
        }
    }
    | IDENTIFICADOR '=' exprcadeia ';' {
        variavel* var = encontra_variavel($1);
        if (var) {
            if (var->tipo == 1) {
                free(var->valor_str);
                var->valor_str = strdup($3);
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            printf("Erro: Variável não declarada\n");
        }
    }
    | IDENTIFICADOR '=' IDENTIFICADOR ';' {
        variavel* var = encontra_variavel($1);
        variavel* aux_var = encontra_variavel($3);
        if (var && aux_var) {
            if (var->tipo == aux_var->tipo) {
                if (var->tipo == 0) var->valor_num = aux_var->valor_num;
                else {
                    free(var->valor_str);
                    var->valor_str = strdup(aux_var->valor_str);
                }
            } else {
                printf("Erro: tipos não compatíveis\n");
            }
        } else {
            if (!var) printf("Erro: Variável não declarada\n");
            if (!aux_var) printf("Erro: Variável não declarada\n");
        }
    }
    ;

declaracao:
    NUMERO lista_declaracao_num ';'
    | CADEIA lista_declaracao_cadeia ';'
    ;

lista_declaracao_num:
    IDENTIFICADOR '=' expr { adiciona_variavel($1, 0); inicializa_variavel(encontra_variavel_no_escopo_atual($1), $3, NULL); }
    | IDENTIFICADOR { adiciona_variavel($1, 0); }
    | lista_declaracao_num ',' IDENTIFICADOR '=' expr { adiciona_variavel($3, 0); inicializa_variavel(encontra_variavel_no_escopo_atual($3), $5, NULL); }
    | lista_declaracao_num ',' IDENTIFICADOR { adiciona_variavel($3, 0); }
    ;

lista_declaracao_cadeia:
    IDENTIFICADOR '=' exprcadeia { adiciona_variavel($1, 1); inicializa_variavel(encontra_variavel_no_escopo_atual($1), 0, $3); }
    | IDENTIFICADOR { adiciona_variavel($1, 1); }
    | lista_declaracao_cadeia ',' IDENTIFICADOR '=' exprcadeia { adiciona_variavel($3, 1); inicializa_variavel(encontra_variavel_no_escopo_atual($3), 0, $5); }
    | lista_declaracao_cadeia ',' IDENTIFICADOR { adiciona_variavel($3, 1); }
    ;

expr:
    expr '+' expr { 
        $$ = $1 + $3; 
    }
    | NUMERO { $$ = $1; }
    | IDENTIFICADOR {
        variavel* var = encontra_variavel($1);
        if (var) {
            if (var->tipo == 0) $$ = var->valor_num;
            else {
                printf("Erro: tipos não compatíveis\n");
                $$ = 0;
            }
        } else {
            printf("Erro: Variável não declarada\n");
            $$ = 0;
        }
    }
    ;
	
exprcadeia:
    exprcadeia '+' exprcadeia { 
        char* concat_str = (char*)malloc(strlen($1) + strlen($3) + 1);
        strcpy(concat_str, $1);
        strcat(concat_str, $3);
        free($1);
        free($3);
        $$ = concat_str;
    }
    | CADEIA { $$ = strdup($1); }
    | IDENTIFICADOR {
        variavel* var = encontra_variavel($1);
        if (var) {
            if (var->tipo == 1) $$ = strdup(var->valor_str);
            else {
                printf("Erro: tipos não compatíveis");
                $$ = strdup("");
            }
        } else {
            printf("Erro: Variável não declarada\n");
            $$ = strdup("");
        }
    }
    ;

%%

void empilha_escopo() {
    escopo* novo_escopo = (escopo*)malloc(sizeof(escopo));
    novo_escopo->variaveis = NULL;
    novo_escopo->prox = escopo_atual;
    escopo_atual = novo_escopo;
}

void desempilha_escopo() {
    escopo* old_escopo = escopo_atual;
    escopo_atual = escopo_atual->prox;
    variavel* var = old_escopo->variaveis;
    while (var) {
        variavel* prox = var->prox;
        if (var->tipo == 1) free(var->valor_str);
        free(var->nome);
        free(var);
        var = prox;
    }
    free(old_escopo);
}

variavel* encontra_variavel(char* nome) {
    escopo* e = escopo_atual;
    while (e) {
        variavel* var = e->variaveis;
        while (var) {
            if (strcmp(var->nome, nome) == 0) return var;
            var = var->prox;
        }
        e = e->prox;
    }
    return NULL;
}

variavel* encontra_variavel_no_escopo_atual(char* nome) {
    variavel* var = escopo_atual->variaveis;
    while (var) {
        if (strcmp(var->nome, nome) == 0) return var;
        var = var->prox;
    }
    return NULL;
}

void adiciona_variavel(char* nome, int type) {
    if (encontra_variavel_no_escopo_atual(nome)) {
        printf("Erro: Variável já declarada %s\n", nome);
        return;
    }
    variavel* var = (variavel*)malloc(sizeof(variavel));
    var->nome = strdup(nome);
    var->tipo = type;
    if (type == 0) var->valor_num = 0;
    else var->valor_str = strdup("");
    var->prox = escopo_atual->variaveis;
    escopo_atual->variaveis = var;
}

void inicializa_variavel(variavel* var, double valor_num, char* valor_str) {
    if (var->tipo == 0) var->valor_num = valor_num;
    else if (var->tipo == 1) var->valor_str = strdup(valor_str);
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    empilha_escopo(); // Adiciona um escopo global
    return yyparse();
}
