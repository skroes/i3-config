# Ubuntu/debian specific recipes

virtualbox: /usr/bin/virtualbox
vagrant: /usr/bin/vagrant
direnv: /usr/bin/direnv
bundle: /usr/bin/bundle
java: /usr/bin/java
git: /usr/bin/git
dot: /usr/bin/dot
jq: /usr/bin/jq

/usr/bin/virtualbox: deb-virtualbox
/usr/bin/vagrant: | bin-vagrant
/usr/bin/direnv: deb-direnv
/usr/bin/bundle: deb-ruby-bundler deb-g++ deb-ruby-dev
/usr/bin/shellcheck: deb-shellcheck

/usr/bin/java: deb-openjdk-8-jdk
/usr/bin/python: deb-python
/usr/bin/dot: deb-imagemagick
/usr/bin/jq: deb-jq
/usr/bin/curl: deb-curl
/usr/bin/git: deb-git

# If running on WSL don't install Virtualbox (use the Windows Virtualbox installation)
ifneq ($(shell uname -a|grep Microsoft),)
virtualbox:
endif

# Recipes for installing system packages using apt
deb-git deb-shellcheck deb-ruby-bundler deb-virtualbox deb-g++ deb-direnv deb-python deb-imagemagick deb-jq deb-curl: deb-% :/var/lib/dpkg/info/%.list
deb-ruby-dev deb-openjdk-8-jdk: deb-% :/var/lib/dpkg/info/%\:amd64.list

/var/lib/dpkg/info/%.list /var/lib/dpkg/info/%\:amd64.list: | .updated_apt
	${sudo} apt-get install -yqq $*

.updated_apt:
	# ensure apt update has run at least once
	${sudo} apt-get update -qq
	@touch $@

# Install Vagrant binary from vendor
.PHONY: bin-vagrant
bin-vagrant: /var/lib/dpkg/info/vagrant.list
/var/lib/dpkg/info/vagrant.list: /tmp/vagrant_2.1.2_x86_64.deb
	${sudo} dpkg -i $<
/tmp/vagrant_2.1.2_x86_64.deb: | /usr/bin/curl
	/usr/bin/curl -s https://releases.hashicorp.com/vagrant/2.1.2/vagrant_2.1.2_x86_64.deb > $@

/usr/local/bin/packer:
	/usr/bin/curl -s https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip > ${TMPDIR}/packer.zip
	cd $(dir $@); ${sudo} unzip ${TMPDIR}/packer.zip
