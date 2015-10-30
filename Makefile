### autorefs
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: 

##################################################################

Sources = Makefile inc.mk .gitignore

gitroot = ../
-include local.mk
ms = $(gitroot)/makestuff
-include $(gitroot)/local.mk

-include $(ms)/perl.def

## Change this name to download a new version of the makestuff directory
Makefile: start.makestuff

%.makestuff:
	-cd $(dir $(ms)) && mv -f $(notdir $(ms)) .$(notdir $(ms))
	cd $(dir $(ms)) && git clone $(msrepo)/$(notdir $(ms)).git
	-cd $(dir $(ms)) && rm -rf .$(notdir $(ms))
	touch $@

##################################################################

# Keep files and do corrections in a local or Dropbox directory.
# Or a repo for a specific project.
# The idea is to let people do disambiguation their own way.

export bib = ~/Dropbox/bib

Makefile: $(bib)

$(bib):
	mkdir $@

######################################################################

# Make a bib file from .rmu
# pm.pl calls make -f %.bibrec, which in turn calls the stuff below

Sources += int.pl test.rmu
%.int: %.rmu $(autorefs)/int.pl
	$(PUSH)

auto.int: auto.rmu $(autorefs)/int.pl
	$(PUSH)

Sources += bibmk.pl
%.bibmk: %.int $(autorefs)/bibmk.pl
	$(PUSH)

## Unresolved craziness in NSERC proposal; this rule does not seem to work. Touching .rmu and making .int both fail to put .bib out of date.
Sources += pm.pl
%.bib: %.int $(autorefs)/pm.pl
	$(MAKE) $*.bibmk
	$(MAKE) -f $*.bibmk -f $(autorefs)/Makefile bibrec
	$(PUSH)

.PRECIOUS: $(bib)/%.pm.med
$(bib)/%.pm.med:
	wget -O $@ "http://www.ncbi.nlm.nih.gov/pubmed/$*?dopt=MEDLINE&output=txt"

temp: 24026815.pm.corr
# To make a correction (or to disambiguate), copy the file in the bib directory (so we have a record) and then edit it.
%.corr: $(bib)/%.mdl
	$(CPF) $< $<.orig
	$(EDIT) $<

Sources += mm.pl
.PRECIOUS: %.mdl
%.mdl: %.med $(autorefs)/mm.pl
	$(PUSH)

Sources += mbib.pl
%.bibrec: %.mdl $(autorefs)/mbib.pl
	$(PUSH)

include $(ms)/git.mk
include $(ms)/visual.mk
