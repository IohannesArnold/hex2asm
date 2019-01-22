# stage-1/Makefile

# Copyright (C) 2009, 2011 Richard Smith <richard@ex-parrot.com>
# All rights reserved.

SHELL = /bin/sh
PATH  = .

RM    = /bin/rm
CMP   = /usr/bin/cmp
MAKE  = /usr/bin/make

all:	unhexl elfify 

init unhexl elfify: unhex

unhex:
	$(MAKE) -C ../stage-0

elfify:	unhex elfify.x
	../bin/unhex elfify.x ../bin/elfify

exec_enable: unhex exec_enable.x
	../bin/unhex exec_enable.x ../bin/exec_enable

unhexl:	unhex elfify exec_enable unhexl.ts.x
	../bin/unhex unhexl.ts.x ../bin/unhexl.ts
	../bin/elfify ../bin/unhexl.ts > ../bin/unhexl
	../bin/exec_enable ../bin/unhexl
	$(RM) ../bin/unhexl.ts

check:	check-unhexl

check-unhexl:	unhexl elfify unhexl.ts.xl
	../bin/unhexl < unhexl.ts.xl > ../bin/unhexl_1.ts
	../bin/elfify ../bin/unhexl_1.ts > ../bin/unhexl_1
	../bin/exec_enable ../bin/unhexl_1
	../bin/unhexl_1 < unhexl.ts.xl > ../bin/unhexl_2.ts
	$(CMP) ../bin/unhexl_1.ts ../bin/unhexl_2.ts
	../bin/elfify ../bin/unhexl_2.ts > ../bin/unhexl_2
	$(CMP) ../bin/unhexl_1 ../bin/unhexl_2
	$(RM) ../bin/unhexl_1.ts ../bin/unhexl_2.ts ../bin/unhexl_1 ../bin/unhexl_2

clean:
	$(RM) -f ../bin/unhexl ../bin/elfify ../bin/unhexl.ts 

