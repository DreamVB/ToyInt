# ToyInt
A simple toy Interpreter made in Lazarus

This is a simple stack interpreter I made in Lazarus to run simple programs, it started off as a RPN calculator but developed in to a little programming language.

# Features
- Simple math operations
- Simple jumps
- Simple call procedures
- Labels
- Variables
- Printing strings
- String operations
- and lots more


# Example of squareing numbers 1 to 20

```
; Square numbers 1 to 20

20 !num
1 !count
0 !sqr

loop:
  &count Print
  &count dup * !sqr
  "$ = " Print &sqr PrintLn
  &count 1 + !count
  &count &num <=
  jnz loop
 Exit
 ```

See examples in the example folder to better understand the language.
