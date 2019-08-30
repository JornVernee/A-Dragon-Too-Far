# A-Dragon-Too-Far
Text based adventure game written in GAS, originally as a college assignment.

Since the code looked somewhat decent, I thought I'd put it up on GitHuib to serve as an example for other people trying to learn assembler (which was lacking in my case).

The code is x86 (32 bit) GAS (Gnu assembler). Some C library calls have Windows style function names (starting with an underscore), but I've tried to put these in a separate file as much as possible (`ADTF_Kernel_C_Windows.s`). It heavily uses macros, so you'll probably want to look at `ADTF_Macros.s` as well as the `as` manual at: https://ftp.gnu.org/old-gnu/Manuals/gas-2.9.1/html_node/as_toc.html

I originally had a 5 x 5 map, but the code was terrible. This is a re-write, but I only got as far as adding the first event location.

There's also a python script that crawls the source files and generates `ADTF_Debug_gen.s`, which contains tables with various address -> string mappings, which is used in a debug build to look up things like function names.

The main file is `ADTF_Revive.s`.
