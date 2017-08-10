#!/bin/bash

STACKNAME=${1:-Weapon-X}

DESTROY="aws cloudformation xxxxxx-stack --stack-name ${STACKNAME}"
echo ${DESTROY}
${DESTROY}
