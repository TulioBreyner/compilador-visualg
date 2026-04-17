
 /* %define parse.error custom // tratamento de erro mais detalhado, com mensagens próprias */
%define parse.error verbose    // tratamento de erro mais detalhado
%locations                     // suporte regional

%{
    #define _USE_MATH_DEFINES

    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <float.h>
    #include <string.h>

    #include "ast.h"       // definição da estrutura da árvore abstrata
    #include "symtab.h"    // definições da tabela de símbolos
    #include "mathfuncs.h" // tabela de funções e fatorial

    void show_help();

    /* Declarações de funções necessárias */
    void yyerror(const char *s);
    int yylex(void);
%}

/* ================================================================ */
/* Redefinição do repositório de atributos de tokens                */
/* ================================================================ */
%union {
    double    dval;    /* para atributos de números reais              */
    char     *sval;    /* para atributos de strings e identificadores  */
    int       ival;    /* para atributos de inteiros                   */
    ast_node *node;    /* o parser vai retornar um nó da AST           */
}

/* ================================================================ */
/* Associação de tipos para os símbolos não terminais da gramática  */
/* ================================================================ */
%type <node> exp fator termo potencia posfixo

/* ================================================================ */
/* TOKENS — Literais com atributo                                   */
/* ================================================================ */
%token <dval> NUM            /* número (inteiro ou real)              */
%token <sval> ID             /* identificador (variável ou nome)      */
%token <sval> FUNC_MAT       /* função matemática predefinida         */
%token <sval> FUNC_STR       /* função de string predefinida          */
%token <sval> STRING_LITERAL /* literal de cadeia de caracteres       */

/* ================================================================ */
/* TOKENS — Estrutura do programa                                   */
/* ================================================================ */
%token ALGORITMO             /* início do programa                    */
%token INICIO                /* início do bloco de comandos           */
%token FIMALGORITMO          /* fim do programa                       */
%token VAR                   /* seção de declaração de variáveis      */

/* ================================================================ */
/* TOKENS — Tipos de dados                                          */
/* ================================================================ */
%token INTEIRO               /* tipo inteiro                          */
%token REAL                  /* tipo real / numérico                  */
%token CARACTERE             /* tipo caracter / caractere / literal   */
%token LOGICO                /* tipo lógico (booleano)                */
%token VETOR                 /* tipo vetor (array)                    */

/* ================================================================ */
/* TOKENS — Estruturas condicionais                                 */
/* ================================================================ */
%token SE                    /* se                                    */
%token ENTAO                 /* entao                                 */
%token SENAO                 /* senao                                 */
%token FIMSE                 /* fimse                                 */

%token ESCOLHA               /* escolha (switch)                      */
%token CASO                  /* caso                                  */
%token OUTROCASO             /* outrocaso (default)                   */
%token FIMESCOLHA            /* fimescolha                            */

/* ================================================================ */
/* TOKENS — Estruturas de repetição                                 */
/* ================================================================ */
%token PARA                  /* para (for)                            */
%token DE                    /* de (from)                             */
%token ATE                   /* ate (to / until)                      */
%token PASSO                 /* passo (step)                          */
%token FACA                  /* faca (do)                             */
%token FIMPARA               /* fimpara                               */

%token ENQUANTO              /* enquanto (while)                      */
%token FIMENQUANTO           /* fimenquanto                           */

%token REPITA                /* repita (repeat)                       */
%token FIMREPITA             /* fimrepita                             */

%token INTERROMPA            /* interrompa (break)                    */

/* ================================================================ */
/* TOKENS — Subprogramas                                            */
/* ================================================================ */
%token PROCEDIMENTO          /* procedimento                          */
%token FIMPROCEDIMENTO       /* fimprocedimento                       */
%token FUNCAO                /* funcao                                */
%token FIMFUNCAO             /* fimfuncao                             */
%token RETORNE               /* retorne                               */

/* ================================================================ */
/* TOKENS — Entrada e Saída                                         */
/* ================================================================ */
%token LEIA                  /* leia (read)                           */
%token ESCREVA               /* escreva (write)                       */
%token ESCREVAL              /* escreval (writeln)                    */

/* ================================================================ */
/* TOKENS — Operadores lógicos (palavras-chave)                     */
/* ================================================================ */
%token E                     /* e  (and)                              */
%token OU                    /* ou (or)                               */
%token NAO                   /* nao (not)                             */
%token XOU                   /* xou (xor)                             */

/* ================================================================ */
/* TOKENS — Literais booleanos                                      */
/* ================================================================ */
%token VERDADEIRO            /* verdadeiro (true)                     */
%token FALSO                 /* falso (false)                         */

/* ================================================================ */
/* TOKENS — Diretivas e comandos especiais do VisuAlg               */
/* ================================================================ */
%token ALEATORIO             /* aleatorio (geração aleatória)         */
%token ARQUIVO               /* arquivo (leitura de arquivo)          */
%token CRONOMETRO            /* cronometro (medição de tempo)         */
%token DEBUG                 /* debug (modo depuração)                */
%token ECO                   /* eco (exibir entrada do usuário)       */
%token MENSAGEM              /* mensagem (caixa de mensagem)          */
%token PAUSA                 /* pausa (aguarda tecla)                 */
%token TIMER                 /* timer (temporizador)                  */
%token LIMPATELA             /* limpatela (limpar console)            */

/* ================================================================ */
/* TOKENS — Constantes predefinidas                                 */
/* ================================================================ */
%token PI                    /* constante pi                          */

/* ================================================================ */
/* TOKENS — Operadores relacionais (símbolos compostos)             */
/* ================================================================ */
%token ATRIB                 /* <- (atribuição)                       */
%token NEQ                   /* <> (diferente de)                     */
%token GEQ                   /* >= (maior ou igual a)                 */
%token LEQ                   /* <= (menor ou igual a)                 */
%token GT                    /* >  (maior que)                        */
%token LT                    /* <  (menor que)                        */
%token EQ                    /* =  (igual a — comparação)             */

/* ================================================================ */
/* TOKENS — Operadores aritméticos (palavras / símbolos)            */
/* ================================================================ */
%token DIV_INT               /* \  (divisão inteira)                  */
%token MOD                   /* %  (módulo / resto da divisão)        */

/* ================================================================ */
/* TOKENS — Controle de fluxo do interpretador interativo           */
/* ================================================================ */
%token EOL                   /* fim de linha (Enter)                  */
%token VARS                  /* exibição da tabela de símbolos        */
%token SAIR                  /* encerrar interpretador                */
%token HELP                  /* ajuda                                 */

/* ================================================================ */
/* Definição de precedência e associatividade                       */
/* (resolve ambiguidades na gramática de expressões)                */
/* ================================================================ */
%right ATRIB                 /* atribuição <- (direita-associativa)   */
%left  OU XOU                /* menor precedência lógica              */
%left  E                     /* conjunção lógica                      */
%right NAO                   /* negação lógica (unária)               */
%left  EQ NEQ                /* igualdade e diferença                 */
%left  LT LEQ GT GEQ         /* relacionais                           */
%left  '+' '-'               /* adição e subtração                    */
%left  '*' '/' DIV_INT MOD   /* multiplicação e divisão               */
%right '^'                   /* potenciação (direita-associativa)     */
%precedence UMINUS           /* menos unário                          */

/* ================================================================ */
/* Destruidores: libera memória alocada se tokens forem descartados */
/* ================================================================ */
%destructor { free($$); } ID FUNC_MAT FUNC_STR STRING_LITERAL

%% /* ============================================================== */

/* Regra inicial: permite múltiplas expressões separadas por quebra de linha */
calclist: /* vazio */
    | calclist line
    ;

line: EOL      { printf("> "); }

    | SAIR EOL { return 0; }

    | VARS EOL { symtab_print(stdout);
                 printf("> ");
               }
    | HELP EOL { show_help();
                 printf("> ");
               }
    | exp EOL  { double result = ast_eval($1);
                 printf("Resultado = %.10g\n", result);
                 ast_print($1, stdout);
                 ast_free($1);
                 printf("> ");
               }
    | error EOL { yyerror("Linha invalida");
                  yyerrok;
                  printf("> ");
                }
    ;

/* ================================================================ */
/* Regras de derivação para expressões aritméticas                  */
/* ================================================================ */

exp : fator              { $$ = $1; }
    | exp '+' fator      { $$ = ast_binary(AST_ADD, $1, $3); }
    | exp '-' fator      { $$ = ast_binary(AST_SUB, $1, $3); }
    | ID ATRIB exp       { $$ = ast_assign($1, $3); }
    ;

fator : potencia           { $$ = $1; }
    | fator '*' potencia   { $$ = ast_binary(AST_MUL, $1, $3); }
    | fator '/' potencia   { $$ = ast_binary(AST_DIV, $1, $3); }
    ;

potencia : posfixo               { $$ = $1; }
    | posfixo '^' potencia       { $$ = ast_binary(AST_POW, $1, $3); }
    ;

posfixo: termo    { $$ = $1; }
    ;

termo : NUM                    { $$ = ast_num($1); }
    | '(' exp ')'              { $$ = $2; }
    | '-' termo %prec UMINUS   { $$ = ast_unary(AST_NEG, $2); }
    | ID                       { $$ = ast_var($1); }

      /* função matemática com um parâmetro */
    | FUNC_MAT '(' exp ')' {
        ast_node **args = malloc(sizeof(ast_node*));
        if (!args) { fprintf(stderr, "Erro: falta de memoria\n"); exit(1); }
        args[0] = $3;
        $$ = ast_func($1, args, 1);
    }

      /* função matemática com dois parâmetros */
    | FUNC_MAT '(' exp ',' exp ')' {
        ast_node **args = malloc(sizeof(ast_node*) * 2);
        if (!args) { fprintf(stderr, "Erro: falta de memoria\n"); exit(1); }
        args[0] = $3;
        args[1] = $5;
        $$ = ast_func($1, args, 2);
    }
    ;

%% /* ============================================================== */

void show_help() {
    puts("Comandos disponíveis:");
    puts("\tprint");
    puts("\ttabela");
    puts("\tvars    exibe a tabela de símbolos");
    puts("");
    puts("\tajuda");
    puts("\thelp    mostra essa tela");
    puts("");
    puts("\tsair");
    puts("\tquit    encerra a calculadora");
}

/* Função chamada pelo Bison em caso de erro sintático */
void yyerror(const char *s) {
    fprintf(stderr, "Erro sintatico: %s\n", s);
    fflush(stderr);
}

/* Função principal (Ponto de entrada do programa) */
int main(void) {

    setvbuf(stdout, NULL, _IOLBF, 0);  /* buffer por linha          */
    setvbuf(stderr, NULL, _IONBF, 0);  /* sem buffer, para erro     */

    /* carregando constantes predefinidas na tabela de símbolos */
    sym_set("pi", M_PI);
    sym_set("e",  M_E);

    puts("Calculadora Flex/Bison (double + tabela de simbolos)");
    puts("Exemplos:");
    puts("  x <- 2.5");
    puts("  y <- x * 4");
    puts("  y + 1");
    puts("Ctrl+D para sair.");

    printf("> ");
    yyparse();     /* chamada ao parser                               */
    symtab_free(); /* destruição da tabela de símbolos                */

    puts("Calculadora encerrada!");
    return 0;
}