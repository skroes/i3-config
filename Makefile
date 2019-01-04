uname  = $(shell uname -s)
USER   = $(shell whoami)
TOPDIR = $(shell pwd)
SHELL  = /bin/bash

ifeq ($(shell uname), Darwin)
	OS	:= macos
else ifeq ($(shell uname -o), GNU/Linux)
	OS	:= linux
endif

.PHONY: all install help usage
.SILENT: help usage usage-simple usage-all

help: usage-simple

include Makefile.functions.mk

usage-simple:
	grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

usage: ## More usage options
	printf "\\n\
	\\033[1mMYFILES\\033[0m\\n\
	\\n\
	Custom Linux and macOS settings and terminal configurations.\\n\
	See README.md for detailed usage information.\\n\
	\\n\
	\\033[1mUSAGE:\\033[0m make [target]\\n\
	\\n\
	\\033[1mtargets:\\033[0m\\n\
	"
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -vw 'usage:' | sort | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

usage-all: # show all usage actions
	grep -hE '^[0-9a-zA-Z_-]+:.*?#.*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?#"}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

#getRecipe = $(if $(DEPENDENCY_GRAPH),@echo Target $@ depends on prerequisites "$^",$(1))

#print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

#zozo-% : ; $(info $* is set to [$($*)]) @true

#leeg-% : ; @echo $* @true

# notify if SSH agent is not enabled
agent_enabled = $(shell pgrep ssh-agent)
ifndef SKIP_SSH_AGENT_CHECK
ifeq (${agent_enabled},)
$(info SSH-agent is not running, start agent using: `eval $$(ssh-agent)` or add this line to `~/.profile` to do it automatically at login.)
endif
identities = $(shell ssh-add -l|grep -v "The agent has no identities.")
ifeq (${identities},)
$(info No SSH identities configured in ssh-agent, please add a key using: `ssh-add ~/.ssh/id_rsa`)
endif
endif

OK_STRING=[OK]
WARN_STRING=[WARNING]
ERROR_STRING=[ERROR]

# EXECUTABLES is variable wuth a list of expected executables
EXECUTABLES = stow gpg git sudo
K := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(warning "${WARN_STRING} No $(exec) in PATH")))

#
# todo list:
#
# ssh-askpass thing
# solarized -> gnome-install / terminator?
#

### generate needed software dependancie targets
is-not-installed=! (command -v $(1))

###
### core stuff
###

update: ### update i3 repo
	git pull --rebase

push:
	git push

git-commit-and-push-in-one-go:
	for filetocommit in $$(git status --short | awk {'print $$2'}); do git add $$filetocommit; git commit -m "[$$(hostname -s)] [$${filetocommit}]"; done
	git push

###
### features
###

# objects are a list of 'feature-xyz' strings
featureobjects := $(shell cd ${OS}/feature/ && ls -1 *.sh | sed 's/.sh//g' | sed 's/^/feature-/g'  )

feature-all: ${featureobjects} ## Setup all features segments

${featureobjects}: $(addprefix .,${featureobjects}) .upgrade update-repo tmp
	$(call oksign,$@)

.feature-%:
	bash -e ${TOPDIR}/${OS}/feature/$*.sh
	touch $@

feature-clean:
	rm -f .feature-*

###
### Puppet package manipulations
###

#latestobjectslist := vim stow
#latestobjects := $(addprefix latest-,${latestobjectslist})

#${latestobjects}: $(addprefix .,${latestobjects})
#	$(call oksign,$@)

#  | puppet-agent $(addprefix .,${latestobjects})
#latest-%: $(addprefix .,$@)

latest-%: | puppet-agent
	sudo -i puppet resource package $* ensure=latest  | tr "\n" " "
	touch $@

latest-clean:
	rm -f .latest-* latest-*

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
-include .env.override
#include Makefile.global.mk
include Makefile.${OS}.mk
include Makefile.git.mk
include Makefile.ssh.mk
include Makefile.shell.mk

clean: ${OS}-clean
	$(call oksign,$@)

mrproper: clean

tmp:
	mkdir $@

makefile2graph.png: | ./tmp/makefile2graph
	cat Makefile* > .tmp.combined-makefile
	make -f .tmp.combined-makefile -Bnd | ./tmp/makefile2graph/make2graph | dot -Tpng -o $@
	#rm .tmp.combined-makefile
	xdg-open $@

./tmp/makefile2graph:
	rm -Rf $@
	git clone https://github.com/lindenb/makefile2graph.git $@
	cd $@ && make
	touch $@
