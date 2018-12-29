
linux: feature-all .upgrade update-repo fish git i3 e2 chrome firefox etckeeper ### This will setup targets; update-repo vscode git i3 e2 regular-packages
	$(call oksign,$@)

linux-complete-workspace: github | linux

linux-clean: packages-clean i3-clean git-clean e2-clean feature-clean latest-clean fish-clean

ssh-add:
	ssh-add --quiet -l || ( echo "Error connecting to agent ... attempt to load key"; ssh-add ~/.ssh/id_rsa )

###
### OS and repo
###

update-repo: .update-repo ## Update repository metadata
	$(call oksign,$@)
.update-repo: $(shell sudo find /etc/apt -type f)
	sudo apt update -qqy
	sudo apt autoremove -qy
	touch $@

upgrade: .upgrade-exec ## Upgrade OS
	touch .upgrade
	$(call oksign,$@)

# trigger only if updated req
.upgrade: $(shell sudo ls /var/cache/apt/*.bin) .update-repo
	sudo apt upgrade -qqy
	sudo apt autoremove -qy
	touch $@

# execute the actual upgrade of packages
.upgrade-exec:
	sudo apt upgrade -qqy
	sudo apt autoremove -qy

###
### puppet
###

puppet: puppet-agent
puppet-agent: .puppet-agent # installs puppet5 agent
	$(call oksign,$@)
.puppet-agent:
	wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
	sudo dpkg -i puppet5-release-bionic.deb
	rm puppet5-release-bionic.deb
	sudo apt update
	sudo apt install puppet-agent
	touch $@

packages-clean:
	rm -rf .upgrade .update-repo

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
### firefox
###

firefox: .firefox # Install firefox
	$(call oksign,$@)

.firefox:
	sudo apt-get install firefox -qqy
	touch $@

###
### google-chrome
###

chrome: .chrome # Setup Google Chrome
	$(call oksign,$@)
.chrome:
	@sudo su -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'
	wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	sudo apt-get update -qqy
	sudo apt-get install google-chrome-stable -qqy
	touch $@

chrome-clean:
	sudo rm -f /etc/apt/sources.list.d/google-chrome.list

###
### i3
###

i3: .i3-dependencies .i3-install .i3-settings # Setup i3
	$(call oksign,$@)

i3-repo-github-enabled: github-enabled .i3-git-update-remote ### ssh access enabled for i3 repository
	$(call oksign,$@)

###
### sub
###

.i3-git-update-remote: github-enabled
	git remote remove origin
	git remote add origin git@github.com:skroes/i3-config.git
	git fetch
	git branch --set-upstream-to origin/master
	touch $@

.i3-dependencies:
	sudo apt install \
		suckless-tools i3-wm gnome-settings-daemon unclutter gnome-tweak-tool gnome-session \
		alsa-utils volumeicon-alsa disper libnotify-bin meld s3cmd gconf2 wget curl\
		feh xinput gnome-settings-daemon j4-dmenu-desktop i3status libxml2-utils jq \
    xdotool volumeicon-alsa -y
	sudo apt-get install python-pip -qqy
	pip install i3-py
	@touch $@

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
### e2
###

# e2guardian
e2: .e2-install .e2-config # Setup e2guardian
	$(call oksign,$@)

.e2-install: /var/lib/dpkg/info/e2guardian.list | .upgrade
/var/lib/dpkg/info/e2guardian.list:
	sudo apt install e2guardian -qy

.e2-config: | .e2-install
	@test -L /etc/e2guardian || sudo unlink /etc/e2guardian
	@test -d /etc/e2guardian || sudo rm -Rf /etc/e2guardian
	sudo stow -t /etc -S e2guardian
	touch $@

e2-clean:
	rm -f .e2-install .e2guardian-config

.e2-mrproper:
	sudo stow -t /etc -D e2guardian
	sudo apt purge e2guardian -qy
<<<<<<< HEAD
=======
	sudo unlink /etc/e2guardian

###
### emby
###

EMBY_RELEASE=3.5.3.0
EMBY_URL=https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_RELEASE}/
EMBY_DEBNAME=emby-server-deb_${EMBY_RELEASE}_amd64.deb

emby: .emby-install ### Install emby server
	@echo Open a web browser to http://localhost:8096
	$(call oksign,$@)

emby-status:
	@sudo systemctl status emby-server --no-pager | GREP_COLOR='1;32' egrep -Hr 'active|running|loaded' - --color 2>/dev/null

###
### sub emby
###

.emby-install: | tmp/${EMBY_DEBNAME}
	sudo dpkg -i tmp/${EMBY_DEBNAME}
	sudo systemctl status emby-server --no-pager
	rm -f tmp/${EMBY_DEBNAME}
	touch $@

tmp/${EMBY_DEBNAME}: | tmp
	curl -L -S --progress-bar "${EMBY_URL}/${EMBY_DEBNAME}" -o $@

tmp:
	mkdir $@
<<<<<<< HEAD
>>>>>>> add emby
=======

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
	@#nothing here
>>>>>>> git ssh etckeeper etc
