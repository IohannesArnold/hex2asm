# stage-1/Makefile
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

all: elfify unhexl

$(BUILD)/unhex:
	$(MAKE) -C ../stage-0

elfify:	$(BUILD)/elfify

$(BUILD)/elfify:	$(BUILD)/unhex elfify.x
	$(BUILD)/unhex elfify.x $(BUILD)/elfify

unhexl:	$(BUILD)/unhexl

$(BUILD)/unhexl:	$(BUILD)/unhex elfify unhexl.ts.x
	$(BUILD)/unhex unhexl.ts.x $(BUILD)/unhexl.ts
	$(BUILD)/elfify $(BUILD)/unhexl.ts $(BUILD)/unhexl
	$(RM) $(BUILD)/unhexl.ts

check:	check-unhexl

check-unhexl:	unhexl elfify unhexl.ts.x
	$(BUILD)/unhexl unhexl.ts.x $(BUILD)/unhexl_2.ts
	$(BUILD)/elfify $(BUILD)/unhexl_2.ts $(BUILD)/unhexl_2
	$(CMP) $(BUILD)/unhexl $(BUILD)/unhexl_2
	$(RM) $(BUILD)/unhexl_2.ts $(BUILD)/unhexl_2

clean:
	$(RM) -f $(BUILD)/unhexl $(BUILD)/elfify $(BUILD)/unhexl.ts 

