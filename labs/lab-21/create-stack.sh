#!/bin/bash

STACKNAME=${1:-Weapon-X}
PROJECTNAME=${2:-Weapon-X}
PURPOSE=${3:-Weapon-X}
CREATOR=${4:-CloudFormation}
ENVIRONMENT=${5:-Weapon-X}
NOTES=${6:-Weapon-X}
SUBNET=${7:-subnet-508eaf19}
TEMPLATELOCATION=${8:-file://$(pwd)/cloudformation.yml}

VALIDATE="aws cloudformation validate-template --template-body ${TEMPLATELOCATION}"
echo ${VALIDATE}
${VALIDATE}

CREATE="aws cloudformation create-stack --stack-name ${STACKNAME} \
                                        --template-body ${TEMPLATELOCATION} \
                                        --parameters ParameterKey=SubnetId,ParameterValue=${SUBNET} \
                                        --tags Key=Project,Value=${PROJECTNAME} \
                                               Key=Purpose,Value=${PURPOSE} \
                                               Key=Creator,Value=${CREATOR} \
                                               Key=Environment,Value=${ENVIRONMENT} \
                                               Key=Freetext,Value=${NOTES}"
echo ${CREATE}
${CREATE}

