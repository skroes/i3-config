darwin: upgrade #! installs all requirements for Linux
	@echo "done."

upgrade: .upgrade ## Upgrade OS
.upgrade:
	@echo ye almost.

bash: brew
	echo /usr/local/bin/bash >> /etc/shells
	chsh -s /usr/local/bin/bash

brew:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew bundle --file=$(TOPDIR)/macos/.Brewfile

#clean:
#	@echo done.

#mrproper: clean
#	@echo done.