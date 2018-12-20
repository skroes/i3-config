UNAME        := $(shell uname -s)
USER         := $(shell whoami)
TOPDIR			 := $(shell pwd)

ifeq ($(UNAME), Darwin)
  OS         := macos
else ifeq ($(UNAME), Linux)
  OS         := linux
endif

.PHONY: all install

all: install

install: $(OS)

.PHONY: help usage
.SILENT: help usage

help: usage

usage:
	printf "\\n\
	\\033[1mMYFILES\\033[0m\\n\
	\\n\
	Custom Linux and macOS settings and terminal configurations.\\n\
	See README.md for detailed usage information.\\n\
	\\n\
	\\033[1mUSAGE:\\033[0m make [target]\\n\
	\\n\
	  make         Install all configurations and applications.\\n\
	\\n\
	"
	@grep -hE '^[a-zA-Z_-]+:.*?#! .*$$' $(MAKEFILE_LIST) |        awk 'BEGIN {FS = ":.*?#! "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'


# EXECUTABLES is variable wuth a list of expected executables
EXECUTABLES = stow gpg git sudo
K := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(warning "No $(exec) in PATH")))

include .env
#include Makefile.global.mk
#include Makefile.common.mk
include Makefile.${OS}.mk
include Makefile.git.mk

sense: ## This doesnt make sense
	$(error Doesnt make sense)

#APP_LIST=$(shell uname -s)
#test: ${APP_LIST}: app

#app: | apt
#	bash ${DOTFILES_DIR}/linux/apps/$@.sh

#directory = ~/Dropbox

#all: | $(directory)
#    @echo "Continuation regardless of existence of ~/Dropbox"

#$(directory):
#	@echo "Folder $@ does not exist"
#	mkdir -p $@

#.PHONY: all