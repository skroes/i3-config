#.SILENT:

###
### main
###

git: .git-stow git/.gitconfig ### basic local gitconfig
	$(call oksign,$@)

git-clean:
	rm -f .git-stow
	rm -f .git-configured-for-github

github-enabled: git .git-configured-for-github ### ssh access enabled for github
	$(call oksign,$@)

###
### sub
###

.git-configured-for-github: | ssh-public-key .local.known_hosts.github.com
	test -f ~/.ssh/known_hosts || cp .local.known_hosts.github.com ~/.ssh/known_hosts
	ssh -T git@github.com -o UserKnownHostsFile=.local.known_hosts.github.com 2>&1 | GREP_COLOR='1;32' grep "You've successfully authenticated" --color \
	|| (echo -e "\n\033[36m ... You need to add this public key to github ... \033[0m\n" \
	&& cat ~/.ssh/id_rsa.pub \
	&& echo -e "\n\033[36m ... What are your waiting for? head to https://github.com/login ... \033[0m\n" \
	&& exit 1)
	touch $@

#GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$' || true)
git/.gitconfig:
	cp git/.gitconfig.dist $@
	git config --file git/.gitconfig user.name $(GIT_AUTHOR_NAME)
	git config --file git/.gitconfig user.email $(GIT_AUTHOR_EMAIL)
	git config --file git/.gitconfig github.user $(GITHUB_USER)
#git config --file git/.gitconfig user.signingkey $(GIT_SIGNING_KEY)

.git-stow: git/.gitconfig
	-@test -L ~/.gitconfig && (unlink ~/.gitconfig )
	-@test -f ~/.gitconfig && (echo cleaning ~/.gitconfig; mv ~/.gitconfig{,.org} 2>/dev/null )
	-@test -L ~/.gitignore_global && (unlink ~/.gitignore_global)
	-@test -f ~/.gitignore_global && (echo cleaning ~/.gitignore_global; mv ~/.gitignore_global{,.org} 2>/dev/null )
	stow --target ~ git --adopt
	touch $@

###
### github main
###

github: .github-update-remote .github-configured-i3 ## enable github configured

github-clean:
	rm -f .local.known_hosts.github.com .github-update-remote

github-mrproper:
	rm -f .github-configured-i3 

###
### github sub
###

.github-update-remote:
	#git remote remove origin
	#git remote add origin git@github.com:skroes/i3-config.git
	git remote set-url --push origin git@github.com:skroes/i3-config.git
	git fetch
	#git branch --set-upstream-to origin/master
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

###
###
###
blablagit:
	git fetch origin ; git diff --name-only master origin/master 