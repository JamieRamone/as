BINARY =		as
CFLAGS =		-fno-builtin-log
CFLAGS +=		-fzero-initialized-in-bss
CFLAGS +=		-fomit-frame-pointer
CFLAGS +=		-faggressive-loop-optimizations
CFLAGS +=		-fcrossjumping
CFLAGS +=		-fdce
CFLAGS +=		-fdse
CFLAGS +=		-fif-conversion
CFLAGS +=		-fif-conversion2
CFLAGS +=		-Os
CFLAGS +=		-s
CFLAGS +=		-Wall
CFLAGS +=		-fno-inline
CFLAGS +=		-Werror
#GENERATED_SOURCES =	confparser.c confscanner.c
#GENERATED_OBJECTS =	confparser.o confscanner.o
SOURCES =		$(shell echo *.c)
OBJECTS =		$(SOURCES:.c=.o)
CC =			gcc
LEX =			flex
YACC =			bison

.PHONY: all prelude install clean ${GENERATED_SOURCES}

.SUFFIXES:
.SUFFIXES: .c .h .y .l

%: %.c
%: %.h
%: %.y
%: %.l

all: prelude ${GENERATED_SOURCES} ${BINARY}

.NOTPARALLEL: prelude install clean

prelude:
	@echo "Building as..."

%.o : %.c
	@echo "Compiling $<..."
	@$(CC) ${CFLAGS} -c $^ -o $@

#confscanner.c: confscanner.l
#	@echo "Pregenerating $<..."
#	@$(LEX) -X -Ca -Cem -B -o confscanner.c $<

#confparser.c: confparser.y
#	@echo "Pregenerating $<..."
#	@$(YACC) -y -d -t -o confparser.c $<

${BINARY}: ${GENERATED_OBJECTS} ${OBJECTS}
	@echo "linking ${BINARY}..."
	@echo "(${OBJECTS})"
	gcc ${CFLAGS} -o ${BINARY} ${OBJECTS}

install: ${BINARY}
	@echo "installing the as binary..."
	@rm -f /etc/${BINARY}
	@cp -v ${BINARY} /etc

clean:
	@echo "Cleaning up..."
	@rm -f ${BINARY} ${OBJECTS} ${GENERATED_SOURCES} ${GENERATED_OBJECTS} confparser.h
