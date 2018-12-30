#!/bin/bash
set -e
cd tmp

#https://download.cloud.lastpass.com/pocket/pocket_x64.tar.bz2
#https://download.cloud.lastpass.com/sesame/sesame_x64.tar.bz2

LASTPASSFILE=lplinux.tar.bz2
curl -L -S --progress-bar https://download.cloud.lastpass.com/linux/${LASTPASSFILE} -o ${LASTPASSFILE}

checksum=b517c3dfa350d928957fe23e03fc4509e0673472

if ! echo "$checksum ${LASTPASSFILE}" | shasum -; then
    echo "Checksum failed" >&2
    exit 1
fi

tar xjvf ${LASTPASSFILE}
./install_lastpass.sh