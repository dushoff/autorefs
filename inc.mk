
rmulist = $(wildcard *.pmr)
Ignore += $(rmulist:.pmr=.rmu)
%.rmu: %.pmr
	perl -wf $(autorefs)/nodoi.pl $< > $@

rmulist = $(wildcard *.rmu)
Ignore += $(rmulist:.rmu=.bib)
Ignore += *.int *.bibmk *.point
%.bib %.int %.bibmk %.point: %.rmu
	$(MAKE) -f $(autorefs)/Makefile $@

Ignore += *.ref *.int
%.ref %.int %.refmk: %.rmu
	$(MAKE) -f $(autorefs)/Makefile $@

Ignore += *.md *.mdmk
%.md %.mdmk: %.rmu
	$(MAKE) -f $(autorefs)/Makefile $@
