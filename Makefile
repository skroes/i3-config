.DEFAULT_GOAL := help

DOTFILES_DIR := $(shell echo $(HOME)/.dotfiles)
DEBUG=0

.PHONY: help

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-13s\033[0m %s\n", $$1, $$2}'

### Software Packages

apt-update: .package-update ## Update apt repo
app-vscode: .vscode ## install app vscode

.package-update:
	sudo apt update -q
	@touch $@

.vscode: | /usr/bin/code apt-update ## Update apt repo
	bash ${DOTFILES_DIR}/linux/apps/vscode.sh
	@touch $@

### GIT

GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$')

EXECUTABLES = stow gpg git
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH")))

#include .env ?

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

### SENSE

sense: ## This doesnt make sense
	$(error Doesnt make sense)