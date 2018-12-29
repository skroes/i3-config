
ssh-add:
	@ssh-add --quiet -l || ( echo "Attempt to load key ..."; ssh-add ~/.ssh/id_rsa )

ssh-public-key: ~/.ssh/id_rsa.pub

~/.ssh/id_rsa.pub:
	ssh-keygen -b 4096 -f ~/.ssh/id_rsa
