#!/bin/bash

export PACKER_LOG=activate
#export PACKER_LOG_PATH=/tmp

packer validate ami.json
packer build ami.json
