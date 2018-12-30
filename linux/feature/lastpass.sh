#!/bin/bash
set -e
sudo apt-get --no-install-recommends -yqq install \
  bash-completion \
  build-essential \
  cmake \
  libcurl4  \
  libcurl4-openssl-dev  \
  libssl-dev  \
  libxml2 \
  libxml2-dev  \
  libssl1.1 \
  pkg-config \
  ca-certificates \
  xclip
pwd

cd tmp
git clone https://github.com/lastpass/lastpass-cli.git || true 
cd lastpass-cli
make
sudo make install
#sudo apt-get install asciidoc xsltproc
#sudo make install-doc