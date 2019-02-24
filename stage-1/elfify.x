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
# along with elfify.  If not, see <http://www.gnu.org/licenses/>.

# This file should produce a binary with the sha256 sum of:
# a64f62f69331c6b19ae3167f518500a996f804917086be5a12c3e1066091eaf5

## ELF Header
7F 45 4C 46                    # e_ident[EI_MAG] ELF's magic number

01                             # e_ident[EI_CLASS] Indicating 32 bit
01                             # e_ident[EI_DATA] Indicating little endianness
01                             # e_ident[EI_VERSION] Indicating original elf

00                             # e_ident[EI_OSABI] Set at 0 because none cares
00                             # e_ident[EI_ABIVERSION] See above

00 00 00 00 00 00 00           # e_ident[EI_PAD]

02 00                          # e_type Indicating Executable
03 00                          # e_machine Indicating x86
01 00 00 00                    # e_version Indicating original elf

0F 82 04 08                    # e_entry Address of the entry point
34 00 00 00                    # e_phoff Address of program header table
54 00 00 00                    # e_shoff Address of section header table

00 00 00 00                    # e_flags

34 00                          # e_ehsize Indicating our 52 Byte header

20 00                          # e_phentsize size of a program header table
01 00                          # e_phnum number of entries in program table

28 00                          # e_shentsize size of a section header table
03 00                          # e_shnum number of entries in section table

02 00                          # e_shstrndx index of the section names

## Program Header
01 00 00 00                    # p_type: PT_LOAD = 1
00 00 00 00                    # p_offset

00 80 04 08                    # p_vaddr
00 80 04 08                    # p_physaddr

14 02 00 00                    # p_filesz
14 02 00 00                    # p_memsz

05 00 00 00                    # p_flags 
00 10 00 00                    # p_align

## Section Headers

# NULL Section Header
00 00 00 00                    # sh_name
00 00 00 00                    # sh_type: SHT_NULL = 0
00 00 00 00                    # sh_flags
00 00 00 00                    # sh_addr
00 00 00 00                    # sh_offset
00 00 00 00                    # sh_size
00 00 00 00                    # sh_link
00 00 00 00                    # sh_info
00 00 00 00                    # sh_addralign
00 00 00 00                    # sh_entsize

# .text Section Header
01 00 00 00                    # sh_name
01 00 00 00                    # sh_type: SHT_PROGBITS = 1
06 00 00 00                    # sh_flags
E0 80 04 08                    # sh_addr
E0 00 00 00                    # sh_offset
34 01 00 00                    # sh_size
00 00 00 00                    # sh_link
00 00 00 00                    # sh_info
04 00 00 00                    # sh_addralign
00 00 00 00                    # sh_entsize

# .shstrtab Section Header
07 00 00 00                    # sh_name
03 00 00 00                    # sh_type: SHT_STRTAB = 3
00 00 00 00                    # sh_flags
00 00 00 00                    # sh_addr
CC 00 00 00                    # sh_offset
14 00 00 00                    # sh_size
00 00 00 00                    # sh_link
00 00 00 00                    # sh_info 
01 00 00 00                    # sh_addralign
00 00 00 00                    # sh_entsize

#End headers

## .shstrtab section
00                             # NULL 
                               
2E 74 65 78 74 00              # ".text\0" 
                               
2E 73 68 73 74 72 74 61 62 00  # ".shstrtab\0" 

00 00 00

## .text section
#0xe0:
     55                        #push   %ebp
     89 E5                     #mov    %esp,%ebp
     8B 75 04                  #mov    0x4(%ebp),%esi
     5D                        #pop    %ebp
     C3                        #ret    
#0xe8:
     55                        #push   %ebp
     89 E5                     #mov    %esp,%ebp
     BA 04 00 00 00            #mov    $0x4,%edx
     8D 4D 08                  #lea    0x8(%ebp),%ecx
     BB 01 00 00 00            #mov    $0x1,%ebx
     B8 04 00 00 00            #mov    $0x4,%eax
     CD 80                     #int    $0x80
     5D                        #pop    %ebp
     C3                        #ret    
#0x101:
     BB 00 00 00 00            #mov    $0x0,%ebx
     B8 01 00 00 00            #mov    $0x1,%eax
     CD 80                     #int    $0x80
#0x10d:
     BB 01 00 00 00            #mov    $0x1,%ebx
     B8 01 00 00 00            #mov    $0x1,%eax
     CD 80                     #int    $0x80
#0x119 (main):
     89 E5                     #mov   %esp,%ebp
     83 7D 00 01               #cmpl  $0x1,0x0(%ebp)
     7E EC                     #jle   0x10d
     B9 00 00 00 00            #mov   $0x0,%ecx
     8B 5D 08                  #mov   0x8(%ebp),%ebx
     B8 05 00 00 00            #mov   $0x5,%eax
     CD 80                     #int   $0x80
     83 F8 00                  #cmp   $0x0,%eax
     7C D8                     #jl    0x10d
     50                        #push  %eax
     81 EC 00 01 00 00         #sub   $0x100,%esp
     89 E1                     #mov   %esp,%ecx
     8B 5D FC                  #mov   -0x4(%ebp),%ebx
     B8 6C 00 00 00            #mov   $0x6c,%eax
     CD 80                     #int   $0x80
     E8 93 FF FF FF            #call  0xe0
     81 EE 4D 01 00 00         #sub   $0x14d,%esi
     BA 18 00 00 00            #mov   $0x18,%edx
     89 F1                     #mov   %esi,%ecx
     BB 01 00 00 00            #mov   $0x1,%ebx
     B8 04 00 00 00            #mov   $0x4,%eax
     CD 80                     #int   $0x80
     8B 85 10 FF FF FF         #mov   -0xf0(%ebp),%eax
     81 C0 DB 80 04 08         #add   $0x80480db,%eax
     50                        #push  %eax
     E8 70 FF FF FF            #call  0xe8
     83 C4 04                  #add   $0x4,%esp
     83 C6 1C                  #add   $0x1c,%esi
     BA 28 00 00 00            #mov   $0x28,%edx
     89 F1                     #mov   %esi,%ecx
     BB 01 00 00 00            #mov   $0x1,%ebx
     B8 04 00 00 00            #mov   $0x4,%eax
     CD 80                     #int   $0x80
     8B 85 10 FF FF FF         #mov   -0xf0(%ebp),%eax
     81 C0 E0 00 00 00         #add   $0xe0,%eax
     50                        #push  %eax
     E8 45 FF FF FF            #call  0xe8
     E8 40 FF FF FF            #call  0xe8
     83 C4 04                  #add   $0x4,%esp
     83 C6 30                  #add   $0x30,%esi
     BA 44 00 00 00            #mov   $0x44,%edx
     89 F1                     #mov   %esi,%ecx
     BB 01 00 00 00            #mov   $0x1,%ebx
     B8 04 00 00 00            #mov   $0x4,%eax
     CD 80                     #int   $0x80
     FF B5 10 FF FF FF         #pushl -0xf0(%ebp)
     E8 1C FF FF FF            #call  0xe8
     83 C4 04                  #add   $0x4,%esp
     83 C6 48                  #add   $0x48,%esi
     BA 4C 00 00 00            #mov   $0x4c,%edx
     89 F1                     #mov   %esi,%ecx
     BB 01 00 00 00            #mov   $0x1,%ebx
     B8 04 00 00 00            #mov   $0x4,%eax
     CD 80                     #int   $0x80
     89 E1                     #mov   %esp,%ecx
#0x1e7:
     BA 00 01 00 00            #mov   $0x100,%edx
     8B 5D FC                  #mov   -0x4(%ebp),%ebx
     B8 03 00 00 00            #mov   $0x3,%eax
     CD 80                     #int   $0x80
     83 F8 00                  #cmp   $0x0,%eax
     0F 8E 02 FF FF FF         #jle   0x101
     89 C2                     #mov   %eax,%edx
     BB 01 00 00 00            #mov   $0x1,%ebx
     B8 04 00 00 00            #mov   $0x4,%eax
     CD 80                     #int   $0x80
     EB D8                     #jmp   0x1e7
#Entry point is here:
     E9 05 FF FF FF            #jmp   0x119 #jump to main
