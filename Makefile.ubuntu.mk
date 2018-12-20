update-repo: .update-repo
.update-repo:
	sudo apt update -q
	touch $@

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

vscode: .vscode ## Installs vscode
/usr/bin/code: .vscode
.vscode: update-repo
	bash ${TOPDIR}/linux/apps/vscode.sh
	touch $@

#clean:
#	rm .vscode .package-apt-puppetrepo

#mrproper: clean
#	@echo done.