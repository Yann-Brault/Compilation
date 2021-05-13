.DELETE_ON_ERROR:

CC = gcc
CFLAGS1 = -g
CFLAGS2 = -lfl
CFLAGS3 = -o
C_FILE1 = exempleminiC.c
C_FILE2 = switch.c
DOT_FILE = graph.dot
DOT_OUT_PDF = graph.pdf
DOT_FLAGS = -Tpdf $(DOT_FILE) -o $(DOT_OUT_PDF)
FL = flex
YCC = yacc

TARGET = compilator_run

dot: run
	dot $(DOT_FLAGS)

run: gcc
	./$(TARGET) < ./Tests/$(C_FILE2)

gcc: flex
	$(CC) $(CFLAGS1) lex.yy.c y.tab.c struct.c $(CFLAGS2) $(CFLAGS3) $(TARGET)

flex: yacc
	$(FL) ANSI-C.l

yacc:
	$(YCC) -d miniC.y

.PHONY: clean
clean:
	rm $(TARGET)