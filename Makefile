### This project needs to be abandoned. Now making horrible stuff to do text in parallel with .bib for the new CIHR framework. Redo with python/entrez, I think.

### Well, python is not as smooth as I would have thought ... also, I like the idea of downloading things once. We are back here and trying to expand to DOIs

### autorefs
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: bib/8dfd560898103e0431e252b0116bc651.doi.mdl 

##################################################################

Sources = Makefile stuff.mk inc.mk .gitignore

include stuff.mk
-include $(ms)/perl.def

##################################################################


bib/8dfd560898103e0431e252b0116bc651.doi.mdl: mm.pl

# Keep files and do corrections in a local or Dropbox directory.
# Or a repo for a specific project.
# The idea is to let people do disambiguation their own way.

export bib = ~/Dropbox/bib

Makefile: bib

bib: $(bib)
	$(forcelink)

$(bib):
	mkdir $@

######################################################################

# Make a bib file from .rmu
# .bibrec is called via .bibmk, and kicks off the rest of the chain.
# DOI stuff is kind of working, but seems fragile. Leave it out for now.

Sources += int.pl test.rmu
# test.int: test.rmu int.pl
%.int: %.rmu $(autorefs)/int.pl
	$(PUSH)

Sources += refmk.pl
%.refmk: %.int $(autorefs)/refmk.pl
	$(PUSH)

Sources += bibmk.pl
%.bibmk: %.int $(autorefs)/bibmk.pl
	$(PUSH)

Sources += point.pl
%.point: %.int $(autorefs)/point.pl
	$(PUSH)

## Unresolved craziness in NSERC proposal; this rule does not seem to work. Touching .rmu and making .int both fail to put .bib out of date.
Sources += pm.pl
.PRECIOUS: %.bib
%.bib: %.int $(autorefs)/pm.pl
	$(MAKE) $*.bibmk
	$(MAKE) $*.point
	$(MAKE) -f $*.point -f $*.bibmk -f $(autorefs)/Makefile bibrec
	$(PUSH)

## This makes some sort of simple reference list and seems a bit deprecated
Sources += ir.pl
%.ref: %.int $(autorefs)/ir.pl
	$(MAKE) $*.refmk
	$(MAKE) -f $*.refmk -f $(autorefs)/Makefile refrec
	$(PUSH)

.PRECIOUS: bib/%.pm.med
bib/%.pm.med:
	wget -O $@ "http://www.ncbi.nlm.nih.gov/pubmed/$*?dopt=MEDLINE&output=txt"

.PRECIOUS: bib/%.doi.med
bib/%.doi.med:
	curl -o $@ -LH "Accept: application/x-research-info-systems" "http://dx.doi.org/$($*)"

temp: 24026815.pm.corr
# To make a correction (or to disambiguate), copy the file in the bib directory (so we have a record) and then edit it.
%.corr: bib/%.mdl
	/bin/cp $< $<.orig
	gvim $<

Sources += mm.pl
.PRECIOUS: %.mdl
%.mdl: %.med $(autorefs)/mm.pl
	$(PUSH)

Sources += mbib.pl
%.bibrec: %.mdl $(autorefs)/mbib.pl
	$(PUSH)

Sources += mref.pl
%.refrec: %.mdl $(autorefs)/mref.pl
	$(PUSH)

include $(ms)/git.mk
include $(ms)/visual.mk
