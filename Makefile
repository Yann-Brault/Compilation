.DELETE_ON_ERROR:

VAR=
CC = gcc
CFLAGS1 = -g
CFLAGS2 = -lfl
CFLAGS3 = -o
DOT_FILE = graph.dot
DOT_OUT_PDF = graph.pdf
DOT_FLAGS = -Tpdf $(DOT_FILE) -o $(DOT_OUT_PDF)
FL = flex
YCC = yacc

TARGET = compilator_run

dot: run
	dot $(DOT_FLAGS)
	rm check.txt

run: check.txt
	./$(TARGET) < ./Tests/$(VAR)

check.txt: gcc
ifeq ($(VAR),)
	$(error "Ce makefile peut directement générer le dot file (et le pdf lié), pour faire cela, vous devez utiliser la syntaxe make VAR=nom_fichier_cible.c Sachant que VAR n'a pas était défini seulement le compilateur était créé sous le nom compilator_run.")
else
	touch check.txt
endif

gcc: flex
	$(CC) $(CFLAGS1) lex.yy.c y.tab.c struct.c $(CFLAGS2) $(CFLAGS3) $(TARGET)

flex: yacc
	$(FL) ANSI-C.l

yacc:
	$(YCC) -d miniC.y
	
.PHONY: clean
clean:
	rm $(TARGET)