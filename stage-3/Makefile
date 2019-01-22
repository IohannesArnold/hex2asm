# stage-3/Makefile

# Copyright (C) 2011, 2012, 2013 Richard Smith <richard@ex-parrot.com>
# All rights reserved.

SHELL = /bin/sh
PATH  = .

CHMOD = ../bin/exec_enable
RM    = /bin/rm
CMP   = /usr/bin/cmp
LN_S  = /bin/ln -sf
MAKE  = /usr/bin/make

all:	as ld

init as ld:	../bin/as2 ../bin/elfify

# as2   is the assemlber symlinked from stage 2.
# as2.5 is this stage's assembler (written in asm), assembled by as0.
# as3   is the same source, assembled by itself (by as1), and therefore similar.
# as3_2 is a test assembler produced by as; it should be binary identical to as.

# The same conventions apply to ld, except that there is no ld2.5.

../bin/as2 ../bin/elfify:
	$(MAKE) -C ../stage-2

as2.5:	as.s
	../bin/as2 as.s > ../bin/as.ts
	../bin/elfify ../bin/as.ts > ../bin/as2.5
	$(CHMOD) ../bin/as2.5
	$(RM) ../bin/as.ts

ld2.5:	ld.s
	../bin/as2 ld.s > ../bin/ld.ts
	../bin/elfify ../bin/ld.ts > ../bin/ld2.5
	$(CHMOD) ../bin/ld2.5
	$(RM) ../bin/ld.ts

check:	check-as check-ld check-sep

as:	as2.5 ld2.5 as.s
	../bin/as2.5 as.s
	../bin/ld2.5 -o ../bin/as3 as.o
	$(RM) as.o

ld:	as2.5 ld2.5 ld.s
	../bin/as2.5 ld.s
	../bin/ld2.5 -o ../bin/ld3 ld.o
	$(RM) ld.o

check-as:	as ld as.s
	../bin/as3 as.s
	../bin/ld3 -o ../bin/as3_2 as.o
	$(CMP) ../bin/as3 ../bin/as3_2
	$(RM) as.o ../bin/as3_2

check-ld:	as ld ld.s
	../bin/as3 ld.s
	../bin/ld3 -o ../bin/ld3_2 ld.o
	$(CMP) ../bin/ld3 ../bin/ld3_2
	$(RM) ld.o ../bin/ld3_2

testprog:	as ld test1.s test2.s test3.s
	../bin/as3 test2.s
	../bin/as3 test3.s
	../bin/ld3 -r -o test2+3.o test2.o test3.o
	../bin/as3 test1.s
	../bin/ld3 -o testprog test1.o test2+3.o
	$(RM) test1.o test2.o test3.o test2+3.o

check-sep:	testprog
	testprog
	$(RM) testprog


clean:
	$(RM) -f as.ts ld.ts as.o ld.o as1 ld1
	$(RM) -f as2.o ld2.o ld as2 ld2 as ld
	$(RM) -f test1.o test2.o test3.o test2+3.o testprog

