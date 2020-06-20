#!/usr/bin/make -f

TARGET := test
keyID = francois.willame@gmail.com

-include Makefile.defs

DATE := $(shell date -I)
DTARGET := $(TARGET).$(DATE).tsv

SRC_DIR	= dagbok
XLS_FILES = $(wildcard $(SRC_DIR)/*.xlsx)					# alternativ 1
#XLS_FILES := $(shell find -L $(SRC_DIR) -name '*.xlsx')		# alternativ 2

all:$(DTARGET)

$(DTARGET):
	find -L $(SRC_DIR)  -name '*.xls' -o -name '*.xlsx' -exec in2csv --write-sheets "-" {}  \;
	find -L $(SRC_DIR) -name '*.csv' -exec ./logbook.awk {} > $@ \;
	echo "$@ done"

# options for in2csv  --date-format "%Y-%m-%d" --datetime-format "%Y-%m-%d %H:%M:%S"

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
