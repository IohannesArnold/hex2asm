# stage-2/Makefile

# Copyright (C) 2010, 2011 Richard Smith <richard@ex-parrot.com>
# All rights reserved.

SHELL = /bin/sh
PATH  = .

CHMOD = ../bin/exec_enable
RM    = /bin/rm
CMP   = /usr/bin/cmp
LN_S  = /bin/ln -sf
MAKE  = /usr/bin/make

all:	as

init as:	unhexl elfify

unhexl elfify:
	$(MAKE) -C ../stage-1

as:	as.ts.xl
	../bin/unhexl < as.ts.xl > ../bin/as.ts
	../bin/elfify ../bin/as.ts > ../bin/as2
	$(CHMOD) ../bin/as2
	$(RM) ../bin/as.ts

check:	check-as

check-as:	as as.s
	../bin/as as.s > ../bin/as_1.ts
	../bin/elfify ../bin/as_1.ts > ../bin/as_1
	$(CHMOD) ../bin/as_1
	../bin/as_1 as.s > ../bin/as_2.ts
	$(CMP) ../bin/as_1.ts ../bin/as_2.ts
	$(RM) ../bin/as_1.ts ../bin/as_2.ts ../bin/as_1

clean:
	$(RM) -f ../bin/as2 ../bin/as.ts

