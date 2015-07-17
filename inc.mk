%.bib %.int %.bibmk: 
	$(MAKE) -f $(autorefs)/Makefile $@
