### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: test.bib 

##################################################################

Sources = Makefile 

##################################################################

PUSH = perl -wf $(filter %.pl, $^) $(filter-out %.pl, $^) > $@
PSTAR = perl -wf $(filter %.pl, $^) $(filter-out %.pl, $^) $@ > $@

export autorefs = ../autorefs
export bib = ~/Dropbox/bib

Makefile: $(bib)

$(bib):
	mkdir $@

# Make a bib file from .rmu
# pm.pl calls make -f %.bibrec, which in turn calls the stuff below

Sources += int.pl test.rmu
%.int: %.rmu $(autorefs)/int.pl
	$(PUSH)

Sources += bibmk.pl
test.bibmk: test.int $(autorefs)/bibmk.pl
	$(PUSH)

Sources += pm.pl
## test.bib: test.int $(autorefs)/pm.pl 
test.bib: test.int pm.pl
	$(MAKE) test.bibmk
	$(MAKE) -f test.bibmk -f Makefile bibrec
	$(PUSH)

.PRECIOUS: $(bib)/%.pm.med
$(bib)/%.pm.med:
	wget -O $@ "http://www.ncbi.nlm.nih.gov/pubmed/$*?dopt=MEDLINE&output=txt"

Sources += $(wildcard *.mdl)
.PRECIOUS: $(bib)/%.mdl
$(bib)/%.mdl: $(autorefs)/%.mdl
	/bin/cp -f $< $@

Sources += mm.pl
%.mdl: %.med mm.pl
	$(PUSH)

Sources += mbib.pl
%.bibrec: %.mdl mbib.pl
	$(PUSH)

######################################################################

md = ../make/

local = default
-include $(md)/local.mk
include $(md)/$(local).mk

