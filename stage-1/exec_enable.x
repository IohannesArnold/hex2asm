# Copyright (C) 2016 Jeremiah Orians
# This file is part of stage0.
#
# stage0 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# stage0 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with stage0.  If not, see <http://www.gnu.org/licenses/>.

# Exec_enable program
# Takes only single arg
# Shitty to use but essential if you need it

## ELF Header
7F 45 4C 46         ## e_ident[EI_MAG0-3] ELF's magic number
02                  ## e_ident[EI_CLASS] Indicating 64 bit
01                  ## e_ident[EI_DATA] Indicating little endianness
01                  ## e_ident[EI_VERSION] Indicating original elf
00                  ## e_ident[EI_OSABI] Set at 0 because none cares
00                  ## e_ident[EI_ABIVERSION] See above
00 00 00 00 00 00 00 ## e_ident[EI_PAD]
02 00               ## e_type Indicating Executable
3E 00               ## e_machine Indicating AMD64
01 00 00 00         ## e_version Indicating original elf
78 00 40 00 00 00 00 00 ## e_entry Address of the entry point
40 00 00 00 00 00 00 00 ## e_phoff Address of program header table
F0 01 00 00 00 00 00 00 ## e_shoff Address of section header table
00 00 00 00         ## e_flags
40 00               ## e_ehsize Indicating our 64 Byte header
38 00               ## e_phentsize size of a program header table
01 00               ## e_phnum number of entries in program table
00 00               ## e_shentsize size of a section header table
00 00               ## e_shnum number of entries in section table
00 00               ## e_shstrndx index of the section names

## Program Header
01 00 00 00         ## p_type
05 00 00 00         ## Flags
00 00 00 00 00 00 00 00 ## p_offset
00 00 40 00 00 00 00 00 ## p_vaddr
00 00 00 00 00 00 00 00 ## Undefined
B1 00 00 00 00 00 00 00 ## p_filesz
B1 00 00 00 00 00 00 00 ## p_memsz
00 00 20 00 00 00 00 00 ## Required alignment

## Start
58                   # pop    %rax
5f                   # pop    %rdi
5f                   # pop    %rdi
48 83 f8 02          # cmp    $0x2,%rax
75 20                # jne    4000a1 <Bail>
48 c7 c6 ed 01 00 00 # mov    $0x1ed,%rsi
48 c7 c0 5a 00 00 00 # mov    $0x5a,%rax
0f 05                # syscall

## Done
48 c7 c7 00 00 00 00 # mov    $0x0,%rdi
48 c7 c0 3c 00 00 00 # mov    $0x3c,%rax
0f 05                # syscall

## Bail
48 c7 c7 01 00 00 00 # mov    $0x1,%rdi
48 c7 c0 3c 00 00 00 # mov    $0x3c,%rax
0f 05                # syscall
