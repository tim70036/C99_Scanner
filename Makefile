LEX = flex
C = gcc
SCANNER = scanner.l
FILE = lex.yy.c
OUT = scanner
LIB = -lfl

# Default Target
build:
	$(LEX) $(SCANNER)
	$(C) -o $(OUT) $(FILE) $(LIB)

clean:
	rm -f $(FILE)
	rm -f $(OUT)
