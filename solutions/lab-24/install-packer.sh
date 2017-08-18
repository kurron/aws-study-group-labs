#!/bin/bash

ZIP="https://releases.hashicorp.com/packer/1.0.3/packer_1.0.3_linux_amd64.zip"
CURL="curl --output /tmp/packer.zip ${ZIP}"

echo ${CURL}
${CURL}

UNZIP="sudo unzip /tmp/packer.zip -d /usr/local/bin"
echo ${UNZIP}
${UNZIP}

VERIFY="packer --version"
echo ${VERIFY}
${VERIFY}

