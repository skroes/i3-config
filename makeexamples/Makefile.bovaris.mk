# Bovaris specific variables/targets/recipies

## High level workflow targets, defines which applications are needed to perform certain tasks.

# For development on US customer related features
develop-us-customers: customer-domain us-customer-adapter
	@echo "$@ done"

develop-we-customers: customer-domain we-customer-adapter
	@echo "$@ done"

# The develop-helixs target bring up a complete helixs development platform.
# This includes all domains, adapters and dvs. As well as all VM's required for
# these components to deploy and run.
.PHONY: bovaris
develop-helixs: helixs_platform all-domains all-adapters
	@echo
	@echo -e " __________________________"
	@echo -e "< Helixs Platform is ready >"
	@echo -e " --------------------------"
	@echo -e "      \\   ^__^"
	@echo -e "       \\  (oo)\\_______"
	@echo -e "          (__)\\       )\\/\\"
	@echo -e "              ||----w |"
	@echo -e "              ||     ||"
	@echo
	@echo -e "\nJboss AS is running at: "
	@echo -e "    http://${bovaris_host}:9990/console/App.html"
	@echo -e "\nJboss AS adapters is running at: "
	@echo -e "    http://${bovarisadapters_host}:9990/console/App.html"
	@echo -e "\nKeycloak/RHSSO is running at: "
	@echo -e "    http://${rhsso_host}:9990/console/App.html"
	@echo -e "\nJboss AMQ is running at: "
	@echo -e "    http://${jamq_host}:8161/console/welcome"
	@echo -e "\ndefault user and password are: admin and admin\n"
	@echo -e "\nTo login into a host using SSH do:"
	@echo -e "    ssh LastnameF@${bovaris_host}\n"

## Implementation of high level target dependencies

# directory where bovaris repositories are expected to be
bovaris_sources?=./bovaris
bovaris_git_base=ssh://git@bitbucket.org/bigcorp4all

bovaris_host ?= bovaris-jbossas1.bovaris.io
bovarisadapters_host ?= bovarisadapters-jbossas1.bovaris.io
jbossdv_host ?= bovaris-jbossdv1.bovaris.io
jamq_host ?= bovaris-jbossamq1.bovaris.io
rhsso_host ?= bovaris-rhsso1.bovaris.io

application-servers=bovaris-jbossas1 bovarisadapters-jbossas1
database=bovaris-edbpostgres1
queue=bovaris-jamq1
keycloak=bovaris-rhsso1

deployable-platform=${application-servers} ${queue} ${database}
helixs-platform=${deployable-platform} ${keycloak}

deployable_platform: $(addprefix vm_,${deployable-platform})
helixs_platform: $(addprefix vm_,${helixs-platform})

verify-deployable_platform: $(addprefix verify_,${deployable-platform})
verify-helixs_platform: $(addprefix verify_,${helixs-platform})

destroy-deployable_platform: $(addprefix destroy_,${deployable-platform})
destroy-helixs_platform: $(addprefix destroy_,${helixs-platform})

# Lists of components in the Helixs platform, these are also the names of their respective Git repositories.
all_domains=\
	breeding-backend \
	breeding-domain \
	bull-domain \
	communication-domain \
	bigcorp-service-domain \
	customer-domain \
	favv-domain \
	fakebook-domain \
	fertility-domain \
	health-domain \
	herdbook-domain \
	housing-domain \
	mandate-catalog \
	milk-domain \
	mineral-domain \
	rvo-domain \
	user-domain

all_adapters=\
	aeu-track-and-trace-adapter \
	amis-adapter \
	agrifirm-adapter \
	bigcorpanimals-adapter \
	customer-user-pump \
	iris-adapter \
	meld-adapter \
	sirematch-adapter \
	us-customer-adapter \
	wave-adapter \
	stub-wave \
	we-customer-adapter

all_vdbs=\
	breeding \
	customer \
	fertility \
	herdbook
all_dvs=$(addprefix dv-,${all_vdbs})

# Targets for
all-domains: ${all_domains} .updated_etc_hosts
all-adapters: ${all_adapters} .updated_etc_hosts
all-dvs: ${all_dvs} .updated_etc_hosts

# To deploy and run a bovaris component the source from git is required as well as the jbossas servers with vdb's installed.
${all_domains} ${all_adapters}: %: ${bovaris_sources}/%/.git .deployed_%

# Configure deploy target host based on component name
.deployed_%: deploy_host=${bovaris_host}
.deployed_%-adapter: deploy_host=${bovarisadapters_host}
.deployed_%-adapter-validater: deploy_host=${bovarisadapters_host}
.deployed_customer-user-pump: deploy_host=${bovarisadapters_host}
.deployed_stub-wave: deploy_host=${bovarisadapters_host}
.deployed_breeding-domain: dv-breeding
.deployed_we-customer-adapter: dv-customer
.deployed_fertility-domain: dv-fertility
.deployed_herdbook-domain: dv-herdbook

$(addprefix .deployed_,${all_domains} ${all_adapters}): .deployed_%: ${bovaris_sources}/%/.git .updated_etc_hosts | deployable_platform java
	${PWD}/scripts/deploy-java.sh ${bovaris_sources}/$* ${deploy_host}
	touch $@

# make sure sources are checked out before make determined which version of above deploy target to use
${bovaris_sources}/%/gradlew: ${bovaris_sources}/%/.git
${bovaris_sources}/%/mvnw: ${bovaris_sources}/%/.git

# # This list can include components that should not be deployed
# bovaris_disabled_components?=\
# 	# EOL

# List of bovaris repositories to check out
bovaris_repos=$(patsubst %,${bovaris_sources}/%/.git,${all_adapters} ${all_domains} ${all_vdbs} ${all_dvs} build-scripts)
bovaris_repos: ${bovaris_repos}

.PRECIOUS: ${bovaris_sources}/%/.git
${bovaris_repos}: ${bovaris_sources}/%/.git:
	${git} clone --quiet --branch develop ${bovaris_git_base}/$*.git ${bovaris_sources}/$*

# Deploy vdbs
# The list of vdb's that are loaded
${all_dvs}: dv-%: ${bovaris_sources}/dv-%/.git .vdb_%

$(addprefix .vdb_,${all_vdbs}): .vdb_%: ${bovaris_sources}/dv-%/.git .converged_bovaris-jbossdv1 | ${bovaris_sources}/build-scripts/.git /usr/bin/python
	python ${bovaris_sources}/build-scripts/scripts/vdbDeploy.py \
		-h ${jbossdv_host} -v $*.vdb -f ${bovaris_sources}/dv-$*/$*-vdb.vdb \
		-u admin -p admin -s local -am basic -mp 9992
	@touch $@

# Update entries in the /etc/hosts files with hostnames for all boxes
.updated_etc_hosts: .etc_hosts
	# remove all previously added lines and add new ones
	${sudo} sed -i.bck -n -e '/# from Makefile.bovaris/!p' /etc/hosts
	cat $^ | ${sudo} tee -a /etc/hosts
ifneq ($(shell uname -a|grep Microsoft),)
	# on windows we can't break out of de WSL with admin right to update the hosts file, ask user to do it for us
	(grep bovaris /mnt/c/Windows/System32/drivers/etc/hosts && touch $@)|| echo -e "\n\n\e[33mAdd the following lines to C:/Windows/System32/drivers/etc/hosts:\e[0m\n\n$$(cat .etc_hosts)"
else
	@touch $@
endif

# Allow to manually update hosts file
.etc_hosts: | jq
	ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' < kitchen.yml| \
	jq -r '.suites[] | select(.name | contains("bovaris")) | [.driver.network[0][1].ip, .name + ".bovaris.io " + .altname + " # from Makefile.bovaris"] | join(" ")'  > $@
	echo "192.168.51.211 dev-wildfly.bovaris.io # from Makefile.bovaris" >> $@

clean_bovaris:
	rm -f .deployed_*
