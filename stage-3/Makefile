# stage-3/Makefile
# Copyright (C) 2009-2019 Richard Smith <richard@ex-parrot.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

include ../config.make
BUILD = ../build

all:	$(BUILD)/bin/as $(BUILD)/bin/ld

# as2   is the assembler from stage 2.
# as2.5 is this stage's assembler (written in asm), assembled by as2.
# as   is the same source, assembled by itself (by as2.5), and therefore similar.
# as_alt is a test assembler produced by as; it should be binary identical to as.

# The same conventions apply to ld, except that there is no ld2.

$(BUILD)/as2 $(BUILD)/elfify:
	$(MAKE) -C ../stage-2

$(BUILD)/as2.5:	as.s $(BUILD)/as2 $(BUILD)/elfify
	$(BUILD)/as2 as.s $(BUILD)/as.ts
	$(BUILD)/elfify $(BUILD)/as.ts $(BUILD)/as2.5
	$(RM) $(BUILD)/as.ts

$(BUILD)/ld2.5:	ld.s $(BUILD)/as2 $(BUILD)/elfify
	$(BUILD)/as2 ld.s $(BUILD)/ld.ts
	$(BUILD)/elfify $(BUILD)/ld.ts $(BUILD)/ld2.5
	$(RM) $(BUILD)/ld.ts

$(BUILD)/bin/as:	as.s $(BUILD)/as2.5 $(BUILD)/ld2.5 
	$(BUILD)/as2.5 as.s
	$(BUILD)/ld2.5 -o $(BUILD)/bin/as as.o
	$(RM) as.o

$(BUILD)/bin/ld:	ld.s $(BUILD)/as2.5 $(BUILD)/ld2.5 
	$(BUILD)/as2.5 ld.s
	$(BUILD)/ld2.5 -o $(BUILD)/bin/ld ld.o
	$(RM) ld.o

check:	check-as check-ld check-sep

check-as:	$(BUILD)/bin/as $(BUILD)/bin/ld as.s
	$(BUILD)/bin/as as.s
	$(BUILD)/bin/ld -o $(BUILD)/bin/as_alt as.o
	$(CMP) $(BUILD)/bin/as $(BUILD)/bin/as_alt
	$(RM) as.o $(BUILD)/bin/as_alt

check-ld:	$(BUILD)/bin/as $(BUILD)/bin/ld ld.s
	$(BUILD)/bin/as ld.s
	$(BUILD)/bin/ld -o $(BUILD)/bin/ld_alt ld.o
	$(CMP) $(BUILD)/bin/ld $(BUILD)/bin/ld_alt
	$(RM) ld.o $(BUILD)/bin/ld_alt

tests/testprog:	$(BUILD)/bin/as $(BUILD)/bin/ld $(addprefix tests/,test1.s test2.s test3.s)
	$(BUILD)/bin/as tests/test2.s
	$(BUILD)/bin/as tests/test3.s
	$(BUILD)/bin/ld -r -o tests/test2+3.o tests/test2.o tests/test3.o
	$(BUILD)/bin/as tests/test1.s tests/test4.o
	$(BUILD)/bin/ld -o tests/testprog tests/test4.o tests/test2+3.o
	$(RM) $(addprefix tests/,test4.o test2.o test3.o test2+3.o)

check-sep:	tests/testprog
	./tests/testprog
	$(RM) tests/testprog


clean:
	$(RM) -f $(addprefix $(BUILD)/,as.ts ld.ts as2.5 ld2.5 as ld)
	$(RM) -f as2.o ld2.o as.o ld.o 
	$(RM) -f $(addprefix tests/,test4.o test2.o test3.o test2+3.o testprog )

