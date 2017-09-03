### autorefs

### Well, python is not as smooth as I would have thought ... also, I like the idea of downloading things once. We are back here and trying to expand to DOIs
#### I had tried to switch to a python/entrez approach. Good thing I didn't record where I did that work!

### Hooks 
current: target
-include target.mk

##################################################################

Sources = Makefile sub.mk inc.mk .gitignore

Sources += makestuff

include sub.mk
-include $(ms)/perl.def

##################################################################

ifndef Drop
Drop = ~/Dropbox
endif

ifndef autorefs
autorefs = .
endif

export bib = $(autorefs)/bib

Makefile: bib

$(bib): 
	(touch $(Drop)/autorefs/testfile && $(LNF) $(Drop)/autorefs $@) || mkdir $@

######################################################################

Sources += $(wildcard *.pl)

Sources += notes.txt

# Make a bib file from .rmu
# .bibrec is called via .bibmk, and kicks off the rest of the chain.
# DOI stuff is kind of working ...

## Parse the .rmu file into something with "integrated" tags (IOW, understand both doi and pubmed references)
Sources += test.rmu
# test.int: test.rmu int.pl
%.int: %.rmu $(autorefs)/int.pl
	$(PUSH)

## Make variables so that we can refer to doi identifiers
%.point: %.int $(autorefs)/point.pl
	$(PUSH)

######################################################################

## Output formats; first make records, then files

###### .bib #######

## bibrec is a single bibliographic record made from info in .mdl
%.bibrec: %.mdl $(autorefs)/mbib.pl
	$(PUSH)

%.bibmk: %.int $(autorefs)/mkmk.pl
	$(call PUSHARGS, bibrec)

## Unresolved craziness in NSERC proposal; this rule does not seem to work. Touching .rmu and making .int both fail to put .bib out of date.
.PRECIOUS: %.bib
%.bib: %.int $(autorefs)/pm.pl
	$(MAKE) $*.bibmk
	$(MAKE) $*.point
	$(MAKE) -f $*.point -f $*.bibmk -f $(autorefs)/Makefile bibrec
	$(PUSH)

###### .ref #######

## This makes some sort of simple reference list and seems a bit deprecated. Probably doesn't work for DOIs, but might be a simple fix.
%.refrec: %.mdl $(autorefs)/mref.pl
	$(PUSH)

%.refmk: %.int $(autorefs)/refmk.pl
	$(PUSH)

%.ref: %.int $(autorefs)/ir.pl
	$(MAKE) $*.refmk
	$(MAKE) -f $*.refmk -f $(autorefs)/Makefile refrec
	$(PUSH)

###### .md #######

## Now trying to make a markdown version
## First get the pipeline going, then look for hints from wikitext version on wiki
## In the middle of all this; also, it doesn't seem right, because the markdown should ideally incorporate _text_ from the .rmu (otherwise, why all that work making rmus?

%.mdrec: %.mdl $(autorefs)/mdrec.pl
	$(PUSH)

%.mdmk: %.int $(autorefs)/mdmk.pl
	$(PUSH)

%.md: %.int $(autorefs)/md.pl
	$(MAKE) $*.bib
	$(MAKE) $*.mdmk
	$(MAKE) -f $*.mdmk -f $(autorefs)/Makefile mdrec
	$(PUSH)

######################################################################

## .med is a raw MEDLINE formatted download
## Needed to change just some bib -> $(bib) and only need it sometimes!
.PRECIOUS: $(bib)/%.pm.med
$(bib)/%.pm.med: $(bib)
	wget -O $@ "http://www.ncbi.nlm.nih.gov/pubmed/$*?dopt=MEDLINE&output=txt"

.PRECIOUS: $(bib)/%.doi.med
$(bib)/%.doi.med: $(bib)
	curl -o $@ -LH "Accept: application/x-research-info-systems" "http://dx.doi.org/$($*)"

## Corrections

# To make a correction (or to disambiguate), copy mdl to a .corr file (which we will push)
# ~/Dropbox/bib/98ccd4a361cfed7df91966e068af4ce4.doi.mdl

dcorr: 98ccd4a361cfed7df91966e068af4ce4.doi.corr

## Updated not tested! 27 Jun '17
corr: 19393959.pm.corr
%.corr: 
	$(MAKE) $(bib)/$*.mdl
	$(MV) $(bib)/$*.mdl $@
	$(EDIT) $@
	$(CP) $@ $(bib)/$*.mdl

Sources += $(wildcard *.corr)

## mdl has parsed fields from .med joined using #AND#
## it also has a default tag created from author and date
## as of 2016 the script attempts to "fill" using second choices
.PRECIOUS: $(bib)/%.mdl
$(bib)/%.mdl: $(bib)/%.med $(autorefs)/mm.pl
	$(CP) $*.corr $@ || $(PUSH)

%.rmk:
	$(RM) $*
	$(MAKE) $*

include $(ms)/git.mk
include $(ms)/visual.mk
