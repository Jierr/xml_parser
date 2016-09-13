@echo off
bison --defines pxml.y -o parser.cpp
flex -oscanner.cpp pxml.l 
g++ parser.cpp scanner.cpp -LC:\Toolkits\GnuWin32\lib -lfl -o xml_parser