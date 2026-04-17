%{
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"              /* ast_node precisa ser conhecido antes do tab.h */
    #include "tradutor.tab.h" /* Arquivo de cabeçalho gerado pelo Bison com os tokens */

    static char *xstrdup(const char *s);
%}

/* Evita a necessidade de linkar com a biblioteca do Flex (-lfl) */
%option noyywrap
%option noinput
%option nounput
%option yylineno
/* case-insensitive: VisuAlg is case-insensitive */
%option case-insensitive

%%

 /* ================================================================ */
 /* Delimitacoes estruturais do programa                             */
 /* ================================================================ */
"algoritmo"             { return ALGORITMO; }
"inicio"                { return INICIO; }
"fimalgoritmo"          { return FIMALGORITMO; }

 /* Declaracao de variaveis */
"var"|"declare"         { return VAR; }

 /* ================================================================ */
 /* Tipos de dados                                                   */
 /* ================================================================ */
"inteiro"|"int"                         { return INTEIRO; }
"real"|"numerico"                       { return REAL; }
"caracter"|"caractere"|"literal"        { return CARACTERE; }
"logico"                                { return LOGICO; }
"vetor"                                 { return VETOR; }

 /* ================================================================ */
 /* Estruturas condicionais                                          */
 /* ================================================================ */
"se"                    { return SE; }
"entao"                 { return ENTAO; }
"senao"                 { return SENAO; }
"fimse"                 { return FIMSE; }

"escolha"               { return ESCOLHA; }
"caso"                  { return CASO; }
"outrocaso"             { return OUTROCASO; }
"fimescolha"            { return FIMESCOLHA; }

 /* ================================================================ */
 /* Estruturas de repeticao                                          */
 /* ================================================================ */
"para"                  { return PARA; }
"de"                    { return DE; }
"ate"                   { return ATE; }
"passo"                 { return PASSO; }
"faca"                  { return FACA; }
"fimpara"               { return FIMPARA; }

"enquanto"              { return ENQUANTO; }
"fimenquanto"           { return FIMENQUANTO; }

"repita"                { return REPITA; }
"fimrepita"             { return FIMREPITA; }

"interrompa"            { return INTERROMPA; }

 /* ================================================================ */
 /* Subprogramas (procedimentos e funcoes)                           */
 /* ================================================================ */
"procedimento"          { return PROCEDIMENTO; }
"fimprocedimento"       { return FIMPROCEDIMENTO; }
"funcao"                { return FUNCAO; }
"fimfuncao"             { return FIMFUNCAO; }
"retorne"               { return RETORNE; }

 /* ================================================================ */
 /* Comandos de entrada e saida                                      */
 /* ================================================================ */
"leia"                  { return LEIA; }
"escreva"               { return ESCREVA; }
"escreval"              { return ESCREVAL; }

 /* ================================================================ */
 /* Operadores logicos (palavras-chave)                              */
 /* ================================================================ */
"e"                     { return E; }
"ou"                    { return OU; }
"nao"                   { return NAO; }
"xou"                   { return XOU; }

 /* ================================================================ */
 /* Literais booleanos                                               */
 /* ================================================================ */
"verdadeiro"            { return VERDADEIRO; }
"falso"                 { return FALSO; }

 /* ================================================================ */
 /* Comandos/diretivas especiais do VisuAlg                         */
 /* ================================================================ */
"aleatorio"             { return ALEATORIO; }
"arquivo"               { return ARQUIVO; }
"cronometro"            { return CRONOMETRO; }
"debug"                 { return DEBUG; }
"eco"                   { return ECO; }
"mensagem"              { return MENSAGEM; }
"pausa"                 { return PAUSA; }
"timer"                 { return TIMER; }
"limpatela"             { return LIMPATELA; }

 /* ================================================================ */
 /* Funcoes matematicas predefinidas                                 */
 /* ================================================================ */
"abs"|"arccos"|"arcsen"|"arctan"|"cos"|"cotan"|"exp"|"grauprad"|"log"|"logn"|"quad"|"radpgrau"|"raizq"|"rand"|"randi"|"sen"|"tan" {
                yylval.sval = xstrdup(yytext);
                return FUNC_MAT;
            }

 /* ================================================================ */
 /* Funcoes de string predefinidas                                   */
 /* ================================================================ */
"asc"|"compr"|"copia"|"maiusc"|"minusc"|"numpcarac"|"pos" {
                yylval.sval = xstrdup(yytext);
                return FUNC_STR;
            }

 /* ================================================================ */
 /* Constante predefinida                                            */
 /* ================================================================ */
"pi"            { return PI; }

 /* ================================================================ */
 /* Comandos auxiliares do interpretador (modo interativo)          */
 /* ================================================================ */
"vars"|"tabela"|"print"     { return VARS; }
"sair"|"quit"               { return SAIR; }
"ajuda"|"help"              { return HELP; }

 /* ================================================================ */
 /* Literais numericos: inteiro, decimal e notacao cientifica       */
 /* ================================================================ */
([0-9]+(\.[0-9]*)?|\.[0-9]+)([eE][+-]?[0-9]+)? {
                yylval.dval = strtod(yytext, NULL);
                return NUM;
            }

 /* ================================================================ */
 /* Literais de cadeia de caracteres (strings entre aspas duplas)   */
 /* ================================================================ */
\"([^\"\n])*\"  {
                yylval.sval = xstrdup(yytext);
                return STRING_LITERAL;
            }

 /* ================================================================ */
 /* Identificadores: variaveis e nomes de subprogramas              */
 /* ================================================================ */
[a-zA-Z_][a-zA-Z0-9_]*  {
                yylval.sval = xstrdup(yytext);
                return ID;
            }

 /* ================================================================ */
 /* Espacos em branco e comentarios                                  */
 /* ================================================================ */
[ \t\r]+        { /* ignora espacos, tabulacoes e retorno de carro */ }

"//"[^\n]*      { /* ignora comentarios de linha (estilo VisuAlg)  */ }

 /* ================================================================ */
 /* Operadores e pontuacao                                           */
 /* ================================================================ */
"<-"            { return ATRIB; }   /* operador de atribuicao do VisuAlg */
"<>"            { return NEQ; }     /* diferente de                      */
">="            { return GEQ; }     /* maior ou igual a                  */
"<="            { return LEQ; }     /* menor ou igual a                  */
">"             { return GT; }      /* maior que                         */
"<"             { return LT; }      /* menor que                         */
"="             { return EQ; }      /* igual a (comparacao)              */

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"\\"            { return DIV_INT; } /* divisao inteira                   */
"%"             { return MOD; }     /* modulo / resto da divisao         */
"^"             { return '^'; }     /* potenciacao                       */

"("             { return '('; }
")"             { return ')'; }
"["             { return '['; }
"]"             { return ']'; }
","             { return ','; }
":"             { return ':'; }
"."             { return '.'; }

\n              { return EOL; }     /* fim de linha                      */

 /* Qualquer outro caractere: deixa o parser decidir */
.               { return yytext[0]; }

%%

/* strdup portatil */
static char *xstrdup(const char *s) {
    size_t n = strlen(s) + 1;
    char *p = malloc(n);
    if (!p) {
        fprintf(stderr, "Erro fatal: sem memoria\n");
        exit(1);
    }
    memcpy(p, s, n);
    return p;
}
