# Copyright (C) 2000-2003 Alexandr Gorlov <ct@mail.ru>
#                         Karsten Scheibler <karsten.scheibler@bigfoot.de>
#                         Rudolf Marek <marekr2@fel.cvut.cz>
#                         Joshua Hudson <joshudson@hotmail.com>
#                         Thomas Ogrisegg <tom@rhadamanthys.org>
#                         Konstantin Boldyshev <konst@linuxassembly.org>
#                         Nick Kurshev <nickols_k@mail.ru>
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

#############################################################################
#############################################################################
##
## PART 1: Data Section
##
#############################################################################
#############################################################################

.data
text:
.welcome:	.string "asmutils shell\n"
.welcom_len:	.int 15
.prompt_usr:	.string "$ "
.prompt_rt:	.string "# "
.prompt_tbd:	.string "> "
.cmd_nf:	.string "command not found\n"
.cmd_nf_len:	.int 17
.cdfail:	.string "couldn't change directory\n"
.cdfail_len:	.int 26
.logout:	.string "logout"
.logout_len:	.int 6

cmdline:
.buffer1:	.zero 4096
.buffer2:	.zero 65536
.align 4
.prompt:	.int  0
.argv:		.zero 8192
.environ:	.zero 128
.env_c:		.int  0
.argc:		.int  0

script_fd:	.int  0		# STDIN = 0

#############################################################################
#############################################################################
##
## PART 2: Start Code
##
#############################################################################
#############################################################################

.text
_start:
		POP	%edi		# argc
		POP	%edi		# argv[0]
		CALL	env_init
		POP	%ebx		# argv[1] (shell script or NULL)
		CALL	env_inherit
		TESTL	%ebx, %ebx
		JZ	.intract_sh

		# open shell script
		XORL	%ecx, %ecx
		MOVL	$5, %eax
		INT	$0x80
		MOVL	%eax, script_fd
		JMP	.skip_prmpt

.intract_sh:
		# write welcome message
		MOVL	$15, %edx
		MOVL	$.welcome, %ecx
		MOVL	$1, %ebx
		MOVL	$4, %eax
		INT	$0x80

		# initialize terminal
		CALL	tty_init

		# get UID and select prompt type
		MOVL	$24, %eax
		INT	$0x80
		MOVL	$.prompt_usr, %ebx
		TESTL	%eax, %eax
		JNZ	.not_root
		MOVL	$.prompt_rt, %ebx
.not_root:
		MOVL	%ebx, %eax	#assembler can only move symbol values
		MOVL	%eax, .prompt	#to and from %eax

cmd_loop:
		# print a new shell prompt then exec the command

		# print shell prompt
		MOVL	.prompt, %eax
		MOVL	%eax, %ecx
		JMP	.show_prmpt
.tbd_prmpt:
		MOVL	$.prompt_tbd, %ecx
.show_prmpt:				
		MOVL	$2, %edx	#all prompts are 2 chars long
		MOVL	$1, %ebx
		MOVL	$4, %eax
		INT	$0x80
.skip_prmpt:
		# read cmdline into buffer
		CALL	cmdline_get
		TESTL	%eax, %eax
		JZ	.no_read

.skip_read:
		# parse cmdline
		CALL	cmdline_prs
		PUSH	%ecx
		TESTL	%eax, %eax
		JZ	.skip_exec

		# execute cmd
		CALL	cmd_exec
.skip_exec:
		# reset argc
		XORL	%eax, %eax
		MOVL	%eax, .argc

		# get next cmdline
		POP	%eax
		TESTL   %eax, %eax	# if there are still chars in 
		JZ	cmd_loop	# buffer 1 then don't read more
		JMP	.skip_read
.no_read:
		MOVL	script_fd, %eax
		TESTL	%eax, %eax
		JZ	cmd_loop
		XORL	%ebx, %ebx
		MOVL	$1, %eax
		INT	$0x80

#############################################################################
#############################################################################
##
## PART 3: Subroutines
##
#############################################################################
#############################################################################

#############################################################################
#############################################################################
####
#### PART 3.1: string subroutines
####
#############################################################################
#############################################################################

#############################################################################
## string_length ############################################################
#############################################################################
## edi=>  pointer to string
## <=ecx  string length (including trailing 0)
## <=edi  pointer to string + string length
#############################################################################
str_len:
		XORL	%ecx, %ecx
		XORL	%eax, %eax
		DECL	%ecx
		CLD
		REPNE	SCASB
		NEGL	%ecx
		RET

#############################################################################
#############################################################################
####
#### PART 3.2: subroutines for environment variables
####
#############################################################################
#############################################################################

#############################################################################
## env_initialize ###########################################################
#############################################################################
## edi=>  argv[0]
#############################################################################
env_init:
		XORL	%ebx, %ebx
		MOVL	$45, %eax
		INT	$0x80
		MOVL	%eax, .environ
		PUSH	%eax
		MOVL	$1, %eax
		MOVL	%eax, .env_c
		POP	%eax
		MOVL	%eax, %edx
		XCHGL	%eax, %ebx
		MOVL	%edi, %esi
		CALL	str_len
		ADDL	%ecx, %ebx
		ADDL	$8, %ebx
		MOVL	$45, %eax
		INT	$0x80
		XCHGL	%edi, %edx
		MOVL	'SHEL', (%edi)
		MOVL	'L=\0\0', 4(%edi)
		ADDL	$6, %edi
.shell_char:
		LODSB
		STOSB
		ORB	%al, %al
		JNZ	.shell_char
		DECL	%edi
		XORB	%al, %al
		STOSB
		RET

#############################################################################
## env_inherit ##############################################################
#############################################################################
## ebx=>  argv[1]
## <=ebx  argv[1] (unused, but needs to remain unclobbered)
#############################################################################
env_inherit:
		POP	%esi		# return addr
		ORL 	%ebx, %ebx
		JZ	.first_env
.clear_argv:
		#get rid of the rest of argv
		POP 	%eax
		TESTL	%eax, %eax
		JNZ   	.clear_argv
.first_env:
		MOVL 	.env_c, %eax
		MOVL	%eax, %edx
		MOVL	$4, %ecx
		MULL	%ecx
		ADDL	$.environ, %eax
		MOVL	%eax, %ecx
.next_env:
		POP	%eax
		TESTL	%eax, %eax
		JZ	.env_done
		MOVL	%eax, (%ecx)
		INCL	%edx
		ADDL	$4, %ecx
		JMP	.next_env
.env_done:
		MOVL	%edx, %eax
		MOVL	%eax, .env_c
		PUSH	%esi
		RET

#############################################################################
#############################################################################
####
#### PART 3.3: subroutines for terminal handling
####
#############################################################################
#############################################################################

#############################################################################
## tty_init #################################################################
#############################################################################
tty_init:
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#TODO: set STDIN options (blocking, echo, icanon etc ...) only on linux ?
#      set signal handlers
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		RET

#############################################################################
#############################################################################
####
#### PART 3.3: sub routines for parsing command line
####
#############################################################################
#############################################################################

#############################################################################
## cmdline_get ##############################################################
#############################################################################
## <=eax  characters read (including trailing \n)
#############################################################################
#Possible TODO: change to char orientated mode
cmdline_get:
		MOVL	$4095, %edx
		MOVL	$.buffer1, %ecx
		MOVL	script_fd, %eax
		MOVL	%eax, %ebx
		MOVL	$3, %eax
		INT	$0x80
		TESTL	%eax, %eax
		JNS	.get_end
		XORL	%eax, %eax
.get_end:
		MOVL	%eax, %ebx
		ADDL	$.buffer1, %ebx
		MOVB	$0, (%ebx)
		RET

#############################################################################
## cmdline_parse ############################################################
#############################################################################
## eax=>  number of characters in buffer 1
## <=ecx  number of characters remaining in buffer 1
## <=eax  argc
#############################################################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#TODO: < > 2> ` $ | & || &&
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
cmdline_prs:
		MOVL	$.argv, %ebx
		MOVL	%eax, %ecx
		MOVL	.argc, %eax
		MOVL	%eax, %edx
		MOVL	$.buffer1, %esi
		MOVL	$.buffer2, %edi

.new_arg:
		MOVL	%edi, (%ebx)
		
.next_char:
		LODSB
		CMPB	'\0', %al
		JE	.cmd_end
		DECL	%ecx
		CMPB	'\n', %al
		JE	.cmd_end
		CMPB	'#', %al
		JE	.skip_cmnt
		CMPB	' ', %al
		JE	.end_arg
		CMPB	'\t', %al
		JE	.end_arg
		CMPB	'\'', %al
		JE	.sing_quot
		CMPB	'"', %al
		JE	.dbl_quot
		STOSB
		JMP	.next_char
.sing_quot:
		LODSB
		DECL	%ecx
		CMPB	'\'', %al
		JE	.next_char
		STOSB
		JMP	.sing_quot
.dbl_quot:
		LODSB
		DECL	%ecx
		CMPB	'"', %al
		JE	.next_char
		STOSB
		JMP	.dbl_quot
.skip_cmnt:
		LODSB
		CMPB	'\0', %al
		JE	.cmd_end
		DECL	%ecx
		CMPB	'\n', %al
		JE	.next_char
		JMP	.skip_cmnt
.end_arg:
		MOVL	(%ebx), %eax
		CMPL	%eax, %edi	# if eax = edi, no new arg
		JE	.next_char	# chars have been copied
		MOVB	'\0', %al
		STOSB
		INCL	%edx		# argc++
		ADDL	$4, %ebx
		JMP	.new_arg
.cmd_end:
		MOVL	(%ebx), %eax
		CMPL	%eax, %edi	# if eax = edi, no new arg
		JE	.argv_seal	# chars have been copied
		MOVB	'\0', %al
		STOSB
		INCL	%edx		# argc++
		ADDL	$4, %ebx
.argv_seal:
		MOVL	$0, (%ebx)	# NULL-terminate argv

		MOVL	%ecx, %eax
		MOVL	$.buffer1, %edi	# move any remaining buffer 1 chars
		CLD
		REP	MOVSB		# to the beginning of buffer 1
		MOVL	%eax, %ecx

		MOVL	%edx, %eax
		MOVL	%eax, .argc
		RET

#############################################################################
## cmd_exec #################################################################
#############################################################################
cmd_exec:
		# fork
		MOVL	$2, %eax
		INT	$0x80
		TESTL	%eax, %eax
		JNZ	.wait

.exe_extern:
		# try to execute directly if the name contains a '/'
		MOVL	.argv, %eax
		MOVL	%eax, %edi
		CALL	str_len
		MOVL	.argv, %eax
		MOVL	%eax, %edi
		MOVB	'/', %al
		REPNE	SCASB
		CMPL	$0, %ecx
		JE	.scan_paths
		MOVL	$.environ, %edx
		MOVL	$.argv, %ecx
		MOVL	.argv, %eax
		MOVL	%eax, %ebx
		MOVL	$11, %eax
		INT	$0x80
.scan_paths:
		MOVL	$1, %ebx
		MOVL	$1, %eax
		INT	$0x80
.wait:
		XORL	%esi, %esi
		XORL	%edx, %edx
		XORL	%ecx, %ecx
		MOVL	$0xFFFFFFFF, %ebx
		MOVL	$114, %eax
		INT	$0x80
		RET
