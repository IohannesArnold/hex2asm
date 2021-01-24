# Copyright (C) 2012 - 2019 Richard Smith <richard@ex-parrot.com>
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

.data
.local bar
bar:
	.int	0x2A

.text
_start:
	MOVL	%esp, %ebp

	#  bar = square(bar)
	MOVL	bar, %eax
	PUSH	%eax
	CALL	square
	POP	%ecx
	MOVL	%eax, bar

	MOVL	bar, %eax
	MOVL	%eax, %ecx
	MOVL	foo, %eax
	CMPL	%eax, %ecx
	SETNE	%al
	MOVZBL	%al, %eax
	MOVL	%eax, foo

	#  Call exit(foo)
	MOVL	foo, %eax
	PUSH	%eax

# It should be safe to embed this literal in the middle of this function
.data
	.string	"\"Hello,\tworld\!\""
	.byte	0xFF

.text
	CALL	exit
	HLT

.data
