# x86 hex to asm Bootstrapping Kit

This is a project to develop a working an x86 assembler and linker from as 
small a binary seed as possible. We start with a minimal program capable of 
generating itself from its source and gradually develop higher level tools
and abstractions.

This programs produced in this project are 32-bit ELF executables which run on
a Linux kernel running on an Intel x86 processor.  They run fine on modern
64-bit systems.

## Stage 0: unhex

The starting point of the experiment is a tiny program for packing hexadecimal
octets into binary.

## Stage 1: unhexl & elfify

This stage adds a tool to wrap a text section into a minimal ELF executable, as
well as further developing the unhex program to support labels, and references
to earlier labels.

## Stage 2: as

This stage introduces a light-weight assembler, written in machine code without
forward jumps. It generates a text section that can be wrapped with the stage 1
elfify program to produce an executable.

## Stage 3: as & ld

The assembler is rewritten in assembler language and is joined by a linker,
which together allow for separate compilation units.

## Stage 4: asmutils

Various command line utilites are provided in assembly.

### Licensing
The code in stages 0-3 is copyright (C) Richard Smith, and is licensed for use
under version 3 or later of the GNU General Public License. The documentation
contained in the README.txt files in each stage is licensed under the Creative
Commons BY-NC-SA licence, version 4.

The code in stage 4 is derived from the asmutils project and is
copyright (C) Konstantin Boldyshev et al. It is licensed under the GNU General
Public License version 2 ONLY.

The GPLv2 and the GPLv3 are INCOMPATIBLE with one another. These files can be
hosted in the same repo because each util is independent and not linked to any
incompatible code. But you cannot copy + paste code from any of the stages 0-3
into any file in stage 4, or vice versa. Be mindful of this.
