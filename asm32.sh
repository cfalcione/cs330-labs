#!/bin/sh
# Simple shell script to compile and link a nasm program on Linux
# This is a modified version of the script given to students
nasm -f elf32 along32.asm
nasm -f elf32 -l $1.lst $1.asm && gcc -m32 $1.o along32.o -o $1 -nostartfiles && rm $1.o && rm along32.o && rm $1.lst && ./$1
