# Targets to manage updates of git repositories used

# Update command updates everything to latest, this command does not
# care if updates are needed, it will force update everything.
.PHONY: update update_repositories
update: update_repositories ## Update repositories to latest
	@echo -e "Latest sources for kitchen have been fetched."

update_repositories: .update_./ .update_hiera/ .update_environments/lab/

.update_%: | %/.git
	cd $*; git pull --rebase
	@echo
