
linux: all-features update-repo git i3 e2 regular-packages ### This will setup targets; update-repo vscode git i3 e2 regular-packages
	$(call echo,$@ ${OK_STRING})

all-features: feature-vscode feature-regularpackages

linux-clean: packages-clean i3-clean git-clean e2-clean packages-clean feature-clean

#%:app-=l)
#$(BIN)/%.o: %.cpp
#@echo "111" .app-$@
#@echo "222" $*

# feature-vscode
# feature-lala
#       ->'''' -> executes ./linux/feature/lala.sh

featureobjects := $(shell cd linux/feature/ && ls -1 *.sh)
#featurebjects := $(wildcard linux/feature/*.sh)

feature-%: | .feature-%
	$(call echo,$@ ${OK_STRING})
.feature-%:
	. ${TOPDIR}/linux/feature/$*.sh
	> $@

feature-clean:
	rm -f .feature-*



#$(info ${objects})
#print:
#	@echo vraagteken $?
#	@echo wildcard $*
#	@echo < $<
#	@echo > $>
#	touch print


#.PHONY: basic_%
#basic_%: %.c

#lala_oef:#
#	@echo $(patsubst .*_, "", $@)

#basic_abc: $(patsubst .*_, " ", $@).c
#		@echo gcc -g -o  $(patsubst .*_, " ", $@)    $(patsubst .*_, " ", $@).c

#objects = iets*

#foo : $(objects)
#	@echo cc -o foo $(CFLAGS) $(objects)

update-repo: .update-repo ## Update repository metadata
	@echo ${OK_STRING} $@
.update-repo:
	sudo apt update -qqy
	touch $@

upgrade: | .upgrade ## Upgrade OS
	@echo "$@ ${OK_STRING}"
.upgrade: update-repo
	sudo apt upgrade -qy
	sudo apt autoremove -qy
	touch $@

puppet: puppet-agent
puppet-agent: .puppet-agent # installs puppet5 agent
	@echo "$@ ${OK_STRING}"
.puppet-agent:
	wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
	sudo dpkg -i puppet5-release-bionic.deb
	rm puppet5-release-bionic.deb
	sudo apt update
	sudo apt install puppet-agent
	touch $@

packages-clean:
	rm -rf .upgrade .update-repo


#%.o: $$(addsuffix /%.c,foo bar) foo.h
#%.o: $$(addsuffix /%.c,foo bar) foo.h
#$(patsubst pattern,replacement,$(var))

#latest-${addsuffix /latest-,,)}: latest-%
#latest-$(patsubst latest-,,$(%)): latest-%
latest-%: $(latest-x:latest=xxx)
	echo "zomthing"
	@echo $@
	touch $@
	rm $@

#latest-%: $$(addsuffix /%.c,foo bar) | puppet-agent
#	sudo -i puppet resource package $@ ensure=latest

#present-$(subst present-,x,%): | puppet-agent
#	sudo -i puppet resource package $@ ensure=present

#app-%: testfile-x
#	@info app-$(subst app-,,$<)

#testfile-%: 
#	@echo touch $<

###
### firefox
###

firefox: .firefox # Install firefox

.firefox:
	sudo apt-get install firefox -qqy
	touch $@

###
### google-chrome
###

chrome: .chrome # Setup Google Chrome
	@echo "$@ ${OK_STRING}"
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

i3: .i3-install .i3-dependencies .i3-settings # Setup i3
	@echo "$@ ${OK_STRING}"

.i3-install: /var/lib/dpkg/info/i3.list | upgrade 
/var/lib/dpkg/info/i3.list:
	sudo apt install i3 -y

.i3-dependencies: | upgrade 
	sudo apt install \
		suckless-tools i3-wm gnome-settings-daemon unclutter gnome-tweak-tool gnome-session \
		alsa-utils volumeicon-alsa disper libnotify-bin meld s3cmd gconf2 wget curl\
		feh xinput gnome-settings-daemon j4-dmenu-desktop i3status -y 
	sudo apt-get install python-pip -qqy
	pip install i3-py
	@touch $@

.i3-settings:
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
	@echo "$@ ${OK_STRING}"

###
### e2
###

# e2guardian
e2: .e2-install .e2-config  # Setup e2guardian
	@echo "$@ ${OK_STRING}"

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
	@rm -f .e2-install .e2guardian-config
	@echo "$@ ${OK_STRING}"

.SILENT: .e2guardian-mrproper
.e2-mrproper: | .e2-install
	sudo stow -t /etc -D e2guardian
	sudo apt purge e2guardian -qy
	sudo unlink /etc/e2guardian

#sudo tar -czvf /etc/e2guardian.tgz /etc/e2guardian
#sudo rm -Rf /etc/e2guardian
#sudo mv /etc/e2guardian{.rpmorg}