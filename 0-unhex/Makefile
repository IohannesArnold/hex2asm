# stage-0/Makefile
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
BUILD = ../$(BUILD_DIR)

all:	$(BUILD)/unhex

unhex:	$(BUILD)/unhex

$(BUILD)/unhex:	unhex.x
	for x in `$(SED) '/^#/d;s/#.*//;s/ *//' unhex.x`; do $(PRINTF) \\x$$x; done > $@ 
	$(CHMOD) +x $@

check:	check-unhex

check-unhex: $(BUILD)/unhex
	$(BUILD)/unhex ./unhex.x $(BUILD)/unhex2
	$(CMP) $(BUILD)/unhex $(BUILD)/unhex2
	$(RM) $(BUILD)/unhex2

clean:	
	$(RM) -f $(BUILD)/unhex $(BUILD)/unhex2
