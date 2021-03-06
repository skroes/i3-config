
fish-config: .fish-config
.fish-config: | ${HOME}/.local/share/omf/init.fish fish .fish.omf.theme.yimmy ### install fish stow config
	-unlink ~/.config/fish/functions/fish_prompt.fish
	stow --target ~/.config/fish/ fish --adopt
	touch $@

.fish.omf.theme.yimmy: /home/serkroes/.local/share/omf/themes/yimmy
/home/serkroes/.local/share/omf/themes/yimmy:
	fish -c 'omf install yimmy &; exit'

${HOME}/.local/share/omf/init.fish: | fish
	curl -L https://get.oh-my.fish > tmp/omf-install
	fish tmp/omf-install --path=~/.local/share/omf --config=~/.config/omf

###
### fish-core
###

fish: | .fish-add-to-shell ### install fish
	@grep -q '^exec fish' ~/.bashrc || (echo '# from here on run fish' >> ~/.bashrc; echo 'exec fish' >> ~/.bashrc)
	$(call oksign,$@)

.fish-add-to-shell: | fish-exec
	@sudo grep -q $(shell command -v fish || echo burp) /etc/shells || ( echo /usr/local/bin/fish | sudo tee -a /etc/shells2 )
	touch $@

fish-exec: /usr/bin/fish

/usr/bin/fish: | latest-fish

fish-clean:
	rm -f .fish .fish-config .fish-add-to-shell

nord-theme-gnome-terminal:
	git clone https://github.com/arcticicestudio/nord-gnome-terminal.git /tmp/nord-gnome-terminal
	/tmp/nord-gnome-terminal/src/nord.sh
	rm -Rf /tmp/nord-gnome-terminal/