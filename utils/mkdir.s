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
	.string "Usage: mkdir [-p] DIRECTORY ...\n"

.text
_start:
	POP	%eax
	DECL	%eax
	JNZ	.begin
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

.begin:
	POP	%esi
.n1:				# set edi to argv[0] eol
	LODSB
	ORB 	%al, %al
	JNZ	.n1
	MOVL	%esi, %edi

	MOVL	$0755, %ecx
	XORL	%ebp, %ebp

.next_arg:
	POP	%esi
	PUSH	%esi

	CMPB	'-', (%esi)
	JNZ	.next_file
#	CMPB	'm', 1(%esi)
#	JZ	.read_m
	CMPB	'p', 1(%esi)
	JNZ	.help
	INCL	%ebp		# ebp: -p flag
	POP	%esi
	JMP	.next_arg

#.read_m:
#	POP	%esi
#	ORL	%esi, %esi
#	JZ	.exit
#
#	MOVL	%esi, %edx 
#	XORL	%ecx, %ecx
#	XORL	%eax, %eax
#	MOVL	$8, %ebx

#.next:
#	MOVB	(%esi), %cl
#	SUBB	$0x30, %cl
#	JB	.done
#	CMPB	$7, %cl
#	JA	.done
#	MULB	%bl
#	ADDL	%ecx, %eax
#	INCL	%esi
#	JMP	.next

#.done:
#	CMPL	%esi, %edx
#	JZ	.exit
#	ORL	%eax, %eax
#	JZ	.exit
#
#	POP	%esi
#	MOVL	%eax, %ecx
#	JMP	.next_arg
	
.next_file:
	POP	%ebx
	ORL	%ebx, %ebx
	JZ	.exit
	CMPB	'r', -6(%edi)
	JNZ	.mkdir
	MOVL	$0x28, %eax
	INT	$0x80
	JMP	.next_file
	
.mkdir:
	PUSH	%edi

	MOVB	$1, %dl
	ORL	%ebp, %ebp
	JZ	.call
	
	MOVL	%ebx, %esi
	JMP	.check

.next_dir:
	MOVL	%esi, %edi
	MOVB	$0, (%edi)
.call:
	MOVL	$0x27, %eax
	INT	$0x80
	ORL	%edx, %edx
	JNZ	.done_mk
	MOVB	'/', (%edi)
	INCL	%esi
.check:
	XORL	%edx, %edx
	MOVL	%esi, %edi
	MOVB	'/', %al
	CALL	strchr
	JC	.next_dir
	INCL	%edx
	CMPL	%edi, %esi
	JNZ	.next_dir
.done_mk:
	POP	%edi
	JMP	.next_file


strchr:
	PUSH	%eax
	MOVB	%al, %ah
	CLC
.next_chr:
	LODSB
	ORB	%al, %al
	JZ	.return
	CMPB	%ah, %al
	JNZ	.next_chr
	STC
.return:
	DECL	%esi
	POP	%eax
	RET
