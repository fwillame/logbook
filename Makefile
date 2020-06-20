#!/usr/bin/make -f

TARGET := test
keyID = francois.willame@gmail.com

-include Makefile.defs

DATE := $(shell date -I)
DTARGET := $(TARGET).$(DATE).tsv

SRC_DIR	= dagbok
XLS_FILES = $(wildcard $(SRC_DIR)/*.xlsx)					# alternativ 1
#XLS_FILES := $(shell find -L $(SRC_DIR) -name '*.xlsx')		# alternativ 2

# converting the xlsx to csv files
# unoconv -f csv bla.xlxs
# https://linoxide.com/linux-how-to/methods-convert-xlsx-format-files-csv-linux-cli/
# using gnumeric
# ssconvert -S Dagbok\ FSE613\ 2020\ V20.xlsx test.%s.csv
# ssconvert -S Dagbok\ FSE613\ 2020\ V20.xlsx test.%s.csv
# https://stackoverflow.com/questions/22419979/how-do-i-convert-a-tab-separated-values-tsv-file-to-a-comma-separated-values
# using in2csv
# https://csvkit.readthedocs.io/en/0.9.0/tutorial/1_getting_started.html#in2csv-the-excel-killer

all:$(DTARGET)

$(DTARGET):
	find -L $(SRC_DIR)  -name '*.xls' -o -name '*.xlsx' -exec in2csv --write-sheets "-" {}  \;
	find -L $(SRC_DIR) -name '*.csv' -exec ./logbook.awk {} > $@ \;
	echo "$@ done"

# --date-format "%Y-%m-%d" --datetime-format "%Y-%m-%d %H:%M:%S"

test:
	@echo $(XLS_FILES)
	@echo $(CSV_FILES)

clean: clean-csv clean-tsv

clean-csv:
	find . -type f -name '*.csv' -exec rm -f {}  \;

clean-tsv:
	find . -type f -name '*.tsv' -exec rm -f {}  \;

push: $(DTARGET)
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
