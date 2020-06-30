#!/usr/bin/make -f

TARGET := test
keyID = francois.willame@gmail.com

-include Makefile.defs

DATE := $(shell date -I)
DTARGET := $(TARGET).$(DATE)

# with in2csv
xls2csv1: clean-csv
	find .  -name "*.xls" -o -name "*.xlsx" -exec in2csv -t --write-sheets "-" {}  \;

# with ssconvert (gnumeric) and exec
xls2csv2: clean-csv
	find .  -name "*.xls" -o -name "*.xlsx" -exec ssconvert --import-encoding=UTF-8 -S {} {}.%s.csv  \;  # 2>/dev/null


# with ssconvert (gnumeric) and xargs
xls2csv3: clean-csv
	find .  -name "*.xls" -o -name "*.xlsx" | xargs -I{} ssconvert -S {} $(patsubst %.xlsx,%.,{}).%s.csv

#%.csv : %.xlsx
#	echo $<
#	echo $@
#	echo $(patsubst %.csv,%.,$@)%s.csv
#	echo ssconvert -S $< $(patsubst %.csv,%.,$@)%s.csv 2>/dev/null

#csv2tsv: xls2csv
#	find .  -name '*.csv' | ./logbook.awk > $(DTARGET)

all: $(DTARGET).in2csv.tsv $(DTARGET).ssconvert.tsv

$(DTARGET).in2csv.tsv: xls2csv1
	find . -name '*.csv' -exec ./logbook.in2csv.awk {} > $@ \;
	@echo "$@ done"


$(DTARGET).ssconvert.tsv: xls2csv2
	find . -name '*.csv' -exec ./logbook.ssconvert.awk {} > $@ \;
	@echo "$@ done"

clean: clean-csv clean-tsv
	tree

clean-csv:
	find . -type f -name '*.csv' -exec rm -f {}  \;

clean-tsv:
	find . -type f -name '*.tsv' -exec rm -f {}  \;

push: $(DTARGET).in2csv.tsv $(DTARGET).ssconvert.tsv
	scp $^ $(USER)@$(HOST):$(PUBDIR)
	@echo "upload done"

pull:
	@echo "download from ..."

encrypt: Makefile.defs
	cat $< | gpg -ear $(keyID) -o $<.gpg
	rm $<

decrypt: Makefile.defs.gpg
	cat $< | gpg -dr $(keyID) -o $(patsubst %.gpg,%,$<)
	rm $<
