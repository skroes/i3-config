.PHONY: brew
brew: /usr/local/bin/brew
virtualbox: /usr/local/bin/virtualbox
vagrant: /usr/local/bin/vagrant
direnv: /usr/local/bin/direnv
bundle: /usr/local/bin/bundle
java: ${HOME}/.sdkman/candidates/java/current/bin/java
jq: /usr/local/bin/jq
curl: /usr/local/bin/curl

# git is preinstalled
git: /usr/bin/git

/usr/local/bin/brew:
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

/usr/local/bin/virtualbox: | /usr/local/bin/brew
	brew cask install virtualbox

/usr/local/bin/vagrant: | /usr/local/bin/brew
	brew cask install vagrant

/usr/local/bin/bundle:
	${sudo} gem install bundler

/usr/local/bin/direnv /usr/local/bin/jq /usr/local/bin/curl: /usr/local/bin/%: | /usr/local/bin/brew
	brew install $*

${HOME}/.sdkman/candidates/java/current/bin/java: | ${HOME}/.sdkman/bin/sdkman-init.sh
	. ${HOME}/.sdkman/bin/sdkman-init.sh; sdk install java $(shell . ${HOME}/.sdkman/bin/sdkman-init.sh; sdk list java|sed -nE 's/.* (8\..*-zulu)/\1/p')

${HOME}/.sdkman/bin/sdkman-init.sh:
	curl -s "https://get.sdkman.io" | bash
