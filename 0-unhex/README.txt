BOOTSTRAP STAGE 0

The starting point for this bootstrap experiment is the unhex program.  
It is a very simple program for converting a stream of hexadecimal 
octets on standard input into a binary file written to standard output.  

  Usage:  unhex < test.x > test

where .x is used as the canonical extension for its input files. The 
source file format is very restrictive:

  XDIGIT := [0-9A-F]
  CHAR   := any character

  octet  := XDIGIT XDIGIT CHAR
  file   := octet*

This format is exceptionally easy to parse, which was the whole idea.
By allowing an arbitrary third character it allows some degree of source
code prettification by using spaces, new lines or other punctuation
marks.

Any deviation from this format will result in bogus data being written 
to the output stream, as no error checking is done.  In particular,
there must not be any trailing space on lines, nor can there be blank
lines.

The unhex.x file contains the hexadecimal octets for unhex.  Processing
it with unhex yields another copy of unhex, which we check is identical
to the inital copy as a way of testing that the program is working.

The program is deliberately minimal.  Of necessity, it starts with an
ELF header, followed by one program header for the whole file.  There
are no section headers and no shstrtab section, which together mean that
the binutils diagnostic tools (objdump, etc.) are of limited use on it.

Conceptually the program should have been written using some lower-level
technique, such as with a hex-editor.  But instead, the Makefile
contains a simple one-line shell script to perform the same action as
unhex, which is used to create the first unhex binary.  
