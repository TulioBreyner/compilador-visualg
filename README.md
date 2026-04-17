# Compilador VisualG

Este projeto é um compilador para a linguagem de programação VisualG, desenvolvido como parte da disciplina de Construção de Compiladores.

## Instalação e Uso

### Pré-requisitos

- **GCC**: Compilador C
- **Flex**: Gerador de lexers
- **Bison**: Gerador de parsers

### Compilação

Para compilar o projeto, execute o comando:

```bash
make
```

Isso irá gerar o executável `tradutor` na raiz do projeto.

### Execução

Para executar o tradutor interativamente:

```bash
./tradutor
```

Para traduzir um arquivo `.alg` para C, use o executável gerado:

```bash
./tradutor < nome-do-arquivo.alg
```

### Limpeza

Para remover os arquivos gerados pela compilação:

```bash
make clean
```

## Ferramentas

O projeto inclui o executável oficial do VisualG 2.5 para Windows na pasta `tools/`, permitindo que você valide seus algoritmos na ferramenta original caso necessário.
