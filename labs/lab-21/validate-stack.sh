#!/bin/bash

TEMPLATELOCATION=${1:-file://$(pwd)/cloudformation.yml}

VALIDATE="aws cloudformation validate-template --template-body ${TEMPLATELOCATION}"
echo ${VALIDATE}
${VALIDATE}
