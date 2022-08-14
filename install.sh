#!/bin/bash
#
# Simple install script for A18
#
gcc -I. -o a18 a18.c a18util.c a18eval.c
rm -rf /usr/local/bin/a18 || true
sudo ln -s $HOME/Software/A18_Assembler/a18 /usr/local/bin/a18
chmod +x a18
