CC = gcc
CFLAGS = -Wall -g -Iinclude -Isrc
LEX = flex

# Tenta encontrar o bison do Homebrew, se não existir usa o padrão do sistema
BISON_BREW = /opt/homebrew/opt/bison/bin/bison
YACC = $(shell if [ -f $(BISON_BREW) ]; then echo $(BISON_BREW); else echo bison; fi)

# Diretórios
SRC_DIR = src
BIN_DIR = .
INC_DIR = include

# Nome do executável
TARGET = $(BIN_DIR)/tradutor

# Arquivos fonte
LEX_SRC = $(SRC_DIR)/tradutor.l
YACC_SRC = $(SRC_DIR)/tradutor.y
EXTRA_SRC = $(SRC_DIR)/ast.c $(SRC_DIR)/symtab.c $(SRC_DIR)/mathfuncs.c

# Arquivos gerados
LEX_OUT = $(SRC_DIR)/lex.yy.c
YACC_C = $(SRC_DIR)/tradutor.tab.c
YACC_H = $(SRC_DIR)/tradutor.tab.h

# Alvo principal
all: $(TARGET)

$(TARGET): $(LEX_OUT) $(YACC_C) $(EXTRA_SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEX_OUT) $(YACC_C) $(EXTRA_SRC) -lm

$(LEX_OUT): $(LEX_SRC) $(YACC_H)
	$(LEX) -o $(LEX_OUT) $(LEX_SRC)

$(YACC_C) $(YACC_H): $(YACC_SRC)
	$(YACC) -d -o $(YACC_C) $(YACC_SRC)

clean:
	rm -f $(TARGET) $(LEX_OUT) $(YACC_C) $(YACC_H)

.PHONY: all clean
