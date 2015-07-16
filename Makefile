### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: notarget

##################################################################

# make files

md = ../make/

# local.mk should not be a source file; use it so reset the value of the variable local

Sources = Makefile 

##################################################################

local = default
-include $(md)/local.mk
include $(md)/$(local).mk

