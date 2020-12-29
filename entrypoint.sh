#!/bin/sh
timeout 1 cp code.ytp code2.ytp
echo "" > code.ytp # nuke the file content, just to ensure we have 
timeout 1 ./compiler code2.ytp -o code.o 2> compile_stderr


timeout 1 objdump -Mintel -d code.o > asm

timeout 1 gcc code.o -o code 2> gcc_stderr

timeout 2 ./code > program_stdout 2> program_stderr

retval=$?

timeout 1 python3 create_output.py
cat output > code.ytp

exit $retval
