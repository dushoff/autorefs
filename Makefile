### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: test.int 

##################################################################

Sources = Makefile 

##################################################################

PUSH = perl -wf $(filter %.pl, $^) $(filter-out %.pl, $^) > $@

export autorefs = ../autorefs
export bib = ~/Dropbox/bib

# Make a bib file from .rmu
# pm.pl calls make -f %.bibrec, which in turn calls the stuff below

Sources += int.pl test.rmu
test.int: test.rmu int.pl
	$(PUSH)
%.int: %.rmu int.pl
	$(PUSH)

test.bib: test.rmu pm.pl
	$(PUSH)

%.bib: %.rmu pm.pl
	$(PUSH)

# Use a protected program that's allowed to access pubmed, just to look up the PMID and dump it
PM%.med: pmed.pl
	$< $* > $@

# Convert .med to a friendlier format (.mdl) that can be read by programs below
%.mdl.raw: %.med mm.pl
	$(PUSH)

# corr.pl parses a corrections file, if it exists, and makes the "real" .mdl file
%.mdl: %.mdl.raw %.corr corr.pl
	$(PUSH)

# Make needs to _think_ it knows how to make .corr
%.corr:
	echo Pretending to make $@
	touch $@

# Convert .mdl to .bibrec; these are individual files (one per article) that can be concatenated to make a .bib file
%.bibrec: %.mdl mbib.pl
	$(PUSH)

# Convert .mdl to an individual .wt file, which will be interpolated into the wikitext rendering.  The logic here should be changed and made more flexible, but not very soon, I guess.
%.wt: %.mdl mw.pl
	$(PUSH)

%.pubs.wt: %.mdl pubs.pl
	$(PUSH)

delete_empty:
	grep -l "backend-exception" *.med | xargs -i /bin/rm '{}'

delete_bibrec:
	/bin/rm -f */*.bibrec

# Allow raw bibtex in .rmu files, and parse it into .bib files

%.raw.bib: %.rmu rawbib.pl
	$(PUSH)

%.comp.bib: %.bib %.raw.bib
	cat $^ > $@

##### Developing a non-pubmed stream

######################################################################

md = ../make/

local = default
-include $(md)/local.mk
include $(md)/$(local).mk

