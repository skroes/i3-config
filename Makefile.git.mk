#GIT_SIGNING_KEY=$(shell gpg --list-keys $(GIT_AUTHOR_EMAIL) | grep -v "^pub\\|^uid" | grep -o '.\{8\}$$' || true)

git: git/.gitconfig
	stow -t ~ -S git

git/.gitconfig:
	cp gitconfig.dist $@
	git config --global user.name $(GIT_AUTHOR_NAME)
	git config --global user.email $(GIT_AUTHOR_EMAIL)
	git config --global github.user $(GITHUB_USER)
	#git config --global user.signingkey $(GIT_SIGNING_KEY)

.PHONY: git-show
git-show: ## do something
	git log --graph --full-history --all --pretty=format:"%h%x09%d%x20%s"

clean:
	@echo 'Remove Git config'
	#stow -t ~ -D git
	rm -rf git/.gitconfig

mrproper: clean
	rm .vscode 
