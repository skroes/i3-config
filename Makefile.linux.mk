
linux: update-repo vscode git i3 e2guardian #! installs all requirements for Linux

linux-clean: packages-clean i3-clean git-clean e2-clean packages-clean

#%:app-=l)
#app-%: | update-repo
#	@bash ${TOPDIR}/linux/apps/$@.sh

.PHONY: basic_%
basic_%: %.c
	@echo gcc -g -o $* $<

#lala_oef:#
#	@echo $(patsubst .*_, "", $@)

#basic_abc: $(patsubst .*_, " ", $@).c
#		@echo gcc -g -o  $(patsubst .*_, " ", $@)    $(patsubst .*_, " ", $@).c

objects = iets*

foo : $(objects)
	@echo cc -o foo $(CFLAGS) $(objects)

update-repo: .update-repo
	@echo ${OK_STRING} $@
.update-repo:
	sudo apt update -qq
	touch $@

upgrade: | .upgrade ## Upgrade OS
	@echo "$@ ${OK_STRING}"
.upgrade:
	sudo apt upgrade -y
	sudo apt autoremove -y
	touch $@

regular-packages:
	sudo apt install stow -y

puppet-agent: .puppet-agent ## installs puppet5 on ubuntu 18.04
	@echo "$@ ${OK_STRING}"
.puppet-agent:
	wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
	sudo dpkg -i puppet5-release-bionic.deb
	rm puppet5-release-bionic.deb
	sudo apt update
	sudo apt install puppet-agent
	touch $@

/usr/bin/code: vscode
vscode: .vscode ## Installs vscode
	@echo "$@ ${OK_STRING}"
.vscode: | update-repo
	bash ${TOPDIR}/linux/apps/vscode.sh
	touch $@

packages-clean:
	rm -rf .vscode .puppet-agent .upgrade .update-repo

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

i3: .i3-install .i3-dependencies .i3-settings
	@echo "$@ ${OK_STRING}"

.i3-install: /var/lib/dpkg/info/i3.list | upgrade 
/var/lib/dpkg/info/i3.list:
	sudo apt install i3 -y

.i3-dependencies: | upgrade 
	sudo apt install suckless-tools i3-wm gnome-settings-daemon unclutter gnome-tweak-tool gnome-session alsa-utils volumeicon-alsa disper libnotify-bin meld s3cmd gconf2 -y 
	sudo apt-get install python-pip -y
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

objects := $(shell cd linux/apps/ && ls -1 *.sh)
#bjects := $(wildcard linux/apps/*.sh)
#$(info ${objects})
print:
	@echo vraagteken $?
	@echo wildcard $*
	@echo < $<
	@echo > $>
	touch print

# e2guardian
e2guardian: | .e2guardian-install .e2guardian-config  ## configure e2guardian
	@echo "$@ ${OK_STRING}"

.e2guardian-install: /var/lib/dpkg/info/e2guardian.list | upgrade 
/var/lib/dpkg/info/e2guardian.list:
	sudo apt install e2guardian -y

.SILENT: .e2guardian-config
.e2guardian-config: | .e2guardian-install
	@test -L /etc/e2guardian || (echo moving /etc/e2guardian; sudo rm -Rf /etc/e2guardian)
	sudo stow -t /etc -S e2guardian
	touch $@

e2-clean:
	@rm -f .e2guardian-install .e2guardian-config
	@echo "$@ ${OK_STRING}"

.SILENT: .e2guardian-mrproper
.e2guardian-mrproper: | .e2guardian-install
	sudo stow -t /etc -D e2guardian
	sudo apt purge e2guardian -y
	sudo rm -Rf /etc/e2guardian

#sudo tar -czvf /etc/e2guardian.tgz /etc/e2guardian
#sudo rm -Rf /etc/e2guardian
#sudo mv /etc/e2guardian{.rpmorg}
	