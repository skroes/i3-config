darwin: upgrade ### installs all requirements for Darwin
	@echo "done."

upgrade: .upgrade # Upgrade OS
.upgrade:
	@echo ye almost.

bash: brew # Install bash
	echo /usr/local/bin/bash >> /etc/shells
	chsh -s /usr/local/bin/bash

brew: # Install brew
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew bundle --file=$(TOPDIR)/macos/.Brewfile

#clean:
#	@echo done.

#mrproper: clean
#	@echo done.
