####################################################################################################################################
#
#	Makefile
#
#	This file is an part of Mondo SysUtils.
#
#	Copyright (C) 2020 Mondo Megagames.
# 	Author: Jamie Ramone <sancombru@gmail.com>
#	Date: 5-6-20
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see
# <http://www.gnu.org/licenses/>
#
####################################################################################################################################
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

