%.bib %.int %.bibmk: %.rmu
	$(MAKE) -f $(autorefs)/Makefile $@

%.ref %.int %.refmk: %.rmu
	$(MAKE) -f $(autorefs)/Makefile $@
