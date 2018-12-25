SHELL=/bin/bash
TMPDIR?=/tmp
sudo?=sudo

# Prevent running as root (it will mess up permissions)
ifeq ($(shell whoami),root)
ifndef SKIP_ROOT_CHECK
$(error Do not run as root or using sudo!)
endif
endif

# Detect the OS in use
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
os = darwin
else ifneq (,$(shell grep ubuntu /etc/os-release))
os = ubuntu
else ifneq (,$(shell grep fedora /etc/os-release))
os = fedora
else
$(error Unsupported system ${os})
endif

# Ensure SSH agent is enabled for Git commands
agent_enabled = $(shell pgrep ssh-agent)
ifndef SKIP_SSH_AGENT_CHECK
ifeq (${agent_enabled},)
$(error SSH-agent is not running, start agent using: `eval $$(ssh-agent)` or add this line to `~/.profile` to do it automatically at login.)
endif
identities = $(shell ssh-add -l|grep -v "The agent has no identities.")
ifeq (${identities},)
$(error No SSH identities configured in ssh-agent, please add a key using: `ssh-add ~/.ssh/id_rsa` or check Requirements section in the manual!)
endif
endif


# Define default variables
vm_image = bento-centos-74
git_base = ssh://git@bitbucket.bigcorp4all.com

workdir=.
# some paths to support an embedded ruby environment so
# we don't have to mess with system ruby
bundle_path=${workdir}/vendor/bundle

# variables to invoke specific commands from embedded ruby environment
ifneq ($(shell uname -a|grep Microsoft),)
kitchen=env VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1 bundler exec kitchen
else
kitchen=bundler exec kitchen
endif
r10k=bundler exec r10k
git=GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git

# By default show help
.DEFAULT_GOAL := help

# Setup all dependencies for running Kitchen
setup: kitchen hiera/ puppet_modules ### Setup all dependencies for running Kitchen
	@echo "Setup done."

include Makefile.usage.mk
# include user override settings file: Makefile.settings.
-include Makefile.settings.mk

# include team specific targets.
include Makefile.bovaris.mk
include Makefile.devbox.mk
include Makefile.ova.mk

# include other utility makefiles.
include Makefile.update.mk

# empty line to separate info from action in the output
$(info )

# update kitchen status files if state has changed outside of kitchen (system reboot, shutdown via virtualbox, etc)
# $(shell scripts/remove_stale_kitchen_state.sh >/dev/null)

# remove deprecated config override.
$(shell rm -f .kitchen.local.yml > /dev/null)

# Kitchen box lifecycle management
vms=$(shell  sed -nE '/suites:/,$$ s/  - name: (.*)/\1/p' kitchen.yml)
$(addprefix vm_,${vms}): vm_%: .converged_%
destroy_vms=$(addprefix destroy_,${vms})

hiera_files=$(shell find hiera/ -type f -name "*.yaml" 2>/dev/null)
puppet_modules=$(shell find environments/lab/modules/ -maxdepth 3 -type f -name HEAD 2>/dev/null)

.converged_%: ${hiera_files} ${puppet_modules} | kitchen
	# check if VM to be converged was created before but has been shutdown in the meantime (eg: due to host reboot)
	scripts/restart_vm_if_created_but_not_up.sh $*
	${kitchen} converge $*

$(addprefix destroy_,${vms}): destroy_%: | kitchen
	${kitchen} destroy $*

$(addprefix verify_,${vms}): verify_%: vm_% | kitchen
	${kitchen} verify $*

.PHONY: kitchen vagrant virtualbox direnv
kitchen: | rubygem-kitchen virtualbox vagrant direnv jq # Manage kitchen and its dependencies

# Git repositories needed
puppet-environments/: | puppet-environments/.git
hiera/: | hiera/.git

%/.git: | git
	${git} clone --quiet ${git_base}/infra/$*.git $*

# Puppet modules for the lab environment
.PHONY: puppet_modules
puppet_modules: | environments/lab/modules/.installed

environments/lab/modules/.installed: environments/lab/.git | rubygem-r10k
	cd environments/lab && ${r10k} puppetfile install -v info
	@touch $@

environments/lab/.git:
	git clone --quiet --branch lab ${git_base}/infra/puppet-environments.git environments/lab/

# Install everything used for kitchen command
.PHONY: rubygem-kitchen rubygem-r10k
rubygem-kitchen rubygem-r10k: rubygem-%: ./vendor/bundle/.installed
./vendor/bundle/.installed: Gemfile.lock | bundle
	# install ruby dependencies
	bundler install --quiet --path ${bundle_path}
	@touch $@

# Packages that can possibly be installed using system package manager
system_packages=virtualbox ruby-dev ruby-bundler
pkgs=$(addprefix pkg-,${system_packages})
.PHONY: ${pkgs}
# The actual implementations of pkg-% recipies is in OS specific Makefiles, eg: .Makefile.ubuntu.

vagrant_plugins=vagrant-hostmanager
$(addprefix vagrant-plugin-,${vagrant_plugins}): vagrant-plugin-%: ${HOME}/.vagrant.d/.plugin-installed-%
${HOME}/.vagrant.d/.plugin-installed-%: | vagrant
	vagrant plugin install $*
	@touch $@

# Cleanup scripting

# Do cleanup of all temporary data (build artifacts, etc)
.PHONY: clean # Do cleanup of all temporary data (build artifacts, etc)
clean:

.PHONY: mrproper
mrproper: clean ## Reset everything to prestine condition (this might destroy unsaved data!)
	rm -rf hiera/ vendor/ environments/
	rm -rf ${PWD}/.tmp_*/

# include OS specific functions.
include Makefile.${os}.mk

overview.png: %.png: %.dot | dot
	dot -Tpng $< > $@

overview-make.png: overview-%.png: | dot .tmp/makefile2graph/.git
	@$(MAKE) -Bnd | .tmp/makefile2graph/make2graph | dot -Tpng -o $@

.tmp/makefile2graph/.git:
	git clone --quiet https://github.com/lindenb/makefile2graph.git .tmp/makefile2graph
	cd .tmp/makefile2graph && make

.PHONY: list
list:
	@$(MAKE) -pRrq 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

# run test suite for kitchen dependencies itself (make setup)
test:
	kitchen test kitchen-in-kitchen

# perform code quality checks
check: | /usr/bin/shellcheck
	shellcheck scripts/*.sh
