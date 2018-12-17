.DEFAULT_GOAL := help

TOPDIR := $(shell echo $(pwd))

.PHONY: help

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-13s\033[0m %s\n", $$1, $$2}'
	@echo 'x'
	@echo 'read xyz'

include .env

# EXECUTABLES is variable wuth a list of expected executables
EXECUTABLES =  stow gpg git
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

### Software Packages

apt-update: .package-update ## Update apt repo
app-vscode: .vscode ## install app vscode
apt-puppetrepo: .package-apt-puppetrepo

.package-update:
	sudo apt update -q
	@touch $@

.package-apt-puppetrepo: ## installs puppet5 on ubuntu 18.04
	wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
	sudo dpkg -i puppet5-release-bionic.deb && rm puppet5-release-bionic.deb
	sudo apt update
	sudo apt install puppet-agent

### Software

.vscode: | /usr/bin/code apt-update ## Install vscode
	bash ${TOPDIR}/linux/apps/vscode.sh
	@touch $@

### GIT

GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$')

git: git/.gitconfig
	stow -t ~ -S git

clean:
	@echo 'Remove Git config'
	stow -t ~ -D git
	rm -rf git/.gitconfig

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
