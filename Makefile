uname	:= $(shell uname -s)
USER	:= $(shell whoami)
TOPDIR	:= $(shell pwd)
SHELL	:= /bin/bash

ifeq ($(shell uname), Darwin)
	OS	:= macos
else ifeq ($(shell uname -o), GNU/Linux)
	OS	:= linux
endif

.PHONY: all install help usage
.SILENT: help usage

help: usage-simple

include Makefile.functions.mk

usage-simple: # show normal actions
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

usage: # show usage
	printf "\\n\
	\\033[1mMYFILES\\033[0m\\n\
	\\n\
	Custom Linux and macOS settings and terminal configurations.\\n\
	See README.md for detailed usage information.\\n\
	\\n\
	\\033[1mUSAGE:\\033[0m make [target]\\n\
	\\n\
	\\033[1mTARGETS:\\033[0m\\n\
	"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

usage-all: # show all targets
	@grep -hE '^[a-zA-Z_-]+:.*?#.*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?#"}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

zozo-% : ; $(info $* is set to [$($*)]) @true

leeg-% : ; @echo $* @true


OK_STRING=[OK]
WARN_STRING=[WARNING]
ERROR_STRING=[ERROR]

# EXECUTABLES is variable wuth a list of expected executables
EXECUTABLES = stow gpg git sudo
K := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(warning "${WARN_STRING} No $(exec) in PATH")))

include .env
#include Makefile.global.mk
#include Makefile.common.mk
include Makefile.${OS}.mk
include Makefile.git.mk

clean: ${OS}-clean
	$(call echo,$@ ${OK_STRING})

mrproper: clean

sense:
	$(error Doesnt make sense)
