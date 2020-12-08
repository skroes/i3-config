
ssh-add:
	@ssh-add --quiet -l || ( echo "Attempt to load key ..."; ssh-add ~/.ssh/id_ed25519 )

ssh-public-key: ~/.ssh/id_ed25519.pub

~/.ssh/id_rsa.pub:
	echo
	echo "remove old id_rsa. generate new id_ed25519"
	echo