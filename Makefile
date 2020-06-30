#!/usr/bin/make -f

-include Makefile.defs
keyID = francois.willame@gmail.com

SRC_DIR	:= dagbok
OBJ_DIR := temp

TARGET := test

DATE := $(shell date -I)
EXE := $(TARGET).$(DATE).tsv

OBJ = $(wildcard $(OBJ_DIR)/*.xlsx)					# alt 1
#OBJ := $(shell find -L $(OBJ_DIR) -name '*.xlsx')		# alt 2
CSV = $(OBJ:$(OBJ_DIR)/%.xlsx=$(OBJ_DIR)/%.csv)
TXT = $(OBJ:$(OBJ_DIR)/%.xlsx=$(OBJ_DIR)/%.txt)
#TXS = $(patsubst %.txt,%.,$(TXT))%s.txt

#$(OBJ_DIR):
#	mkdir -p $@

$(OBJ_DIR): $(SRC_DIR)
	mkdir -p $@
	rsync -rup $</ $@
	rename "s/ /_/g" $@/*

$(OBJ_DIR)/%.csv: $(OBJ_DIR)/%.xlsx
	ssconvert --import-type=Gnumeric_Excel:xlsx $<  $@


$(OBJ_DIR)/%.txt: $(OBJ_DIR)/%.xlsx
	ssconvert -S --import-type=Gnumeric_Excel:xlsx -O 'separator="	" format="preserve" quoting-mode="auto"' $< $(patsubst %.txt,%.,$@)%s.txt 2>/dev/null
	rename "s/ /_/g" $(OBJ_DIR)/*.txt

convert: $(TXT)

$(EXE): $(wildcard $(OBJ_DIR)/*.txt)
	./logbook.ssconvert.awk $^ > $@

# run "make clean prepare convert build"
all: prepare convert build

prepare: $(OBJ_DIR)

build: $(EXE)

clean:
	find . -type f -name '*.csv' -exec rm -f {}  \;
	find . -type f -name '*.txt' -exec rm -f {}  \;
	find . -type f -name '*.tsv' -exec rm -f {}  \;
	$(RM) -rv $(OBJ_DIR) $(TMP_DIR) 			# The @ disables the echoing of the command

.PHONY: all prepare build clean

push: $(EXE)
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
