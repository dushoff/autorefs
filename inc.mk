%.bib %.int %.bibmk: %.rmu
	$(MAKE) -f $(autorefs)/Makefile $@
