# Make recipies for Bovaris/Helixs Consolidated Devbox

devbox_host = 192.168.50.42

full_devbox: $(addprefix .deployed_devbox_,${all_domains} ${all_adapters}) $(addprefix .vdb_devbox_,${all_vdbs}) ### Deploy devbox with all domains and adapters

.deployed_devbox_breeding-domain: .vdb_devbox_breeding
.deployed_devbox_customer-domain: .vdb_devbox_customer
.deployed_devbox_fertility-domain: .vdb_devbox_fertility
.deployed_devbox_herdbook-domain: .vdb_devbox_herdbook

$(addprefix .deployed_devbox_,${all_domains} ${all_adapters}): .deployed_devbox_%: ${bovaris_sources}/%/.git | devbox java
	${PWD}/scripts/deploy-java.sh ${bovaris_sources}/$* ${devbox_host}
	touch $@

$(addprefix .vdb_devbox_,${all_vdbs}): .vdb_devbox_%: ${bovaris_sources}/dv-%/.git | devbox ${bovaris_sources}/build-scripts/.git /usr/bin/python
	python ${bovaris_sources}/build-scripts/scripts/vdbDeploy.py \
		-h ${devbox_host} -v $*.vdb -f ${bovaris_sources}/dv-$*/$*-vdb.vdb \
		-u admin -p admin -s local -am basic -mp 9992
	@touch $@

devbox: .converged_bovaris-helixs1 ### Create, converge and verify the devbox
	kitchen verify bovaris-helixs1
	@echo
	@echo -e " _____________________________________"
	@echo -e "< Helixs Devbox is setup and verified >"
	@echo -e " -------------------------------------"
	@echo -e "      \\   ^__^"
	@echo -e "       \\  (oo)\\_______"
	@echo -e "          (__)\\       )\\/\\"
	@echo -e "              ||----w |"
	@echo -e "              ||     ||"
	@echo
	@echo -e "\nJboss AS is running at: "
	@echo -e "    http://${devbox_host}:9990/console/App.html"
	@echo -e "\nKeycloak/RHSSO is running at: "
	@echo -e "    http://${devbox_host}:19990/console/App.html"
	@echo -e "\nJboss AMQ is running at: "
	@echo -e "    http://${devbox_host}:8161/console/welcome"
	@echo -e "\nTo login to the Devbox using SSH:"
	@echo -e "    kitchen login bovaris-helixs"
	@echo -e "or if your credentials are configured for SSH:"
	@echo -e "    ssh LastnameF@${devbox_host}"
	@echo -e "\ndefault user and password are: admin and admin\n"

update_devbox: update .converged_bovaris-helixs1 ### Update all external sources (hiera, puppet modules) and create/update the devbox

destroy_devbox: ### Get rid of the devbox VM
	kitchen destroy bovaris-helixs1

# Generate hiera config file that consolidates all bovaris roles into a single role.
hiera-bovaris.yaml: scripts/hiera-bovaris-yaml.py
	$< > $@
