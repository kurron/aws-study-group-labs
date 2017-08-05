#!/bin/bash

# Modify this script so that it creates an EC2 instance with the following tags:
# * Name - your "pet" name for the item, eg. Alpha
# * Project - what logical group does the item belong to, eg. TLO Standalone
# * Purpose - what role the item is playing, eg. MySQL
# * Creator - the person or tool that created the item, eg. rkurr@transparent.com or Ansible
# * Environment - what context the item will be used in, eg, production, test, all, performance
# * Freetext - notes that don't fall into any of the above categories

# Alter these values as needed
REGION='us-west-2'
IMAGE='ami-6df1e514'
COUNT='1'
TYPE='t2.nano'
KEY='asgard-lite-test'
GROUP='sg-54cc3d2e'
SUBNET='subnet-508eaf19'

CMD="aws --region ${REGION} \
         ec2 run-instances"

echo ${CMD}
${CMD}
