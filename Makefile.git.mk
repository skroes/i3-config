#GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$' || true)

git/.gitconfig:
	cp gitconfig.dist $@
	git config --file git/.gitconfig user.name $(GIT_AUTHOR_NAME)
	git config --file git/.gitconfig user.email $(GIT_AUTHOR_EMAIL)
	git config --file git/.gitconfig github.user $(GITHUB_USER)
#git config --file git/.gitconfig user.signingkey $(GIT_SIGNING_KEY)

git-stow: git/.gitconfig
	@test -L ~/.gitconfig || (unlink ~/.gitconfig || true )
	@test -f ~/.gitconfig || (echo cleaning ~/.gitconfig; mv ~/.gitconfig{,.org} 2>/dev/null|| true )
	@stow --target ~ git

git: git-stow git/.gitconfig
	$(call echo,$@ ${OK_STRING})

git-update-remote:
	git remote remove origin
	git remote add origin git@github.com:skroes/i3-config.git

git-clean:
	stow --target ~ -D git
	@rm -f git/.gitconfig
	@echo "$@ ${OK_STRING}"