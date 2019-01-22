# stage-0/Makefile

# Copyright (C) 2009, 2011, 2015 Richard Smith <richard@ex-parrot.com>
# All rights reserved.

SHELL = /bin/sh
PATH  = .

CHMOD = /bin/chmod
RM    = /bin/rm
CMP   = /usr/bin/cmp
MAKE  = /usr/bin/make
CAT   = /bin/cat
PRINTF= /usr/bin/printf

all:	unhex


unhex:	unhex.x
	../bin/unhex unhex.x ../bin/unhex
check:	check-unhex

check-unhex:
	../bin/unhex unhex.x ../bin/unhex2
	$(CMP) ../bin/unhex ../bin/unhex2

