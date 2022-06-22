# 1802/1805A Cross-Assembler Ver 2.6

Copyright (c) 1985 William C. Colley, III, _with updates by Herbert R Johnson and others_

## Command Line
The command line for the cross-assembler looks like this:
```
a18 _source_file {-l list_file} {-o obj_file} {-b bin_file}_
```
where the { } indicates that the specified item is optional.

Note: `-L` produces a listing file with uppercase address and data; `-l` produces lowercase.

The order in which the source, listing, object, and binary files are specified does not matter.

## Labels

A label is any sequence of alphabetic or numeric characters starting with an alphabetic. The legal alphabetics are:

 ! # $ % & , . : ? @ [ \ ] ^ _ ` { | } ~ A-Z a-z

The numeric characters are the digits 0-9. Note that "A" is not the same as "a" in a label. This can explain mysterious U (undefined label) errors occurring when a label appears to be defined. Labels ending with a ":" have that character ignored.

A label is permitted on any line except a line where the opcode is IF, ELSE, or ENDIF. The label is assigned the value of the assembly program counter before any of the rest of the line is processed except when the opcode is EQU, ORG, PAGE, or SET.

Labels can have the same name as opcodes, but they cannot have the same name as operators or registers. The reserved (operator and register) names are:
```
             $         AND       EQ        GE        GT        HIGH
             LE        LT        LOW       MOD       NE        NOT
             OR        SHL       SHR       XOR
```
If a label is used in an expression before it is assigned a value, the label is said to be "forward-referenced." Example:

             L1   EQU  L2 + 1   ; L2 is forward-referenced here.
             L2
             L3   EQU  L2 + 1   ; L2 is not forward-referenced here.


## Numeric Constants

 Numeric constants are formed according to the Intel convention. A numeric constant starts with a numeric character (0-9), continues with zero or more digits (0-9, A-F), and ends with an optional base designator. In addition, constants beginning with "$" are hex, with "@" are octal, with "%" binary. The base designators are H for hexadecimal, none or D for decimal, letter O or Q for octal, and B for binary. The hex digits a-f are converted to upper case. Note that a numeric constant cannot begin with A-F as it would be indistinguishable from a label. Thus, all of the following evaluate to 255 (decimal):

	%11111111 $FF 0ffH 255 255D @377 377O 377Q 11111111B

Please consider that '$' alone is the current assembler address value.

## String Constants

A string constant is zero or more characters enclosed in either single quotes (' ') or double quotes (" "). Single quotes only match single quotes, and double quotes only match double quotes, so if you want to put a single quote in a string, you can do it like this: "'". In all contexts except the TEXT, BYTE or DB statement, the first character or two of the string constant are all that are used. The rest is ignored. Noting that the ASCII codes for "A" and "B" are $41 and $42, respectively, will explain the following examples:
```
                  "" and ''           evaluate to $0000
                  "A" and 'A'         evaluate to $0041
                  "AB"                evaluates to $4142
```
Note that the null string "" is legal and evaluates to $0000.

The escape, '\' or "backslash" syntax is a shorthand to allow embedding control codes and literal byte values in a text string.
```
        Seq    Hex    ASCII definition
        \a     07     Alert (Beep, Bell)
        \b     08     Backspace
        \f     0C     Form feed
        \n     0A     Newline (Line Feed)
        \r     0D     Carriage Return
        \t     09     Horizontal Tab
        \v     0B     Vertical Tab
        \\     5C     A literal backslash character, ('\')
        \'     27     Single quote
        \"     22     Double quote
        \nnn   any    Literal byte of value nnn, (octal)
        \xhh   any    Literal byte value hh (hex)
```
 Unsupported sequences are flagged as `Error \`.

A '\0' would confuse the assembler as it uses null to terminate strings.

## 2.4 Expressions

An expression is made up of labels, numeric constants, and string constants glued together with arithmetic operators, logical operators, and parentheses in the usual way that algebraic expressions are made. Operators have the following fairly natural order of precedence:
```
             Highest        anything in parentheses
                            unary +, unary -
                            *, /, MOD, SHL, SHR
                            binary +, binary -
                            LT, LE, EQ, GE, GT, NE
                            NOT
                            AND
                            OR, XOR
             Lowest         HIGH, LOW, .0, .1
```
A few notes about the various operators are in order:

- The remainder operator MOD yields the remainder from dividing its left operand by its right operand.
- The shifting operators SHL and SHR shift their left operand to the left or right the number of bits specified by their right operand.
- The relational operators LT, LE, EQ, GE, GT, and NE can also be written as <, <= or =<, =, >= or =>, and <> or ><, respectively. They evaluate to 0FFFFH if the statement is true, 0 otherwise.
- The logical operators NOT, AND, OR, and XOR do bitwise operations on their operand(s).
- HIGH or .1, and LOW or .0, extract the high or low byte of an expression or symbol. HIGH/LOW precede and .1/.0 follow.
- The special symbol $ can be used in place of a label or constant to represent the value of the program counter before any of the current line has been processed.

Some examples are in order at this point:
```
             2 + 3 * 4                          evaluates to 14
             (2 + 3) * 4                        evaluates to 20
             NOT %11110000 XOR %00001010        evaluates to %00000101
             HIGH 1234H SHL 1                   evaluates to $0024
             [value].1                          is high byte of [value]
             001Q EQ 0                          evaluates to 0
             001Q = 2 SHR 1                     evaluates to $FFFF
```
All arithmetic is unsigned with overflow from the 16-bit word ignored. Thus:

             32768 * 2                          evaluates to 0


## Machine Opcodes

The opcodes of the 1802 and 1805A processors are divided into groups below by the type of arguments required in the argument field of the source line. Opcodes that are peculiar to the 1805A are marked with an asterisk. If an opcode requires multiple arguments, these must be placed in the argument field in order and separated by commas.


3.1 Opcodes -- No Arguments

The following opcodes allow no arguments at all in their argument fields:

             ADC       ADD       AND       CID *     CIE *     DADC *
             DADD *    DIS       DSAV *    DSM *     DSMB *    DTC *
             ETQ *     GEC *     IDL       IRX       LDC *     LDX
             LDXA      LSDF      LSIE      LSKP      LSNF      LSNQ
             LSNZ      LSQ       LSZ       MARK      NOP       OR
             REQ       RET       RSHL      RSHR      SAV       SCM1 *
             SCM2 *    SD        SDB       SEQ       SHL       SHLC
             SHR       SHRC      SKP       SM        SMB       SPM1 *
             SPM2 *    STM *     STPC *    STXD      XID *     XIE *
                                 XOR

## Pseudo Opcodes
Unlike 1802/1805A opcodes, pseudo opcodes (pseudo-ops) do not represent machine instructions. They are, rather, directives to the assembler. These directives require various numbers and types of arguments. They will be listed individually below.

### Pseudo-ops -- BLK, DS
The BLK or DS pseudo-op reserves a block of storage for program variables, or whatever. This storage is not initialized in the Intel or RCA M file; any hex-loader will not load those locations. In the binary file, the binary will be filled with FF's. The argument expression (which may contain no forward references) is added to the assembly program counter. The following statement would reserve 10 bytes of storage called "STORAGE":
```
             STORAGE   BLK       10
```

### Pseudo-ops -- BYTE, DB

The BYTE pseudo-op allows arbitrary bytes to be set into the object code. Its argument is a chain of zero or more expressions that evaluate to -128 through 255 separated by commas. If a comma occurs with no preceding expression, a 00H byte is spliced into the object code. The sequence of bytes 0FEH, 0FFH, 00H, 01H, 02H is assembled with the statement:
```
                       BYTE      -2, -1, , 1, 2
```
(Strings are also accepted as arguments to BYTE/DB.)

### Pseudo-ops -- CPU

By default, the assembler does not recognize the additional opcodes of the 1805A or 1806 CPU. This prevents the assembler from generating invalid 1802 object code. The additional 1805A & 1806 opcodes are turned on and off by this pseudo-op which requires one argument whose value is either 1802 or 1805 (decimal). Thus:
```
                       CPU       1802      ;turns additional opcodes off
                       CPU       1805      ;turns additional opcodes on
```

### Pseudo-ops -- CALL, RETN

RCA's "Standard Call and Return" or SCRT, use registers R4 and R5 to support subroutine call and return. `CALL <value>` produces a `SEP R4` instruction (D4H) followed by a 16-bit address value which should be the address of the called subroutine. `RETN` produces a `SEP R5` instruction (D5H). R4 and R5 "should" be set up with addresses for call/return subroutine support, typically R2 is the stack register.

Note that the 1804/5 processor includes `SCAL Rn` and `SRET Rn` instructions which push low-byte first while common SCRT support code pushes high-byte first.

### Pseudo-ops -- EJCT

 The EJCT pseudo-op always causes an immediate page ejection in the listing by inserting a form feed ('\f') character before the next line. If an argument is specified, the argument expression specifies the number of lines per page in the listing. Legal values for the expression are any number except 1 and 2. A value of 0 turns the listing pagination off. Thus, the following statement cause a page ejection and would divide the listing into 60-line pages:
```
                       EJCT      60 
```

### Pseudo-ops -- END
The END pseudo-op tells the assembler that the source program is over. Any further lines of the source file are ignored and not passed on to the listing. If an argument is added to the END statement, the value of the argument will be placed in the execution address record in the Intel hex object file. If there's no value, the address defaults to the current address. to specify the program starts at label START: 
```
                       END       START
```
 If there no END statement, the assembler will add an END 
 statement and flag it with an `Error *` (missing statement) error.

### Pseudo-ops -- EQU

The EQU pseudo-op is used to assign a specific value to a label, thus the label on this line is REQUIRED. Once the value is assigned, it cannot be reassigned by writing the label in column 1, by another EQU statement, or by a SET statement. Thus, for example, the following statement assigns the value 2 to the label TWO:
```
             TWO       EQU       1 + 1
```
The expression in the argument field must contain no forward references.

### Pseudo-ops -- FILL value, count

The FILL pseudo-op is a define-byte for a given count of locations in the assembled results. The byte value in the first argument for FILL, is repeated for the count given in the second argument. Thus:
```
                       FILL 00, 20
```
will fill the next 20 bytes in the output file with value 00H. The maximum count of values is defined in the assembler as `MAXLINE (255)`. If the value is too large, zero is used. Both value and count are necessary.

### Pseudo-ops -- IF, ELSE, ENDI

These three pseudo-ops allow the assembler to choose whether or not to assemble certain blocks of code based on the result of an expression. Code that is not assembled is passed through to the listing but otherwise ignored by the assembler. The IF pseudo-op signals the beginning of a conditionally assembled block. It requires one argument that may contain no forward references. If the argument is non-zero or undefined, the block is assembled. Otherwise, the block is ignored. The ENDI pseudo-op signals the end of the conditionally assembled block. For example:
```
                       IF   EXPRESSION     ;This whole thing generates
                       BYTE 01H, 02H, 03H  ;  no code whatsoever if
                       ENDI                ;  EXPRESSION is zero.
```
The ELSE pseudo-op allows the assembly of either one of two blocks, but not both. The following two sequences are equivalent:
```
                       IF   EXPRESSION
                       ... some stuff ...
                       ELSE
                       ... some more stuff ...
                       ENDI

             TEMP_LAB  SET  EXPRESSION
                       IF   TEMP_LAB NE 0
                       ... some stuff ...
                       ENDI
                       IF   TEMP_LAB EQ 0
                       ... some more stuff ...
                       ENDI
```
The pseudo-ops in this group do NOT permit labels to exist on the same line as the status of the label (ignored or not) would be ambiguous.

All IF statements (even those in ignored conditionally assembled blocks) must have corresponding ENDI statements and all ELSE and ENDI statements must have a corresponding IF statement.

IF blocks can be nested up to 16 levels deep before the assembler dies of a fatal error. This should be adequate for any conceivable job, but if you need more, change the constant IFDEPTH in file A18.H and recompile the assembler.

### Pseudo-ops -- INCL

The INCL pseudo-op is used to splice the contents of another file into the current file at assembly time. The name of the file to be INCLuded is specified as a normal string constant, so the following line would splice the contents of file "const.def" into the source code stream:
```
                       INCL      "const.def"
```
INCLuded files may, in turn, INCLude other files until four files are open simultaneously. This limit should be enough for any conceivable job, but if you need more, change the constant FILES in file A18.H and recompile the assembler.

### Pseudo-ops -- LOAD

This pseudo-op is a built-in macro that makes up for the 1802's lack of the RLDI instruction. The very common function of loading a 16-bit immediate value into a register is normally done with the following 4-line sequence:
```
                       LDI       HIGH VALUE
                       PHI       REGISTER
                       LDI       LOW VALUE
                       PLO       REGISTER
```
This pseudo-op reduces the above sequence to the following line:
```
                       LOAD      REGISTER, VALUE
```
Note that this construct blows away the contents of the D register whereas the 1805A's RLDI instruction blows away the T register and leaves the D register intact.

### Pseudo-ops -- ORG

 The ORG pseudo-op is used to set the assembly program counter to a particular value. The expression that defines this value may contain no forward references. The default initial value of the assembly program counter is 0000H. The following statement would change the assembly program counter to 0F000H:
```
                       ORG       0F000H
```
If a label is present on the same line as an ORG statement, it is assigned the new value of the assembly program counter. See "Fatal Error -- Binary Address Backwards" for details on how the assembler may fill the binary file with FFs between ORG's.

### Pseudo-ops -- PAGE

This pseudo-op is a built-in macro for a very common use of the ORG pseudo-op, i.e. setting the assembly program counter to the first address of the next 256-byte page. The long-hand form using the ORG pseudo-op is:
```
                       ORG       ($ + 255) AND 0FF00H
```
The short form is:
```
                       PAGE
```
Note that this pseudo-op has no effect if the assembly counter is already at the beginning of a 256-byte page. If it has an effect, the binary will be filled with FF's from end of code to start of the next page. 

### Pseudo-ops -- SET

The SET pseudo-op functions like the EQU pseudo-op except that the SET statement can reassign the value of a label that has already been assigned by another SET statement. Like the EQU statement, the argument expression may contain no forward references. A label defined by a SET statement cannot be redefined by writing it in column 1 or with an EQU statement. The following series of statements would set the value of label "COUNT" to 1, 2, then 3:
```
             COUNT     SET       1
             COUNT     SET       2
             COUNT     SET       3
```

### Pseudo-ops -- TEXT

The TEXT pseudo-op allows character strings to be spliced into the object code. Its argument is a chain of zero or more string constants separated by blanks, tabs, or commas. If a comma occurs with no preceding string constant, an S (syntax) error results. The string constants are not truncated to two bytes, but are instead copied verbatim into the object code. Null strings result in no bytes of code. The message "Kaboom!!" could be spliced into the code with the following statement:

```
                       TEXT      "Kaboom!!"     ;This is 8 bytes of code.
```

### Pseudo-ops -- TITL

The TITL pseudo-op sets the running title for the listing. The argument field is required and must be a string constant, though the null string ("") is legal. This title is printed after every page ejection in the listing, therefore, if page ejections have not been forced by the PAGE pseudo-op, the title will never be printed. The following statement would print the title "Random Bug Generator -- Ver 3.14159" at the top of every page of the listing:
```
                       TITL      "Random Bug Generator -- Ver 3.14159"
```

### Pseudo-ops -- WORD, DW

The WORD or DW pseudo-op accepts 16-bit words into the object code. Its argument is a chain of zero or more expressions separated by commas. If a comma occurs with no preceding expression, a word of 0000H is spliced into the code. The word is placed into memory high byte in low address, low byte in high address as per standard Motorola order. The sequence of bytes 0FEH, 0FFH, 00H, 00H, 01H, 02H could be spliced into the code with the following statement:
```
                       WORD      0FEFFH, , 0102H
```

## Assembly Errors

When a source line contains an illegal construct, the line is flagged in the listing with a single-letter code describing the error. The meaning of each code is listed below. In addition, a count of the number of lines with errors is kept and printed on the C "stderr" device (by default, the console) after the END statement is processed. If more than one error occurs in a given line, only the first is reported. For example, the illegal label "=$#*'(" would generate the following listing line:
```
             L  0000   FF 00 00      =$#*'(     LDA       R0
```

### Error * -- Illegal or Missing Statement

This error occurs when either:

- the assembler reaches the end of the source file without seeing an END statement, or
- an END statement is encountered in an INCLude file.

If you are "sure" that the END statement is present when the assembler thinks that it is missing, it probably is in the ignored section of an IF block. If the END statement is missing, supply it. If the END statement is in an INCLude file, delete it.

### Error ( -- Parenthesis Imbalance

For every left parenthesis, there must be a right parenthesis.

### Error " -- Missing Quotation Mark

Strings have to begin and end with either " or '. Remember that " only matches " while ' only matches '.

### Error B -- Branch Target Too Distant

The short branch instructions will only reach bytes that are on the same 256-byte page as the LAST (address) byte of the branch instruction. If this error occurs, the source code will have to be rearranged to bring the branch target onto the correct page or a long branch instruction that will reach anywhere will have to be used.

### Error D -- Illegal Digit

This error occurs if a digit greater than or equal to the base of a numeric constant is found. For example, a 2 in a binary number would cause a D error. Especially, watch for 8 or 9 in an octal number.

### Error E -- Illegal Expression
This error occurs because of:

- a missing expression where one is required
- a unary operator used as a binary operator or vice-versa
- a missing binary operator
- a SHL or SHR count that is not 0 thru 15

### Error I -- IF-ENDI Imbalance

For every IF there must be a corresponding ENDI. If this error occurs on an ELSE or ENDI statement, the corresponding IF is missing. If this error occurs on an END statement, one or more ENDI statements are missing.

### Error L -- Illegal Label
This error occurs because of:

- a non-alphabetic in column 1
- a reserved word used as a label
- a missing label on an EQU or SET statement
- a label on an IF, ELSE, or ENDI statement

### Error M -- Multiply Defined Label

This error occurs because of:

- a label defined in column 1 or with the EQU statement being redefined
- a label defined by a SET statement being redefined either in column 1 or with the EQU statement
- the value of the label changing between assembly passes

### Error O -- Illegal Opcode

The opcode field of a source line may contain only a valid machine opcode, a valid pseudo-op, or nothing at all. Anything else causes this error. Note that the unique 1805A opcodes are not valid until they are enabled with the CPU statement.

### Error P -- Phasing Error
 This error occurs because of:

- a forward reference in a BLK, CPU, EQU, ORG, or SET statement
- a label disappearing between assembly passes

### Error R -- Illegal Register
This error occurs when a register argument is not in the range 0 - 15 (1 - 15 for LDN) or when an I/O port argument is not in the range 1 - 7.

### Error S -- Illegal Syntax
This error means that an argument field is scrambled. Sort the mess out and reassemble.

### Error T -- Too Many Arguments
This error occurs if there are more items (expressions, register designators, etc.) in the argument field than the opcode or pseudo-op requires. The assembler ignores the extra items but issues this error in case something is really mangled.

### Error U -- Undefined Label
This error occurs if a label is referenced in an expression but not defined anywhere in the source program. If you are "sure" you have defined the label, note that upper and lower case letters in labels are different. Defining "LABEL" does not define "Label."

### Error V -- Illegal Value
This error occurs because:
- an immediate value is not -128 thru 255, or
- a BYTE argument is not -128 thru 255, or
- a CPU argument is not 1802 and not 1805, or
- an INCL argument refers to a file that does not exist.

### Error \ -- Illegal Escape Value

A quoted backslash escape value is not supported. The assembler passes the character value but flags an error.

## Warning Messages

Some errors that occur during the parsing of the cross-assembler command line are non-fatal. The cross-assembler flags these with a message on the C "stdout" device (by default, the console) beginning with the word "Warning." The messages are listed below:

### Warning -- Illegal Option Ignored
The only options that the cross-assembler knows are -l and -o. Any other command line argument beginning with - will draw this error.

### Warning -- -l[-o, -b] Option Ignored -- No File Name 
The -l and -o and - b options require a file name to tell the assembler where to put the files. If this file name is missing, the option is ignored.

### Warning -- Extra Source File Ignored
The cross-assembler will only assemble one file at a time, so source file names after the first are ignored.

### Warning -- Extra Listing/Object/Binary File Ignored
The cross-assembler will only generate one listing, object, and binary file per assembly run, so -l and -o and -b options after the first are ignored.

### Warning -- Object file filled with 00's
See the Fatal Error - Binary Address Backwards for details. The assembler will fill gaps in the assembled binary with FF's. The hex  file is not filled as every hex record is complete.

## Fatal Error Messages
Several errors that occur during the parsing of the cross-assembler command line or during the assembly run are fatal. The cross-assembler flags these with a message on the C "stdout" device (by default, the console) beginning with the words "Fatal Error."

### Fatal Error -- No Source File Specified
This one is self-explanatory. The assembler does not know what to assemble.

### Fatal Error -- Source File Did Not Open
The assembler could not open the source file. The most likely cause is that the source file as specified on the command line does not exist. On larger systems, there could also be privilege violations. Rarely, a read error in the disk directory could cause this error.

### Fatal Error -- Listing File Did Not Open
### Fatal Error -- Object File Did Not Open

This error indicates either a defective listing or object file name or a full disk directory. Correct the file name or make more room on the disk.

### Fatal Error -- Error Reading Source File
This error generally indicates a read error in the disk data space. Use your backup copy of the source file (You do have one, don't you?) to recreate the mangled file and reassemble.

### Fatal Error -- Disk or Directory Full
This one is self-explanatory. Some more space must be found either by deleting files or by using a disk with more room on it.

### Fatal Error -- File Stack Overflow
This error occurs if you exceed the INCLude file limit of four files open simultaneously. This limit can be increased by increasing the constant FILES in file A18.H and recompiling the cross-assembler.

### Fatal Error -- If Stack Overflow
This error occurs if you exceed the nesting limit of 16 IF blocks. This limit can be increased by increasing the constant IFDEPTH in file A18.H and recompiling the cross-assembler.

### Fatal Error -- Too Many Symbols
Congratulations! You have run out of memory. The space for the cross-assembler's symbol table is allocated at run-time using the C library function alloc(), so the cross-assembler will use all available memory. The only solutions to this problem are to lessen the number of labels in the source program or to add more memory.

### Fatal Error -- Binary Address Backwards 
The binary file is filled by the assembler, from the source code as assembled. But binary files must be continuous, from start to end. The start is either 0000H by default, or the first ORG before code is generated. If there's an ORG, PAGE or other pseudo-op that advances the address of generated code AND there's a lack of code or data before that address, the assembler will fill the gap with FF's, and send a warning message to the command line console. If there was no fill, the binary would be "broken" and there would be no information in the binary as to where it's broken. 

The "fatal error" is if an ORG or other command, moves the address "backwards", to an address where a binary was already generated. The assembler can't back up, or overwrite binary code/data! So I choose to call an error and stop assembly. Look at the source, or whatever fragments of the listing and hex files occur, to look for a bad ORG or PAGE or other such error. 
 
