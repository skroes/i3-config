#
# major targets:
#

linux: core shell desktop services .scripts-bin .bash-stow ### This will setup targets
	$(call oksign,$@)

repo: .repo ## Update repository metadata
	$(call oksign,$@)

repo_halt: .repo ## Update repository metadata
	$(call oksign,$@)
	sudo shutdown -h now

core: git etckeeper github feature-all repo
	$(call oksign,$@)

shell: fish fish-config repo
	$(call oksign,$@)

desktop: i3 chrome  repo ## desktop apps
	$(call oksign,$@)

services: ssh-server repo ## system services
	$(call oksign,$@)

specials: emby repo

linux-clean: packages-clean i3-clean git-clean feature-clean latest-clean fish-clean chrome-clean etckeeper-clean

###
### repo
###


.repo: $(shell find /etc/apt -type f)
	sudo apt update -qy
	sudo apt upgrade -qy
	sudo apt autoremove -qy
	touch $@

###
### puppet
###

puppet: puppet-agent
puppet-agent: .puppet-agent # installs puppet5 agent
.puppet-agent:
	wget https://apt.puppetlabs.com/puppet6-release-${OSRELEASE}.deb
	sudo dpkg -i puppet6-release-${OSRELEASE}.deb
	rm -f puppet6-release-${OSRELEASE}.deb
	sudo apt update
	sudo apt install puppet-agent -y
	touch $@

packages-clean:
	rm -rf .repo

###
### setup ssh server
###

ssh-server: .ssh-server # Install sshd daemon
	$(call oksign,$@)

.ssh-server: /usr/sbin/sshd
	sudo systemctl enable --now ssh
	touch $@

/usr/sbin/sshd: latest-openssh-server

###
### google-chrome
###

chrome: .chrome # Setup Google Chrome
	$(call oksign,$@)
.chrome:
	@sudo su -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo apt-get update -qqy
	sudo apt-get install google-chrome-stable -qqy
	touch $@

chrome-clean:
	sudo rm -f /etc/apt/sources.list.d/google-chrome.list

###
### i3
###

i3: .i3-dependencies .i3-install .i3-settings .i3-stow # Setup i3
	$(call oksign,$@)

i3-repo-github-enabled: github-enabled .i3-git-update-remote repo ### ssh access enabled for i3 repository
	$(call oksign,$@)

.i3-stow:
	#test -d ~/.config/i3/.git || ( mv ~/.config/i3 ~/.config/i3-config && mkdir -p ~/.config/i3 )
	mkdir -p ~/.config/i3
	stow --target ~/.config/i3/ i3 --adopt
	touch $@

###
### sub
###

.i3-git-update-remote: github-enabled
	git remote remove origin
	git remote add origin git@github.com:skroes/i3-config.git
	git fetch
	git branch --set-upstream-to origin/master
	touch $@

.i3-dependencies: .repo
	sudo apt install \
		suckless-tools i3-wm gnome-settings-daemon unclutter gnome-tweak-tool gnome-session \
		alsa-utils volumeicon-alsa libnotify-bin meld s3cmd gconf2 wget curl\
		feh xinput gnome-settings-daemon j4-dmenu-desktop i3status libxml2-utils jq \
    		xdotool volumeicon-alsa i3blocks -y
	@touch $@
	# disper
	# sudo apt-get install python-pip -qqy
	# pip install i3-py

.i3-install: /var/lib/dpkg/info/i3.list | .i3-dependencies
/var/lib/dpkg/info/i3.list:
	sudo apt install i3 -y

.i3-settings: | .i3-install
	# mouse cursur
	gsettings set org.gnome.settings-daemon.plugins.cursor active false
	# desktop
	gsettings set org.gnome.desktop.background show-desktop-icons false
	gconftool-2 \
	--type bool \
	--set /apps/nautilus/preferences/show_desktop false
	gsettings set org.gnome.desktop.background show-desktop-icons false
	@touch $@

i3-clean:
	rm -f .i3-dependencies .i3-settings

###
### scripts
###

.scripts-bin:
	stow -v scripts --target ~ --adopt
	@touch $@

.bash-stow:
	stow -v bash --target ~ --adopt

~/.bash_aliases:
#	echo hoiiiii

###
### e2
###

## e2guardian
##e2: .e2-install .e2-config # Setup e2guardian
#	$(call oksign,$@)
#
#.e2-install: /var/lib/dpkg/info/e2guardian.list | .repo
#/var/lib/dpkg/info/e2guardian.list:
#	sudo apt install e2guardian -qy
#
#.e2-config: | .e2-install
#	-@test -L /etc/e2guardian && sudo unlink /etc/e2guardian
#	-@test -d /etc/e2guardian && sudo rm -Rf /etc/e2guardian
#	sudo stow -t /etc -S tag-e2guardian
#	touch $@
#
#e2-clean:
#	rm -f .e2-install .e2-config
#
#.e2-mrproper: e2-clean
#	-sudo stow -t /etc -D e2guardian || sudo unlink /etc/e2guardian
#	sudo apt purge e2guardian -qy
#
###
### emby
###
#
#EMBY_RELEASE=3.5.3.0#
#EMBY_URL=https://github.com/MediaBrowser/Emby.Releases#/releases/download/${EMBY_RELEASE}/
#EMBY_DEBNAME=emby-server-deb_${EMBY_RELEASE}_amd64.deb#
#
#emby: .emby-install #### Install emby server#
#	@echo Open a web #browser to http://loca#lhost:8096
#	$(call oksign,$@)#
#
#emby-status:#
#	@sudo sy#stemctl s#tatus emby-server --no#-pager | GREP_COLOR='1;32' egrep -Hr 'active|running|loaded' - --color 2>/dev/null
#
#####
#### sub emby#
#####
#
#.emby-instal#l: | tmp/#${EMBY_DEBNAME}#
#	sudo dpk#g -i tmp/#${EMBY_DEBNAME}#
#	sudo sys#temctl st#atus emby-server --no-pager
#	rm -f tm#p/${EMBY_DEBNAME}
#	touch $@#
#
#tmp/${EMBY_DEBNAME}: | tmp
#	curl -L -S --progress-bar "${EMBY_URL}/${EMBY_DEBNAME}" -o $@
#
###
### etckeeper
###

etckeeper: | .etckeeper-install /etc/.git
	$(call oksign,$@)

.etckeeper-install:
	sudo apt install etckeeper -y
	touch $@

/etc/.git: | .etckeeper-install
	etckeeper init

etckeeper-clean:
	rm -f .etckeeper-install
