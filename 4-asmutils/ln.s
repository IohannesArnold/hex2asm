# Copyright (C) 1999-2000 Konstantin Boldyshev <konst@linuxassembly.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the version 2 (and only version 2) of the GNU 
# General Public License as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

.data
.usage:
	.string "Usage: ln [-s] TARGET LINK_NAME\n"

.text
_start:
	POP	%ebx
	CMPL	$3, %ebx
	JB	.help

	POP	%esi		# argv[0]
	POP	%edi		# argv[1] = target or '-s'

	CMPB	'-', (%edi)
	JNZ	.hardlink
	CMPB	's', 1(%edi)
	JNZ	.help

.symlink:
	POP	%ebx
	POP	%ecx
	MOVL	$83, %eax
	INT	$0x80
	JMP	.exit

.hardlink:
	POP	%ecx
	MOVL	%edi, %ebx
	MOVL	$9, %eax
	INT	$0x80
	JMP	.exit

.help:
	MOVL	$4, %eax
	MOVL	$2, %ebx
	MOVL	$.usage, %ecx
	MOVL	$32, %edx
	INT	$0x80
	MOVL	$1, %eax
.exit:
	MOVL	%eax, %ebx
	MOVL	$1, %eax
	INT	$0x80
