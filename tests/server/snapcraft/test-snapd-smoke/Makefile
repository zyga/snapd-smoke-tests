# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: Canonical Ltd.

.PHONY: all clean install

CPPFLAGS ?=
LDFLAGS ?=
CFLAGS ?=
DESTDIR ?=
TARGET_ARCH ?=
bindir ?= $(exec_prefix)/bin
exec_prefix ?= $(prefix)
prefix ?= /usr/local

CFLAGS += -Wall -Werror

all: hello

hello: main.o
	$(LINK.o) $(OUTPUT_OPTION) $<

install: hello
	install -d $(DESTDIR)$(bindir)
	install -m 755 $< $(DESTDIR)$(bindir)

clean:
	$(RM) main.o hello
