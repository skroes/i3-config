fish: /usr/bin/fish
	$(call oksign,$@)

/usr/bin/fish: | latest-fish

fish-clean:
