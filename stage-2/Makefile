# stage-2/Makefile
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

all:	as2

$(BUILD)/unhexl $(BUILD)/elfify:
	$(MAKE) -C ../stage-1

as2:	$(BUILD)/as2

$(BUILD)/as2:	as.ts.xl $(BUILD)/unhexl $(BUILD)/elfify
	$(BUILD)/unhexl as.ts.xl $(BUILD)/as.ts
	$(BUILD)/elfify $(BUILD)/as.ts $(BUILD)/as2
	$(RM) $(BUILD)/as.ts

check:	check-as

check-as:	$(BUILD)/as2 tests/as.s
	$(BUILD)/as2 tests/as.s > $(BUILD)/as_1.ts
	$(BUILD)/elfify $(BUILD)/as_1.ts $(BUILD)/as_1
	$(BUILD)/as_1 tests/as.s > $(BUILD)/as_2.ts
	$(CMP) $(BUILD)/as_1.ts $(BUILD)/as_2.ts
	$(RM) $(BUILD)/as_1.ts $(BUILD)/as_2.ts $(BUILD)/as_1

clean:
	$(RM) -f $(BUILD)/as2 $(BUILD)/as.ts

