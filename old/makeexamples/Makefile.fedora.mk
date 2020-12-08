# Fedora

virtualbox: /usr/bin/virtualbox
vagrant: /usr/bin/vagrant
direnv: /usr/bin/direnv
bundle: /usr/bin/bundle
java: /usr/bin/java
git: /usr/bin/git
jq: /usr/bin/jq

/usr/bin/bundle:
	${sudo} dnf groupinstall -y rpm-development-tools development-tools c-development
	${sudo} dnf install -y ruby-devel
	${sudo} dnf install -y rubygem-bundler

/usr/bin/java:
	${sudo} dnf install -y java-1.8.0-openjdk

/usr/bin/virtualbox:
	curl -s https://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo | ${sudo} tee /etc/yum.repos.d/virtualbox.repo >/dev/null
	${sudo} dnf clean all
	${sudo} dnf install -y VirtualBox-5.2

/usr/bin/vagrant /usr/bin/direnv /usr/bin/python /usr/bin/git /usr/bin/jq /usr/bin/curl: /usr/bin/%:
	${sudo} dnf install -y $*
