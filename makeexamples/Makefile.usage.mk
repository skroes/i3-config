.PHONY: help helpmsg usagemsg usage usage-all usage-all-hidden readme
.SILENT: help helpmsg usagemsg usage usage-all usage-all-hidden readme

COLOR      := "\\033[36m"
NOCOLOR    := "\\033[0m"

helpmsg:
	echo -e "${COLOR}infra-devbox${NOCOLOR} - Provides infrastructure for Bovaris devbox"
	echo -e "See README.md for detailed usage information\n"

usagemsg:
	echo -e "usage: make [${COLOR}target${NOCOLOR}]\n"
 	echo "targets:"

help: helpmsg usagemsg
	grep -hE '^[0-9a-zA-Z_-]+:.*?### .*$$' $(MAKEFILE_LIST) | grep -vw 'usage-all' | sort | awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

usage: usagemsg ### Show more targets options
	grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -vw 'usage:' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

usage-all: usagemsg ## show all available targets
	grep -hE '^[0-9a-zA-Z_-]+:.*?.*$$' $(MAKEFILE_LIST) | egrep -vw 'usage:|usage-all:' | sort | awk 'BEGIN {FS = ":.*?#"}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

usage-all-hidden: usagemsg
	grep -hE '^.[0-9a-zA-Z_-]+:.*?.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?#"}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}' | uniq

readme: ### Read the README file
	xdg-open http://nu.nl/ || open http://nu.nl
