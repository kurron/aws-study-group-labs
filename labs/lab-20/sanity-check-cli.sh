#!/bin/bash

CMD='aws --region us-west-2 ec2 describe-availability-zones'
echo ${CMD}
${CMD}
