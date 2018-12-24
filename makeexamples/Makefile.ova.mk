# Generate a single OVA that can be used to run a complete Helixs platform in VirtualBox
output-virtualbox-ovf/devbox.ova: ${TMPDIR}/CentOS-7.VirtualBox/box.ovf | /usr/local/bin/packer
	env SOURCE_OVA=$< /usr/local/bin/packer build -on-error=ask data/packer-template-devbox.json

${TMPDIR}/%/box.ovf: ${TMPDIR}/%.box
	mkdir -p $(dir $@)
	tar -xv -C $(dir $@) -f $<
	@touch $@

${TMPDIR}/CentOS-7.VirtualBox.box: /usr/bin/curl
	@mkdir -p ${TMPDIR}/
	/usr/bin/curl -s https://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1805_01.VirtualBox.box > $@

clean:
	rm -rf output-virtualbox-ovf/
