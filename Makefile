### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: test.bib 

##################################################################

Sources = Makefile inc.mk

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
%.bibmk: %.int $(autorefs)/bibmk.pl
	$(PUSH)

Sources += pm.pl
%.bib: %.int $(autorefs)/pm.pl
	$(MAKE) $*.bibmk
	$(MAKE) -f $*.bibmk -f $(autorefs)/Makefile bibrec
	$(PUSH)

.PRECIOUS: $(bib)/%.pm.med
$(bib)/%.pm.med:
	wget -O $@ "http://www.ncbi.nlm.nih.gov/pubmed/$*?dopt=MEDLINE&output=txt"

Sources += $(wildcard corr/*.mdl)
.PRECIOUS: $(bib)/%.mdl
$(bib)/%.mdl: $(autorefs)/corr/%.mdl
	/bin/cp -f $< $@

Sources += mm.pl
%.mdl: %.med $(autorefs)/mm.pl
	$(PUSH)

Sources += mbib.pl
%.bibrec: %.mdl $(autorefs)/mbib.pl
	$(PUSH)

######################################################################

md = ../make/

local = default
-include $(md)/local.mk
include $(md)/$(local).mk

