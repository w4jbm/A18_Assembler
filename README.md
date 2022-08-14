# A18_Assembler

This is just a copy of Herb Johnson's modifications William C Colley III's A18 assembler as found [on Herb's website](https://www.retrotechnology.com/memship/a18.html).

I would recommend always going to the webside and this is only here as a way for me to install A18 quickly on the various Linux boxes I have.

Installation only requires a few simple shell commands from the user's Programs or Software subdirectory:
```
$ git clone https://github.com/w4jbm/A18_Assembler
$ cd A18_Assembler
$ chmod +x install.sh
$ ./install.sh
```
The only trickery in the script is to remove any previous symlink to A18 before the new one is installed without throwing an error if one does not already exist.
