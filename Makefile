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

getRecipe = $(if $(DEPENDENCY_GRAPH),@echo Target $@ depends on prerequisites "$^",$(1))

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

###
### features
###

# objects are a list of 'feature-xyz' strings
featureobjects := $(shell cd ${OS}/feature/ && ls -1 *.sh | sed 's/.sh//g' | sed 's/^/feature-/g'  )

feature-all: ${featureobjects} ## Setup all features segments
	$(call echo,$@ ${OK_STRING})

$(info ${featureobjects})

${featureobjects}: $(addprefix .,${featureobjects})
	$(call echo,$@ ${OK_STRING})

.feature-%:
	bash -e ${TOPDIR}/${OS}/feature/$*.sh
	touch $@

feature-clean:
	rm -f .feature-*

###
### Puppet package manipulations
###

latestobjectslist := vim stow
latestobjects := $(addprefix latest-,${latestobjectslist})

${latestobjects}: $(addprefix .,${latestobjects})
	$(call echo,$@ ${OK_STRING})

.latest-%: | puppet-agent
	sudo -i puppet resource package $* ensure=latest
	touch $@

latest-clean:
	rm -f .latest-*

#latest-%: $(latest-x:latest=xxx)
#	echo "zomthing"
#	@echo $@
#	touch $@
#	rm $@


#latest-%: $$(addsuffix /%.c,foo bar) | puppet-agent
#	sudo -i puppet resource package $@ ensure=latest

#present-$(subst present-,x,%): | puppet-agent
#	sudo -i puppet resource package $@ ensure=present

#app-%: testfile-x
#	@info app-$(subst app-,,$<)

#testfile-%: 
#	@echo touch $<

###
### code plugin
### 

#eamodio.gitlens
#EditorConfig.EditorConfig

###
### nosense
###

sense:
	$(error Doesnt make sense)

#.PHONY: printvars
#printvars:
#	$(foreach V),
#		$(sort $(.VARIABLES)),
#			$(if 
#			$(filter-out environment% default automatic,
#			$(origin $V)),
#			$(warning $V=$($V) ($(value $V)))
#		)
#	)


include .env
#include Makefile.global.mk
#include Makefile.common.mk
include Makefile.${OS}.mk
include Makefile.git.mk

clean: ${OS}-clean
	$(call echo,$@ ${OK_STRING})

mrproper: clean

makefile2graph.png:
	cat Makefile Makefile.linux.mk > .tmp.combined-makefile
	make -f .tmp.combined-makefile -Bnd | ./tmp/makefile2graph/make2graph | dot -Tpng -o $@
	#rm .tmp.combined-makefile
	xdg-open $@

./tmp/makefile2graph: makefile2graph
	git clone https://github.com/lindenb/makefile2graph.git 
	cd ./tmp/makefile2graph && make
	touch $@