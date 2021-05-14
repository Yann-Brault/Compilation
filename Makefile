.DELETE_ON_ERROR:

CC = gcc
CFLAGS1 = -g
CFLAGS2 = -lfl
CFLAGS3 = -o
C_FILE = switch.c
DOT_FILE = graph.dot
DOT_OUT_PDF = graph.pdf
DOT_FLAGS = -Tpdf $(DOT_FILE) -o $(DOT_OUT_PDF)
FL = flex
YCC = yacc

TARGET = compilator_run

dot: run
	dot $(DOT_FLAGS)

run: gcc
	./$(TARGET) < ./$(C_FILE)

gcc: flex
	$(CC) $(CFLAGS1) lex.yy.c y.tab.c struct.c $(CFLAGS2) $(CFLAGS3) $(TARGET)

flex: yacc
	$(FL) ANSI-C.l

yacc:
	$(YCC) -d miniC.y

.PHONY: clean
clean:
	rm -f $(TARGET) lex.yy.c y.tab.h y.tab.c