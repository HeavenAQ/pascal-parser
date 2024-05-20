# Compiler hw2

Author: B081020008 陳羿閔
Created time: May 19, 2024 9:18 PM
SUBJECTS: Compiler (https://www.notion.so/Compiler-1760939ce271452aa81d9c48c6884bd8?pvs=21)

## 1. Lex Version

```c
flex 2.6.4
```

## 2. Platform (Container)

```c
> uname -svmpi
Linux #1 SMP Sat Mar 30 12:20:36 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux

> lsb_release -sirc
Ubuntu
18.04
bionic
```

## 3. Execution

- Run a single test

```c
make clean all
./a.out < input_data.pas
```

- Run everything at once

```c
./test_all.sh
```

## 4. Error Handling

- **Variable (or Function) Used Before Definition or Assignment Type Mismatch**

  - The validity of variables is checked using the **`check_identifier`** function. This function searches the **`identifier_stack`**, in which all declared identifiers are stored to verify if a variable has been declared before its use. If a variable is used without being declared, an error message is generated using **`yyerror`**.

  - For assignment type mismatches, the **`check_expression`** function ensures that the left-hand side (LHS) and right-hand side (RHS) of an assignment have compatible types. If there is a mismatch, it generates an error message indicating the type conflict. This part is implemented through the use of `check_lhs` flag. It is set to `1` upon an assignment pattern is detected. The `check_expression` will then compare the data types of RHS and LHS to ensure that both side have the same data type.

- **Structural Errors**
  - Structural errors, such as missing brackets or a **`then`** without an **`if`**, are handled by the Yacc grammar rules. For instance, the **`if_statement`** rule ensures that a **`then`** keyword is always preceded by an **`if`** expression. Errors in structure, like missing parentheses, are caught by the parser due to the expected grammar structure.
- **Missing or Incorrect Symbols**
  - The Lex file defines various tokens for symbols like semicolons, colons, and periods. The Yacc grammar enforces the correct use of these symbols. For example, rules like **`declaration_list`** and **`statements`** ensure that declarations and statements are correctly terminated with semicolons. If these symbols are missing or incorrect, the parser will generate an appropriate syntax error.
- **Adding Variables of Different Types**
  - To handle type checking within expressions, the **`check_expression`** function is used. It compares the types of all terms in an expression to ensure they are compatible. If different types are used in an expression (e.g., **`int + string`**), it generates an error message. This ensures that operations between incompatible types are flagged as errors during parsing.

## 6. Result

```c
Testing ./testfile/correct.pas
==================================
Line 1: program test;
Line 2: var
Line 4:   i, j: integer;
Line 5:   ans: array[0 .. 81] of integer;
Line 6: begin
Line 7:     i := -1+3;
Line 8:     j := +7*8;
Line 9:     ans[0] := 7;
Line 14:     for i:=1 to 9 do
Line 15:     begin
Line 16:         for j:=1 to i do
Line 17:             ans[i*9+j] := i*j;
Line 18:     end;
Line 20:     for i:=1 to 9 do
Line 21:     begin
Line 22:         for j:=1 to i do
Line 23:             if ( ans[i*9+j] mod 2 = 0) then
Line 24:                 write(i, '*', j, '=', ans[i*9+j], ' ');
Line 25:         writeln;
Line 26:     end;
Line 27: end.
----------------------------------

Testing ./testfile/error1.pas
==================================
Line 1: program test;
Line 2: var
Line 3:   i: integer;
Line 4: begin
Line 5, at char 6, syntax error, unexpected =, expecting :=
 > Line 5:   i = 3;
Line 6, at char 6, undeclared identifier: j
 > Line 6:   j = 4;
Line 7, at char 13, undeclared identifier: j
 > Line 7:   if (i > j) then
Line 8:     Write('ok');
Line 9: end.
---------------------------------

Testing ./testfile/error2.pas
==================================
Line 1: program test;
Line 2: var
Line 3:   i, j : integer;
Line 4: begin
Line 5:   i := 5*2;
Line 6:   j := 9;
Line 7:   if (i > j) then
Line 8:     Write('ok');
Line 9: end.
---------------------------------

Testing ./testfile/error3.pas
==================================
Line 1: program test;
Line 2: var
Line 3, at char 10, syntax error, unexpected :=, expecting : or ,
 > Line 3:   i, j := integer;
Line 4: begin
Line 5, at char 7, undeclared identifier: i
 > Line 5:   i := 5;
Line 6, at char 4, syntax error, unexpected $end, expecting .
 > Line 6: end
---------------------------------

Testing ./testfile/error4.pas
==================================
Line 1: program test;
Line 2: var
Line 3:   i, j : integer;
Line 4:   c : string;
Line 5: begin
Line 6:   i := 5;
Line 7:   c := 'aa';
Line 8, at char 6, syntax error, unexpected =, expecting :=
 > Line 8:   i = i+c;
Line 9: end.
---------------------------------

Testing ./testfile/diff_declaration_assignment.pas
==================================
Line 1: program test;
Line 2: var
Line 3:   i, j : integer;
Line 4: begin
Line 5, at char 13, Invalid assignment: "'aa'" of type "string" does not match "j" of type "integer
 > Line 5:   j := 'aa';
Line 6:   if (i > j) then
Line 7:     Write('ok');
Line 8: end.
---------------------------------

Testing ./testfile/diff_type_operation.pas
==================================
Line 1: program test;
Line 2: var
Line 3:   i, j : integer;
Line 4:   c : string;
Line 5: begin
Line 6:   i := 5;
Line 7:   c := 'aa';
Line 8, at char 12, Invalid operation in expression: "i" of type "integer" does not match "c" of type "string"
 > Line 8:   i := i+c;
Line 9: end.
---------------------------------

Testing ./testfile/invalid_identifier_in_expression.pas
==================================
Line 1: program test;
Line 2: var
Line 4:   i, j: integer;
Line 5:   ans: array[0 .. 81] of integer;
Line 6: begin
Line 7:     i := -1+3;
Line 8:     j := +7*8;
Line 9:     ans[0] := 7;
Line 14, at char 10, undeclared identifier: k
 > Line 14:     for k:=1 to 9 do
Line 15:     begin
Line 16:         for j:=1 to i do
Line 17, at char 31, undeclared identifier: p
 > Line 17:             ans[i*9+j] := i*p;
Line 18:     end;
Line 20:     for i:=1 to 9 do
Line 21:     begin
Line 22:         for j:=1 to i do
Line 23, at char 27, undeclared identifier: an
 > Line 23:             if ( an[i*9+j] mod 2 = 0) then
Line 24:                 write(i, '*', j, '=', ans[i*9+j], ' ');
Line 25:         writeln;
Line 26:     end;
Line 27: end.

---------------------------------

Testing ./testfile/missing_declaration_type.pas
=================================
Line 1: program test;
Line 2: var
Line 3, at char 7, sytax error: data type missing
 > Line 3:   i: ;
Line 4, at char 7, sytax error: data type missing
 > Line 4:   j: ;
Line 5: begin
Line 6, at char 6, undeclared identifier: i
 > Line 6:   i = 3;
Line 7, at char 6, undeclared identifier: j
 > Line 7:   j = 4;
Line 8, at char 10, undeclared identifier: i
 > Line 8:   if (i > j) then
Line 9:     Write('ok');
Line 10: end.
---------------------------------
```

## 7. 測試檔案

```c
./testfile/correct.pas
==================================
program test;
var
(* one line comment *)
  i, j: integer;
  ans: array[0 .. 81] of integer;
begin
    i := -1+3;
    j := +7*8;
    ans[0] := 7;
    (*
    multiple lines comments
    do not show comments
    *)
    for i:=1 to 9 do
    begin
        for j:=1 to i do
            ans[i*9+j] := i*j;
    end;

    for i:=1 to 9 do
    begin
        for j:=1 to i do
            if ( ans[i*9+j] mod 2 = 0) then
                write(i, '*', j, '=', ans[i*9+j], ' ');
        writeln;
    end;
end.
----------------------------------

./testfile/error1.pas
==================================
program test;
var
  i: integer;
begin
  i = 3;
  j = 4;
  if (i > j) then
    Write('ok');
end.
---------------------------------

./testfile/error2.pas
==================================
program test;
var
  i, j : integer;
begin
  i := 5*2;
  j := 9;
  if (i > j) then
    Write('ok');
end.
---------------------------------

./testfile/error3.pas
==================================
program test;
var
  i, j := integer;
begin
  i := 5;
end
---------------------------------

./testfile/error4.pas
==================================
program test;
var
  i, j : integer;
  c : string;
begin
  i := 5;
  c := 'aa';
  i = i+c;
end.
---------------------------------

./testfile/diff_declaration_assignment.pas
==================================
program test;
var
  i, j : integer;
begin
  j := 'aa';
  if (i > j) then
    Write('ok');
end.
---------------------------------

./testfile/diff_type_operation.pas
==================================
program test;
var
  i, j : integer;
  c : string;
begin
  i := 5;
  c := 'aa';
  i := i+c;
end.
---------------------------------

./testfile/invalid_identifier_in_expression.pas
==================================
program test;
var
(* one line comment *)
  i, j: integer;
  ans: array[0 .. 81] of integer;
begin
    i := -1+3;
    j := +7*8;
    ans[0] := 7;
    (*
    multiple lines comments
    do not show comments
    *)
    for k:=1 to 9 do
    begin
        for j:=1 to i do
            ans[i*9+j] := i*p;
    end;

    for i:=1 to 9 do
    begin
        for j:=1 to i do
            if ( an[i*9+j] mod 2 = 0) then
                write(i, '*', j, '=', ans[i*9+j], ' ');
        writeln;
    end;
end.

---------------------------------

./testfile/missing_declaration_type.pas
==================================
program test;
var
  i: ;
  j: ;
begin
  i = 3;
  j = 4;
  if (i > j) then
    Write('ok');
end.
---------------------------------
```

