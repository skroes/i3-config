
fish-stow: | ${HOME}/.local/share/omf/init.fish fish ### install fish stow config
	stow --target ~/.config/fish fish --adopt

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
	rm -f .fish .fish-add-to-shell
