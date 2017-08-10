#!/bin/bash

TEMPLATELOCATION=${1:-file://$(pwd)/cloudformation.yml}
REGION=${2:-us-west-2}

VALIDATE="aws --region ${REGION} cloudformation validate-template --template-body ${TEMPLATELOCATION}"
echo ${VALIDATE}
${VALIDATE}
