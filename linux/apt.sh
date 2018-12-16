#!/usr/bin/env bash

# Update, upgrade
sudo apt-get update
#sudo apt-get upgrade -y
#sudo apt-get dist-upgrade -f

# Some necessary Unix tools
sudo apt-get install curl wget vim stow tree git-core build-essential make -y

# Ruby dependencies
# apt-get install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev
