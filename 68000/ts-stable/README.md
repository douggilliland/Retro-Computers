# ts-stable

[![Build Status](https://travis-ci.org/jhlagado/ts-stable.svg?branch=master)](https://travis-ci.org/jhlagado/ts-stable)

## STABLE programming language in Typescript

STABLE is an extremely minimalistic "Forth-like" (but not Forth) language by Sandor Schneider.
Originally in C, I have ported it to Typescript to explore what can be done with the one of the world's smallest viable programming languages.

STABLE stands for STAck Bytecode Language & Engine and the [original implementation](examples/st.c) is only about 233 lines of formatted C code and much shorter if all the whitespace is removed.

Go here to see [a fully working version of STABLE](https://jhlagado.github.io/ts-stable/) in your browser.

## Glossary

### Arithmetic

| opcode | stack effects | description                 |
| ------ | ------------- | --------------------------- |
| +      | (a b -- a+b)  | addition                    |
| -      | (a b -- a-b)  | subtraction                 |
| \*     | (a b -- a\*b) | multiply                    |
| /      | (a b -- a/b)  | division                    |
| %      | (a b -- a%b)  | modulo (division remainder) |
| \_     | (n -- -n)     | negate                      |

### Bit manipulation

| opcode | stack effects   | description                         |
| ------ | --------------- | ----------------------------------- |
| &      | (a b -- a&b)    | 32 bits and                         |
| \|     | (a b -- a \| b) | 32 bits or                          |
| ~      | (n -- n')       | not, all bits invertsed (0=>1 1=>0) |

### Stack

| opcode | stack effects  | description                      |
| ------ | -------------- | -------------------------------- |
| \#     | (a -- a a)     | duplicate top of stack           |
| \\     | (a b -- a)     | drop top of stack                |
| \$     | (a b -- b a)   | swap top of stack                |
| @      | (a b -- a b a) | (over) copy next of stack on top |

### Register

| opcode | stack effects | description                                                   |
| ------ | ------------- | ------------------------------------------------------------- |
| x      | ( -- )        | select register x (x: a..z)                                   |
| ;      | ( -- value)   | fetch from selected register                                  |
| :      | ( value --)   | store into selected register                                  |
| ?      | ( -- value)   | selected register contains an address. Fetch value from there |
| !      | ( value --)   | selected register contains an address. Store value there.     |
| -      | ( -- )        | immediately after register, increment content by 1            |
| \*     | ( -- )        | immediately after register, decrement content by 1            |

### Functions

| opcode | stack effects | description                                     |
| ------ | ------------- | ----------------------------------------------- |
| {X     | ( -- )        | start function definition for function X (A..Z) |
| }      | ( -- )        | end of function definition                      |
| X      | ( -- )        | call function X (A..Z)                          |

### I/O

| opcode | stack effects | description                                                                                                                                                       |
| ------ | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| .      | (value -- )   | display value as decimal number on stdout                                                                                                                         |
| ,      | (value -- )   | send value to terminal, 27 is ESC, 10 is newline, etc.                                                                                                            |
| ^      | ( -- key)     | read key from terminal, don't wait for newline.                                                                                                                   |
| "      | ( -- )        | read string until next '"' put it on stdout                                                                                                                       |
| 0..9   | ( -- value)   | scan decimal number until non digit. to push two values on stack separate those by space (4711 3333). to enter negative numbers call \_ (negate) after the number |
| 0..9.0 | ( -- value)   | to enter float numbers digits must contain one '.' (only available if float module is active, see 0`)                                                             |

### Conditionals

| opcode | stack effects | description                                                                               |
| ------ | ------------- | ----------------------------------------------------------------------------------------- |
| <      | (a b -- f)    | true (-1) if b is < a, false (0) otherwise                                                |
| >      | (a b -- f)    | true (-1) if b is > a, false (0) otherwise                                                |
| =      | (a b -- f)    | true (-1) if a is equal to b, false (0) otherwise                                         |
| (      | (f -- )       | if f is true, execute content until ), if false skip code until ')'                       |
| [      | (f -- f)      | begin while loop only if f is true. keep flag on stack if f is false, skip code until ']' |
| ]      | (f --)        | repeat the loop if f is true. If f is false continue with code after ']'                  |
