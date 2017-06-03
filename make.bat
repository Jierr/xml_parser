@echo off

set "LIB_FLEX=C:\MinGW\msys\1.0\lib"

bison --defines pxml.y -o parser.cpp
flex -oscanner.cpp pxml.l 
g++ -static parser.cpp scanner.cpp -L%LIB_FLEX% -lfl -o xml_parser