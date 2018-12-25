
linux: feature-all update-repo git i3 e2 ### This will setup targets; update-repo vscode git i3 e2 regular-packages
	$(call oksign,$@)

linux-clean: packages-clean i3-clean git-clean e2-clean feature-clean latest-clean

###
### OS and repo
###

update-repo: .update-repo ## Update repository metadata
	$(call oksign,$@)
.update-repo: $(shell sudo find /etc/apt -type f)
	sudo apt update -qqy
	touch $@

upgrade: .upgrade ## Upgrade OS
	$(call oksign,$@)
.upgrade: $(shell sudo ls /var/cache/apt/*.bin) | update-repo
	sudo apt upgrade -qy
	touch $@

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

.i3-dependencies: 
	sudo apt install \
		suckless-tools i3-wm gnome-settings-daemon unclutter gnome-tweak-tool gnome-session \
		alsa-utils volumeicon-alsa disper libnotify-bin meld s3cmd gconf2 wget curl\
		feh xinput gnome-settings-daemon j4-dmenu-desktop i3status -y 
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

.e2-install: /var/lib/dpkg/info/e2guardian.list | upgrade 
/var/lib/dpkg/info/e2guardian.list:
	sudo apt install e2guardian -qy

.SILENT: .e2-config
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
	sudo unlink /etc/e2guardian

#sudo tar -czvf /etc/e2guardian.tgz /etc/e2guardian
#sudo rm -Rf /etc/e2guardian
#sudo mv /etc/e2guardian{.rpmorg}