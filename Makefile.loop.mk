# Makefile
.SUFFIXES:

all: build

CC=echo

Makefile: ;

SOURCES = $(wildcard linux/feature/vs*.sh)
$(info ${SOURCES})
%.o: %.sh
	$(CC) -c $< -o $@

%.out: %.o
	$(CC) $^ -o $@

$(info ${SOURCES:.sh=.out})

.PHONY: build
build: $(SOURCES:.sh=.out)

.PHONY: clean
clean:
	rm -f main.o main.out