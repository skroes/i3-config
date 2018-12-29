fish: | .fish-add-to-shell
	@grep -q '^exec fish' ~/.bashrc || (echo '# from here on run fish' >> ~/.bashrc; echo 'exec fish' >> ~/.bashrc)
	$(call oksign,$@)

.fish-add-to-shell: | exec-fish
	@sudo grep -q $(shell command -v fish || echo burp) /etc/shells || ( echo /usr/local/bin/fish | sudo tee -a /etc/shells2 )
	touch $@

exec-fish: /usr/bin/fish

/usr/bin/fish: | latest-fish

fish-clean:
	rm -f .fish .fish-add-to-shell
