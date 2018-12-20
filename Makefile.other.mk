DOTFILES_DIR := $(shell echo $(HOME)/.dotfiles)
RUBY_VERSION := 2.5.1
SHELL        := /bin/sh
UNAME        := $(shell uname -s)
USER         := $(shell whoami)

ifeq ($(UNAME), Darwin)
  OS         := macos
else ifeq ($(UNAME), Linux)
  OS         := linux
endif

.PHONY: all install

APP_LIST=$(shell uname -s)
test: ${APP_LIST}: app

app: | apt
	bash ${DOTFILES_DIR}/linux/apps/$@.sh

all: install

install: $(OS)



.PHONY: help usage
.SILENT: help usage

help: usage

usage:
	printf "\\n\
	\\033[1mDOTFILES\\033[0m\\n\
	\\n\
	Custom macOS settings and terminal configurations.\\n\
	See README.md for detailed usage information.\\n\
	\\n\
	\\033[1mUSAGE:\\033[0m make [target]\\n\
	\\n\
	  make         Install all configurations and applications.\\n\
	\\n\
	  make link    Symlink only Bash and Vim configurations to the home directory.\\n\
	\\n\
	  make unlink  Remove symlinks created by \`make link\`.\\n\
	\\n\
	"

.PHONY: linux macos link unlink

linux: apt git-init ruby-linux stow
	. $(HOME)/.bash_profile

macos: bash brew git-init ruby-macos stow
	bash $(DOTFILES_DIR)/macos/defaults.sh
	bash $(DOTFILES_DIR)/macos/duti/set.sh
	stow macos
	brew services start chunkwm
	brew services start skhd
	ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport
	. $(HOME)/.bash_profile
	open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg
	softwareupdate -aiR

link: git-init
	ln -fs $(DOTFILES_DIR)/bash/.bash_profile $(HOME)/.bash_profile
	ln -fs $(DOTFILES_DIR)/bash/.bashrc $(HOME)/.bashrc
	ln -fs $(DOTFILES_DIR)/bash/.curlrc $(HOME)/.curlrc
	ln -fs $(DOTFILES_DIR)/bash/.inputrc $(HOME)/.inputrc
	ln -fs $(DOTFILES_DIR)/bash/.hushlogin $(HOME)/.hushlogin
	ln -fs $(DOTFILES_DIR)/vim/.vimrc $(HOME)/.vimrc
	ln -fs $(DOTFILES_DIR)/vim/.vim $(HOME)/.vim

unlink:
	unlink $(HOME)/.bash_profile
	unlink $(HOME)/.bashrc
	unlink $(HOME)/.curlrc
	unlink $(HOME)/.hushlogin
	unlink $(HOME)/.inputrc
	unlink $(HOME)/.vimrc
	unlink $(HOME)/.vim
	@printf "\\033[32m✓\\033[0m Symlinks removed. Manually remove ~/dotfiles directory if needed.\\n"

.PHONY: apt bash brew git-init ruby-linux ruby-macos stow

apt:
	bash $(DOTFILES_DIR)/linux/apt.sh

bash: brew
	echo /usr/local/bin/bash >> /etc/shells
	chsh -s /usr/local/bin/bash

brew:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew bundle --file=$(DOTFILES_DIR)/macos/.Brewfile

git-init:
	git submodule init
	git submodule update

ruby-linux: apt
	git clone git://github.com/sstephenson/rbenv.git $(HOME)/.rbenv
	git clone git://github.com/sstephenson/ruby-build.git $(HOME)/.rbenv/plugins/ruby-build
	sudo chown -R $(USER) $(HOME)/.rbenv
	rbenv init -
	rbenv install $(RUBY_VERSION)
	rbenv global $(RUBY_VERSION)

ruby-macos: brew
	rbenv install $(RUBY_VERSION)
	rbenv global $(RUBY_VERSION)

stow:
	stow bash
	stow git
	stow gpg
	stow haskell
	stow vim
