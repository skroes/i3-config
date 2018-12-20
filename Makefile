# My first MAkefile

.DEFAULT_GOAL := help

TOPDIR := $(shell echo $(pwd))

.PHONY: help
#.SILENT: help

.PHONY: help
# via https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@echo "usage: make [TARGET]"
	@echo
	@echo "MAIN TARGET:"
	@grep -hE '^[a-zA-Z_-]+:.*?#! .*$$' $(MAKEFILE_LIST) |        awk 'BEGIN {FS = ":.*?#! "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "TARGET:"
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

include .env

# EXECUTABLES is variable wuth a list of expected executables
EXECUTABLES = stow gpg git
K := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(warning "No $(exec) in PATH")))

# main target
all: update-repo package-apt-puppetrepo vscode #! installs all requirements

update: upgrade ## update

### Software Packages
include Makefile.ubuntu
include Makefile.darwin

update-repo: .update-repo ## Update package manager repo
.update-repo:
	sudo apt update -q
	@touch $@

upgrade: .upgrade ## Upgrade OS
.upgrade:
	sudo apt upgrade

package-apt-puppetrepo: .package-apt-puppetrepo ## installs puppet5 on ubuntu 18.04
.package-apt-puppetrepo:
	wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
	sudo dpkg -i puppet5-release-bionic.deb && rm puppet5-release-bionic.deb
	sudo apt update
	sudo apt install puppet-agent
	touch $@

/usr/bin/code: .vscode
vscode: .vscode ## Installs vscode
.vscode: update-repo
	bash ${TOPDIR}/linux/apps/vscode.sh
	touch $@

### GIT

GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$')

git: git/.gitconfig
	stow -t ~ -S git

clean:
	#@echo 'Remove Git config'
	#stow -t ~ -D git
	#rm -rf git/.gitconfig

mrproper: clean
	rm .vscode 

git/.gitconfig:
	cp gitconfig.dist $@
	git config --global user.name "$(GIT_AUTHOR_NAME)"
	git config --global user.email "$(GIT_AUTHOR_EMAIL)"
	git config --global github.user "$(GITHUB_USER)"
	git config --global user.signingkey "$(GIT_SIGNING_KEY)"

### MISC

.PHONY: git-show
git-show: ## do something
	git log --graph --full-history --all --pretty=format:"%h%x09%d%x20%s"

### NONSENSE

sense: ## This doesnt make sense
	$(error Doesnt make sense)
