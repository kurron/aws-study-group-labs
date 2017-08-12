#!/bin/bash

ZIP="https://releases.hashicorp.com/terraform/0.10.0/terraform_0.10.0_linux_amd64.zip"
CURL="curl --output /tmp/terraform.zip ${ZIP}"

echo ${CURL}
${CURL}

UNZIP="sudo unzip /tmp/terraform.zip -d /usr/local/bin"
echo ${UNZIP}
${UNZIP}

VERIFY="terraform --version"
echo ${VERIFY}
${VERIFY}
