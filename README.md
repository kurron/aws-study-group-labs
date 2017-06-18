# Overview
This document contains the steps that were covered in the
[AWS 101](https://classroom.google.com/c/MjA0NzEyMjA0OFpa) labs.
Useful if you missed a class or forgot a step.

# Prerequisites
* An AWS account
* An SSH client, [OpenSSH](https://www.openssh.com/) preferred

# Lab 1: EC2 Virtual Servers
We'll deviate a bit from what was done in class and use only the Amazon
Linux distribution.

# Steps
1. Log into the AWS console
1. switch to the `N. Virginia` region -- we need everyone to be in the same region
1. Search for `ec2` in the search bar and bring up the EC2 Dashboard
1. Click `Launch Instance` and select `Amazon Linux AMI 2017.03.0 (HVM)`
1. Select `t2.micro` type and click `Next: Configure Instance Details`
1. Make sure to select a public subnet if you are **not** using the default VPC
1. Make sure that `Auto-assign Public IP` is set to `Enable`
1. Expand `Advanced Details` to reveal the `User data` section
1. Paste in the Bash script described below
1. Select `Next: Add Storage`
1. Click `Add New Volume` and keep the defaults
1. Click `Next: Add Tags` and `Add Tag`
1. One by one, add the tags described below
1. Click `Next: Configure Security Group`
1. Create a new security group using whatever `Security group name` and `Description` you want
1. Ensure that the `Source` reads `0.0.0.0/0` or you might not be able to log in
1. Click `Review and Launch` and then `Launch`
1. Either create a new SSH key or select a previously generated one
1. Click `Launch Instance`
1. Click `View Instances` at the bottom of the screen
1. Wait until `Status Checks` reads `2/2 checks passed`
1. Obtain the public ip address of your instance and ssh into it using your private key, eg `ssh -i my-private-key ec2-user@34.209.215.10`
1. `ls --all -l --human-readable`, note that `root` has created a file during creation
1. `touch ~/dolphins-suck.txt` to create a file in your home directory
1. `sudo yum update` to update the OS
1. `df --print-type --human-readable` to list the currently mounted file systems
1. `lsblk --list --fs` to list available disks
1. `sudo mkfs.ext4 -L DATA /dev/xvdb` to create an [ext4](https://ext4.wiki.kernel.org/index.php/Main_Page) file system
1. `sudo mkdir /mnt/data` to create the volume's mount point
1. `sudo mount /dev/xvdb /mnt/data` to mount the volume
1. `lsblk --list --fs` to see that the volume is now mounted
1. `sudo chown --recursive ec2-user:ec2-user /mnt/data` to make your account the volume's owner
1. `ls --all -l --human-readable /mnt` to show the new user and group values
1. `touch /mnt/data/dolphins-still-suck.txt` to put a file onto the new volume
1. `ls --all -l --human-readable /mnt/data` to prove the file exists



## User Data Bash Script
```
#!/bin/bash

FILENAME=$(date)
touch "/home/ec2-user/${FILENAME}"
```

## Instance Tags
* `Name` - the name of your instance, eg `NCC-1701`
* `Purpose` - the role or reason the instance will play in a project, eg. `lab playground`
* `Project` - the project name to attribute billing to, eg `AWS Study Group`
* `Creator` - user or tool that created the instance, eg `luke@disney.com`
* `Environment` - the context the instance is being used in, eg `production`
* `Freetext` - any notes you might to store, eg. `Root password is super-secret`

# Lab 2: EC2 Virtual Servers (continued)
We'll be observing how volumes behave and how to clone instances.

## Permanently Mounting A Volume
1. ssh into the instance we created last time
1. `df --print-type --human-readable` to list the currently mounted file systems
1. `sudo blkid /dev/xvdb` to get the UUID of the data volume
1. note the `LABEL` value
1. `sudo vi /etc/fstab`
1. add this line `LABEL=DATA  /mnt/data   ext4    defaults  1   1`
1. save the file
1. `sudo mount /mnt/data` to mount the 2nd volume
1. `sudo shutdown -r now` to reboot the box
1. ssh back into the instance
1. `df --print-type --human-readable` to list the currently mounted file systems

## Snapshotting The Data Volume
1. Click `Volumes` in the console and select the volume that is attached as `/dev/sdb`
1. Click `Actions` and `Create Snapshot`
1. Use `Data` as the name and whatever `Description` you want
1. `Create` and switch to `Snapshots` view
1. Examine the tags and notice only `Name` is provided
1. Add in the missing tags by hand

## Cloning An Instance Via Launch More Like This
1. Log into the console and bring up the `EC2 Dashboard`
1. Click `Instances` and select the instance created in the last 1ab
1. Click `Actions` then `Launch More Like This`
1. Click `Launch` and select the SSH key
1. Wait for the instance to come up and then ssh into it
1. In the console, edit the `Name` tag to read `Clone`
1. `sudo yum update` -- notice how the updates to be applied again
1. `df --print-type --human-readable` -- is the second volume mounted?
1. `lsblk --list --fs` -- is the second volume available?


## Attaching A Volume To A Running Instance
1. In the console, switch to `Instances` view and note the AZ id of the clone
1. Stop the clone
1. In the console, switch to `Volumes` view
1. Select the clone instance
1. `Create Volume`
1. Search by your snapshot's description and select it
1. Select the same AZ that your instance lives in
1. `Create`
1. Select the newly created volume (should be 100 GB in size)
1. Fill in the tags
1. `Actions`, `Attach Volume`
1. Select your clone instance
1. Leave `Device` to its default value
1. `Attach` and wait for it to complete
1. ssh into your instance
1. Run the the previously outlined steps to mount the volume
1. The volume already has a file system on it so **don't format the volume**
1. `ls --all -l --human-readable /mnt/data`.  Is your file still there?

# Lab 3: EC2 Virtual Servers (continued)

## Cloning An Instance Via An AMI
1. Ensure your instance has a file that distinguishes yours from others
1. Select the `Instances` view
1. Select your original instance
1. `Actions`, `Image`, `Create Image`
1. Fill in `Image Name` and `Image Description` as you like
1. `Create Image`
1. Wait for the AMI to complete
1. Select the AMI
1. Fill in the tags
1. `Launch`
1. Pick `t2.nano`
1. `Review and Launch`
1. Carefully review the settings and compare them to how the original instance looks
1. `Cancel` and start again, this time going through the full wizard
1. Launch the instance, wait for it to spin up and ssh into it
1. See if OS patches need to be applied
1. What files are in the home folder?
1. What files in the data folder?

## Sharing An AMI
1. In the console, select `AMIs`
1. Select your AMI
1. `Actions`, `Modify Image Permissions`, change to public

## Create An Instance Via Somebody Else's AMI
1. In the console, verify that you are in the `N. Virginia` region,
1. `Instances`
1. `Launch Instance`
1. `Community AMIs`
1. Search for an AMI created by someone else in the class
1. Spin up the instance and poke around.  See if it looks the same as the AMI creator expects.
1. Look in both the home directory and data volume

## Using Ephemeral Storage
1. Pull up [Amazon EC2 AMI Locator](https://cloud-images.ubuntu.com/locator/ec2/)
1. Find a `xenial` `hvm:instance-store` AMI and click on its id
1. Select `m3.medium`, which will cost you $0.07/hour
1. ssh into the instance
1. place a file in the home directory
1. `Reboot` the instance
1. see if your file is still there
1. Try and `Stop` the instance.  Will it let you?

## Change the Instance Type
1. select a stopped instance, a small type is preferred
1. `Actions`, `Instance Settings`, `Change Instance Type`
1. select something from a different family and is larger, eg.`m3.medium` costing $0.07/hour
1. spin up the instance
1. ssh into the instance
1. poke around and verify the increased cores and ram, eg `cat /proc/meminfo`, `cat /proc/cpuinfo`, `top`
1. stop the instance
1. change the instance type back to what it was

# Lab 4: EC2 Virtual Servers (continued)

## Termination Protection
1. Create a new EC2 instance of any size
1. Ensure `Enable termination protection` is checked
1. After the instance is up, use the console to terminate it. What happens?
1. Stop the instance
1. Use the console to terminate the instance.  What happens?

## Instance Metadata
1. ssh into an instance
1. `curl http://169.254.169.254/latest/meta-data/` -- **notice the trailing slash**
1. try different endpoints, eg `curl http://169.254.169.254/latest/meta-data/instance-id`

## Expand Volume
1. Spin up an existing EC2 instance, one that has the extra data volume attached
1. ssh into the instance
1. `df -Th` to note the size of the volumes
1. From the console, find the data volume in the `Instances` view and click through
1. From the `Volumes` view, `Actions`, `Modify Volume`
1. Double the size of the volume and click `Modify`
1. Once complete, `df -Th` to see that the volume is still at its original size
1. `sudo file -s /dev/xvdb` to verify the volume's file system
1. `lsblk` to verify that there is no partition that needs to be extended
1. Note the difference in size reporte by `df` and `lsblk`
1. `sudo resize2fs /dev/xvdb` to expand the volume to its new size
1. `df -Th` to verify that the file system has expanded to match the new volume size
1. `lsblk` and `df -h` should now agree

# Lab 5: Elastic Load Balancers

## Create Docker AMI
1. Spin up an Amazon Linux EC2 instance, `t2.nano` or `t2.micro` will do
1. `sudo yum update` -- patch any security vulnerabilities
1. `sudo yum install docker` -- install Docker runtime
1. `groups ec2-user`
1. `sudo usermod --append --groups docker ec2-user`
1. `groups ec2-user`
1. `sudo service docker restart`
1. `docker info`
1. install the Docker container using the script below
1. `docker ps`
1. `curl localhost:8080/operations/health | python -m json.tool`
1. `curl localhost:8080/operations/info | python -m json.tool`
1. `curl localhost:8080/ | python -m json.tool`
1. create an AMI out of it.  We'll use it to create multiple instances.

### Docker Container Installation Script
```
#!/bin/bash

APPLICATION_NAME=TLO
HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
AVAILABILITY_ZONE=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type)

CMD="docker run --detach \
                --name aws-echo \
                --network host \
                --restart always \
                --env INFO_APPLICATION_NAME=${APPLICATION_NAME} \
                --env INFO_APPLICATION_INSTANCE=${INSTANCE_TYPE}:${INSTANCE_ID} \
                --env INFO_APPLICATION_LOCATION=${AVAILABILITY_ZONE}:${HOST_NAME} \
                kurron/spring-cloud-aws-echo:latest"
echo ${CMD}
${CMD}
```

## Spin Up Classic ELB Instances
1. Use the AMI to launch at least 3 small instances.
1. Use a wide open security group to avoid firewall issues
1. Make sure the instances get assigned a public ip address
1. After they spin up, grab the public ip addresses and test them from your Windows box or another EC2 instance
1. `curl ip-address:8080/operations/health | python -m json.tool`
1. `curl localhost:8080/operations/info | python -m json.tool`
1. `curl ip-address:8080/ | python -m json.tool`

## Classic ELB
1. `Load Balancers`, `Create Load Balancer`
1. Select `Classic Load Balancer`, we create an `Application Load Balancer` later
1. Name the balancer so you know it is the classic balancer
1. `Load Balancer Port` should be `80` and `Instance Port` should be `8080`
1. `Assign Security Groups`, select a wide open group
1. `Configure Security Settings`, `Configure Health Check`
1. `Ping Port` should be `8080`
1. `Ping Path` should be `/operations/health`
1. `Interval` should be `10` seconds
1. `Healthy threshold` should be `2`
1. `Add EC2 Instances`
1. Select your newly spun up instances, `Add Tags`
1. Fill in the tags, `Review and Create`
1. `Create`
1. Select the `Instances` tab and wait for the instance status to be `InService`
1. Note the balancer's DNS name
1. `curl lb-dns-name:80/ | python -m json.tool`

## Classic ELB Failover
1. Create a script to continually hit the ELB
1. Run it and note the `served-by` value.  It should change with each request.
1. Also note the `calculated-return-path` and how it reflects the "outside" view
1. Note how we hit the balancer at port `80` but the service lives at `8080`
1. In the console, pull up the `Instances` to see which instances are showing as healthy
1. Select one instance and ssh into it
1. `docker ps` to show the running containers
1. `docker stop aws-echo` to turn off the container
1. Watch the watcher script.  Has service been disrupted?  How has the `served-by` changed?
1. Examine the balancer's `Monitoring` and `Instances` tabs
1. Repeat the process for another node.  How is service behaving now?
1. Re-enable each service via `docker start aws-echo` and watch the script and console
1. How would the health check settings affect how quickly instances get removed and added?
1. How do availability zones affect the load balancer and the EC2 instances?
1. If we wanted the load balancer to front more than one type of application, what would we do?
1. What non-HTTP applications might you front with a load balancer?

### Classic Load Balancer Watch Script
```
#!/bin/bash

# Your DNS name is going to be different
ELB=${1:-classic-load-balancer-1166062004.us-east-1.elb.amazonaws.com}
DELAY=${2:-2}

CMD="curl --silent http://${ELB}:80/"

for (( ; ; ))
do
#  echo ${CMD}
   ${CMD} | python -m json.tool
   sleep ${DELAY}
done
```

## Spin Up ELB Instances
1. Create another Docker AMI, this time **do not install the docker container**
1. Create 4 machines from the AMI but **install user data** with the Docker container script
1. Have 2 instance be the `TLO` application, `APPLICATION_NAME=TLO`
1. Have 2 instance be the `Mold-E` application, `APPLICATION_NAME=Mold-E`
1. Hit the `/operations/info` endpoint and ensure the information is correct

## ELB (Application Load Balancer)
1.
1. 2 mapped to /dolphins-suck
1. 2 mapped to /bills-suck
1. separate watcher scripts
1. turn off an AZ

## Search For Untagged Resources
1. In the console, `Resource Groups`
1. `Tag Editor`
1. Select a region where you have resources
1. Use `EC2` as your `Resource types` filter
1. Click the *cog* and the `Project` tag to the table
1. Notice how many resources are untagged making billing and other operations more difficult

## Watch For Untagged Resources
1. In the console, `Services`, `Config`, `Get Started`
1. `All Resources` and check `Include global resources`
1. `Create a bucket`
1. `Create a role`
1. Peruse the baked-in rules but don't select any
1. `Next` and `Confirm`
1. `Rules` and `Add rule`
1. `Add Custom Rule`
1. **TODO: we need to learn about Lambda first**

## Create Role
1. In the console, switch to the `IAM` view
1. `Roles`, `Create new role`
1. `AWS Service Role`,`Amazon EC2`, `Select`
1. Select `AdministratorAccess`, `Next Step`
1. Provide any `Role name` you want, eg, `ec2_administrative_access`
1. Enhance the `Role description` to say something to the effect that this role has full rights.
1. `Create Role`

## Create CLI Tool Instance
1. In the console, ensure you are in the `N. Virginia` region
1. `EC2`, `Instances`, `Launch`
1. Switch to `Community AMIs` view and search for `ami-67b5ed71`
1. Select any instance type you want but `t2.micro` or `t2.nano` should be just fine
1. `Configure Instance Details`, **use the IAM role created in the previous step**.
1. `Add Storage`, `Add Tags`
1. `Configure Security Group`, make sure to use one that is wide open, avoiding firewall issues
1. `Review and Launch`, `Launch`
1. Wait for the instance to spin up and ssh in
1. `aws --version`
1. `ansible --version`
1. `terraform --version`
1. `http --version`
1. `jq --version`
1. Verify that tab completion works on the `aws` command, eg `aws ec2 des` *tab key*

## Automate Instance Creation via Bash
## Automate Instance Creation via Ansible
## Automate Instance Creation via Terraform

# Tips and Tricks

# Troubleshooting

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).
