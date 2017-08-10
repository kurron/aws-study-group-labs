#!/bin/bash

STACKNAME=${1:-Weapon-X}

DESTROY="aws cloudformation delete-stack --stack-name ${STACKNAME}"
echo ${DESTROY}
${DESTROY}
