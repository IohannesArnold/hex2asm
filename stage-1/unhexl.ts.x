# Copyright (C) 2009 - 2019 Richard Smith <richard@ex-parrot.com>
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

	#  Function: bool isws(char)
	#  Tests whether its argument is in [ \t\n]

	#  As with many of the functions here, it is turned upside down
	#  so the entry point is in the middle.  This is because unhexl
	#  is limited to jumps up the file.
#.L1:
	5D			# pop	%ebp
	C3			# ret
#isws:
	55			# push	%ebp
	89 E5			# movl	%esp, %ebp
	8B 45 08		# movl	8(%ebp), %eax
	3C 20			# cmpb	$0x20, %al	# ' '
	0F 84 F0 FF FF FF	# je	.L1
	3C 09			# cmpb	$0x09, %al	# '\t'
	0F 84 E8 FF FF FF	# je	.L1
	3C 0A			# cmpb	$0x0A, %al	# '\n'
	0F 84 E0 FF FF FF	# je	.L1
	31 C0			# xorl	%eax, %eax
	E9 D9 FF FF FF		# jmp	.L1

	#  Function: bool islchr(char)
	#  Tests whether its argument is in [0-9A-Za-z_]
#.L2:
	31 C0			# xorl	%eax, %eax
#.L3:
	5D			# pop	%ebp
	C3			# ret
#islchr:
	55			# push	%ebp
	89 E5			# movl	%esp, %ebp
	8B 45 08		# movl	8(%ebp), %eax
	3C 30			# cmpb	$0x30, %al	# '0'
	0F 8C EE FF FF FF	# jl	.L2
	3C 39			# cmpb	$0x39, %al	# '9'
	0F 8E E8 FF FF FF	# jle	.L3
	3C 41			# cmpb	$0x41, %al	# 'A'
	0F 8C DE FF FF FF	# jl	.L2
	3C 5A			# cmpb	$0x5A, %al	# 'Z'
	0F 8E D8 FF FF FF	# jle	.L3
	3C 5F			# cmpb	$0x5F, %al	# '_'
	0F 84 D0 FF FF FF	# je	.L3
	3C 61			# cmpb	$0x61, %al	# 'a'
	0F 8C C6 FF FF FF	# jl	.L2
	3C 7A			# cmpb	$0x7A, %al	# 'z'
	0F 8E C0 FF FF FF	# jle	.L3
	E9 B9 FF FF FF	# jmp	.L2

	#  Function: int xchar(char)
	#  Tests whether its argument is a character in [0-9A-F], and if so, 
	#  coverts it to a decimal number; otherwise returns -1.
#.L6:
	2C 37			# subb	$0x37, %al	# 'A'-10
#.L7:
	5D			# pop	%ebp
	C3			# ret
#.L4:
	B8 FF FF FF FF		# movl	$-1, %eax
	E9 F4 FF FF FF		# jmp	.L7
#.L5:
	2C 30			# subb	$0x30, %al	# '0'
	E9 ED FF FF FF		# jmp	.L7
#xchr:
	55			# push	%ebp
	89 E5			# movl	%esp, %ebp
	8B 45 08		# movl	8(%ebp), %eax
	3C 30			# cmpb	$0x30, %al	# '0'
	0F 8C E1 FF FF FF	# jl	.L4
	3C 39			# cmpb	$0x39, %al	# '9'
	0F 8E E3 FF FF FF	# jle	.L5
	3C 41			# cmpb	$0x41, %al	# 'A'
	0F 8C D1 FF FF FF	# jl	.L4
	3C 46			# cmpb	$0x46, %al	# 'F'
	0F 8E C5 FF FF FF	# jle	.L6
	E9 C4 FF FF FF		# jmp	.L4

	#  Not a proper function.
	#  Exits program
#error:
	BB 01 00 00 00		# movl	$1, %ebx
#success:
	B8 01 00 00 00		# movl	$1, %eax
	CD 80			# int	$0x80

	#  Function:	void readone( [%ecx] char* ) 
	#  Reads one byte into (%ecx) which should already be set.
	#  Clobbers %edx, %ebx and %eax.
	#  Exits on failure.
#readone:
	8B 5D 04		# movl 4(%ebp), %ebx
	55			# push	%ebp
	89 E5			# movl	%esp, %ebp
	BA 01 00 00 00		# movl	$1, %edx
	B8 03 00 00 00		# movl	$3, %eax
	CD 80			# int	$0x80
	83 F8 01		# cmpl	$1, %eax
	0F 85 D9 FF FF FF	# jne	error
	5D			# pop	%ebp
	C3			# ret

#### #  The main function.
	#  Stack is arranged as follows:
	#
	#	  -4(%ebp)	int* addr
	#	 -84(%ebp)	char buffer[80]
	#	 -88(%ebp)	label* label_end
	#    -4184(%ebp)	label labels[256]
	#
	#  where label is a { char name[12]; int addr }.

#ret:
	# This ret is labelled to allow various bits of main to
	# jump up to it in order to effect a forwards jump.
	31 C0			# xorl	%eax, %eax
	C3			# ret

	#  --- Test for a comment.
	#  If found, skip over comment line until we've read a LF
	#  At end of section, %eax=1 iff we read a comment.
	#  If %eax=0, all other registers are unaltered.
#comment:
	80 7D AC 23		# cmpb	$0x23, -84(%ebp)
	0F 85 F3 FF FF FF	# jne	ret
#.L10:
	8D 4D AC		# lea	-84(%ebp), %ecx
	E8 CE FF FF FF		# call	readone
	80 7D AC 0A		# cmpl	$0x0A, -84(%ebp)	# '\n'
	0F 85 EE FF FF FF	# jne	.L10
	B8 01 00 00 00		# movl	$1, %eax
	C3			# ret

	# --- Test for an octet.
#octet:
	FF 75 AC		# push	-84(%ebp)
	E8 7F FF FF FF		# call	xchr
	5B			# pop	%ebx
	3C FF			# cmpb	$-1, %al
	0F 84 CA FF FF FF	# je	ret

	#  Yes, we do.  Read the next byte
	50			# push	%eax
	8D 4D AD		# lea	-83(%ebp), %ecx
	E8 A4 FF FF FF		# call	readone
	5B			# pop	%ebx

	#  Process it
	FF 75 AD		# push	-83(%ebp)
	E8 64 FF FF FF		# call	xchr
	5A			# pop	%edx
	83 F8 FF		# cmpl	$-1, %eax
	0F 84 85 FF FF FF	# je	error
	C6 C1 04		# movb	$4, %cl
	D2 E3			# salb	%cl, %bl
	00 D8			# addb	%bl, %al

	#  Byte is now in %al; lets write it
	50			# push	%eax
	BA 01 00 00 00		# movl	$1, %edx
	89 E0			# movl	%esp, %eax
	8D 08			# lea	(%eax), %ecx
	8B 5D 00		# movl 0(%ebp), %ebx
	B8 04 00 00 00		# movl	$4, %eax
	CD 80			# int	$0x80
	5A			# pop	%edx

	#  Increment the address and return
	FF 45 FC		# incl	-4(%ebp)
	B8 01 00 00 00		# movl	$1, %eax
	C3			# ret


	#  Parts of the label section
#labeldef:
	#  Check that we're not about to over run the label store,
	#  and then store the label
	8D 5D A8		# lea	-88(%ebp), %ebx
	8B 3B			# movl	(%ebx), %edi
	39 DF			# cmpl	%ebx, %edi -- is this right?
	0F 8D 53 FF FF FF	# jge	error
	F3 A4			# rep	movsb %ds:(%esi),%es:(%edi)
	8B 45 FC		# movl	-4(%ebp), %eax
	8B 3B			# movl	(%ebx), %edi
	89 47 0C		# movl	%eax, 12(%edi)
	83 03 10		# addl	$16, (%ebx)
	B8 01 00 00 00		# movl	$1, %eax
	C3			# ret

#labelref:
	#  Look up the label
	8D BD 98 EF FF FF	# lea	-4200(%ebp), %edi
#.L14:
	83 C7 10		# addl	$16, %edi
	3B 7D A8		# cmpl	-88(%ebp), %edi
	0F 8D 2E FF FF FF	# jge	error
	51			# push	%ecx
	56			# push	%esi
	57			# push	%edi
	F3 A6			# repz	cmpsb %es:(%edi),%ds:(%esi)
	5F			# pop	%edi
	5E			# pop	%esi
	59			# pop	%ecx
	0F 85 E6 FF FF FF	# jne	.L14

	#  Found it.  Increment address by four and print offset
	83 45 FC 04		# addl	$4, -4(%ebp)
	8B 47 0C		# movl	12(%edi), %eax
	2B 45 FC		# subl	-4(%ebp), %eax
	50			# push	%eax
	BA 04 00 00 00		# movl	$4, %edx
	89 E0			# movl	%esp, %eax
	8D 08			# lea	(%eax), %ecx
	BB 01 00 00 00		# movl	$1, %ebx
	8B 5D 00		# movl	0(%ebp), %ebx
	B8 04 00 00 00		# movl	$4, %eax
	CD 80			# int	$0x80
	58			# pop	%eax
	B8 01 00 00 00		# movl	$1, %eax
	C3			# ret

	# --- Test for a label (either definition or reference).
#label:
	#  Read a label
	8D 4D AC		# lea	-84(%ebp), %ecx
#.L12:
	41			# incl	%ecx
	E8 F9 FE FF FF		# call	readone
	FF 31			# push	(%ecx)
	E8 63 FE FF FF		# call	islchr
	5B			# pop	%ebx
	83 F8 00		# cmpl	$0, %eax
	0F 85 E9 FF FF FF	# jne	.L12

	#  (%ecx) is now something other than lchr.  Is it a colon?
	#  Also, null terminate, load %esi with start of string, and
	#  %ecx with its length inc. nul.
	80 39 3A		# cmpb	$0x3A, (%ecx)
	9C			# pushf
	C6 01 00		# movb	$0, (%ecx)
	41			# incl	%ecx
	8D 75 AC		# lea	-84(%ebp), %esi
	29 F1			# subl	%esi, %ecx
	83 F9 12		# cmpl	$12, %ecx
	0F 8F C6 FE FF FF	# jg	error
	9D			# popf
	0F 85 7F FF FF FF	# jne	labelref
	E9 5A FF FF FF		# jmp	labeldef

	#  --- The main loop
#main:
	89 E5			# movl	%esp, %ebp

	83 7D 00 03		# cmpl $3, 0(%ebp)
	BB 01 00 00 00		# movl $1, %ebx
	0F 85 A9 FE FF FF	# jne	error

# Open input file
	B8 05 00 00 00		# movl $5, %eax
	8B 5D 08		# movl 8(%ebp), %ebx
	31 C9			# xorl %ecx, %ecx
	CD 80			# int $0x80
	83 F8 00		# cmpl $0, %eax
	0F 8C E3 00 00 00	# jl .exit
	50			# pushl %eax
										   
# Open output file
	B8 05 00 00 00		# movl $5, %eax
	8B 5D 0C		# movl 12(%ebp), %ebx
	B9 42 00 00 00		# movl $0102, %ecx
	BA EC 01 00 00		# movl $0754, %edx
	CD 80			# int $0x80
	83 F8 00		# cmpl $0, %eax
	0F 8C C5 00 00 00	# jl .exit
	50			# pushl %eax

	89 E5			# movl	%esp, %ebp
	81 EC 58 10 00 00	# subl	$4184, %esp
	8D 85 A8 EF FF FF	# lea	-4184(%ebp), %eax
	89 45 A8		# movl	%eax, -88(%ebp)
	C7 45 FC 00 00 00 00	# movl	$0, -4(%ebp)

#.L8:
	#  Read one byte (not with readone because EOF is permitted)
	BA 01 00 00 00		# movl	$1, %edx
	8D 4D AC		# lea	-84(%ebp), %ecx
	8B 5D 04		# movl 4(%ebp), %ebx
	B8 03 00 00 00		# movl	$3, %eax
	CD 80			# int	$0x80
	83 F8 00		# cmpl	$0, %eax
	0F 8C 42 FE FF FF	# jl	error
	89 C3			# movl	%eax, %ebx
	0F 84 3F FE FF FF	# je	success

	#  Is the byte white space?  if so, loop back
	8A 45 AC		# movb	-84(%ebp), %al
	50			# push	%eax
	E8 85 FD FF FF		# call	isws
	83 F8 00		# cmpl	$0, %eax
	5A				# pop	%edx
	0F 85 CA FF FF FF	# jne	.L8

	#  We have a byte.  What is it?
	E8 4E FE FF FF		# call	comment
	83 F8 00		# cmp	$0, %eax
	0F 85 BC FF FF FF	# jne	.L8
	E8 62 FE FF FF		# call	octet
	83 F8 00		# cmp	$0, %eax
	0F 85 AE FF FF FF	# jne	.L8
	E8 10 FF FF FF		# call	label
	83 F8 00		# cmp	$0, %eax
	0F 85 A0 FF FF FF	# jne	.L8
	E9 F8 FD FF FF		# jmp	error

#### #  And finally, the entry point.
	#  Last per requirement for elfify.
	E9 39 FF FF FF		# jmp	main
