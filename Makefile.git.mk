#GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$' || true)

git/.gitconfig:
	cp gitconfig.dist $@
	git config --file git/.gitconfig user.name $(GIT_AUTHOR_NAME)
	git config --file git/.gitconfig user.email $(GIT_AUTHOR_EMAIL)
	git config --file git/.gitconfig github.user $(GITHUB_USER)
#git config --file git/.gitconfig user.signingkey $(GIT_SIGNING_KEY)

git-stow: git/.gitconfig
	@test -L ~/.gitconfig || (echo cleaning ~/.gitconfig; mv ~/.gitconfig{,.org} 2>/dev/null|| true )
	stow -t ~ -S git

git: git-stow git/.gitconfig
	@echo "$@ ${OK_STRING}"

.PHONY: git-show
git-show:
	git log --graph --full-history --all --pretty=format:"%h%x09%d%x20%s"

git-clean:
	stow -t ~ -D git
	@rm -f git/.gitconfig
	@echo "$@ ${OK_STRING}"