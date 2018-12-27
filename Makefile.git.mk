#.SILENT:

###
### git
###

git: .git-stow git/.gitconfig
	$(call oksign,$@)

git-clean:
	rm -f git/.gitconfig .local.known_hosts.github.com
	stow --target ~ -D git
	rm -f .git-stow

#GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$' || true)
git/.gitconfig:
	cp gitconfig.dist $@
	git config --file git/.gitconfig user.name $(GIT_AUTHOR_NAME)
	git config --file git/.gitconfig user.email $(GIT_AUTHOR_EMAIL)
	git config --file git/.gitconfig github.user $(GITHUB_USER)
#git config --file git/.gitconfig user.signingkey $(GIT_SIGNING_KEY)

.git-stow: git/.gitconfig
	@test -L ~/.gitconfig || (unlink ~/.gitconfig || true )
	@test -f ~/.gitconfig || (echo cleaning ~/.gitconfig; mv ~/.gitconfig{,.org} 2>/dev/null || true )
	stow --target ~ git
	touch $@

###
### github main
###

github: .github-update-remote .github-configured-i3 ## enable github configured

github-clean:
	rm -f .local.known_hosts.github.com .github-update-remote

github-mrproper:
	rm -f .github-configured-i3 

### github sub

.github-update-remote:
	git remote remove origin
	git remote add origin git@github.com:skroes/i3-config.git
	git fetch
	git branch --set-upstream-to origin/master
	touch $@

.github-configured-i3: | ssh-public-key .local.known_hosts.github.com
	test -f ~/.ssh/known_hosts || cp .local.known_hosts.github.com ~/.ssh/known_hosts
	@ssh -T git@github.com -o UserKnownHostsFile=.local.known_hosts.github.com 2>&1 | grep "You've successfully authenticated" --color \
	|| (echo -e "\n\033[36m ... You need to add this public key to github ... \033[0m\n" \
	&& cat ~/.ssh/id_rsa.pub \
	&& echo -e "\n\033[36m ... What are your waiting for? head to https://github.com/login ... \033[0m\n" \
	&& exit 1)
	touch $@

.local.known_hosts.github.com: 
	@ssh-keyscan -t rsa github.com > $@
