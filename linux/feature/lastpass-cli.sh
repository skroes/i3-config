#!/bin/bash
set -e
sudo apt-get --no-install-recommends -yqq install \
  bash-completion \
  build-essential \
  cmake \
  libcurl4  \
  libcurl4-openssl-dev  \
  libxslt1-dev \
  libssl-dev  \
  libxml2 \
  libxml2-dev  \
  libssl1.1 \
  pkg-config \
  ca-certificates \
  xclip \
  asciidoc \
  xsltproc

cd tmp
git clone https://github.com/lastpass/lastpass-cli.git || true 
cd lastpass-cli
make
sudo make install
#sudo make install-doc
cd ..

echo
echo "now login: lpass login x@c.x"
echo
echo "quick ref see: https://lastpass.github.io/lastpass-cli/lpass.1.html"
echo
#lpass status | grep -i 'logged in as'
