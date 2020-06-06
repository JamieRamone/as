BINARY =		runas
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
SOURCES =		$(shell echo *.c)
OBJECTS =		$(SOURCES:.c=.o)
CC =			gcc

.PHONY: all prelude install clean

.SUFFIXES:
.SUFFIXES: .c .h

%: %.c
%: %.h

all: prelude ${BINARY}

.NOTPARALLEL: prelude install clean

prelude:
	@echo "Building as..."

%.o : %.c
	@echo "Compiling $<..."
	@$(CC) ${CFLAGS} -c $^ -o $@

${BINARY}: ${OBJECTS}
	@echo "linking ${BINARY}..."
	@echo "(${OBJECTS})"
	gcc ${CFLAGS} -o ${BINARY} ${OBJECTS}

install: ${BINARY}
	@echo "installing the runas binary..."
	@rm -f /etc/${BINARY}
	@cp -v ${BINARY} /etc

clean:
	@echo "Cleaning up..."
	@rm -f ${BINARY} ${OBJECTS}

