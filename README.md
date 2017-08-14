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
1. log out and back into the instance or the next step will show an error
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

# Lab 6: Elastic Load Balancers

## Classic ELB Failover
1. Create a script to continually hit the ELB (see below)
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

# Lab 7: Elastic Load Balancers (continued)

## Create A Multi-Application AMI
1. Follow the instructions in the previous lab and create a Docker AMI
1. **Use the script below** to install the correct containers. **Don't use the script in the original instructions.**
1. For this example, we saved the script to `install-application.sh`
1. `./install-application.sh TLO / 8080` - to install the TLO application at port 8080
1. `./install-application.sh Mold-E / 9090` - to install the Mold-E application at port 9090
1. `curl --location --silent localhost:8080 | python -m json.tool`
1. `curl --location --silent localhost:8080/operations/health | python -m json.tool`
1. `curl --location --silent localhost:8080/operations/info | python -m json.tool`
1. `curl --location --silent localhost:9090 | python -m json.tool`
1. `curl --location --silent localhost:9090/operations/health | python -m json.tool`
1. `curl --location --silent localhost:9090/operations/info | python -m json.tool`
1. Create the AMI

### Docker Container Installation Script
```
#!/bin/bash

APPLICATION_NAME=${1:-FOO}
SERVER_PATH=${2:-/foo}
SERVER_PORT=${3:-1234}

HOST_NAME=$(curl http://169.254.169.254/latest/meta-data/hostname)
AVAILABILITY_ZONE=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type)

CMD="docker run --detach \
                --name ${APPLICATION_NAME} \
                --network host \
                --restart always \
                --env INFO_APPLICATION_NAME=${APPLICATION_NAME} \
                --env INFO_APPLICATION_INSTANCE=${INSTANCE_TYPE}:${INSTANCE_ID} \
                --env INFO_APPLICATION_LOCATION=${AVAILABILITY_ZONE}:${HOST_NAME} \
                --env SERVER_CONTEXT-PATH=${SERVER_PATH} \
                --env SERVER.PORT=${SERVER_PORT} \
                kurron/spring-cloud-aws-echo:latest"
echo ${CMD}
${CMD}
```

## Spin Up Multi-Application Instances
1. Use the newly created AMI to create 2 new instances
1. Use `cURL` and ensure that both ports can be hit on each instance
1. `curl --location --silent 54.202.28.248:8080/operations/info | python -m json.tool`
1. `curl --location --silent 54.202.28.248:9090/operations/info | python -m json.tool`
1. `curl --location --silent 54.202.28.248:8080/ | python -m json.tool`
1. `curl --location --silent 54.202.28.248:9090/ | python -m json.tool`

## Support Multiple Applications (Classic Load Balancer)
1. Create a classic ELB
1. Map port `1024` on the ELB to port `8080` in the instances
1. Map port `2048` on the ELB to port `9090` in the instances
1. Use `/operations/health` for the health check
1. Notice how only **one** of the two applications can provide the health check
1. Use `cURL` and hit each port on the ELB (convenience script provided below)
1. Notice how each port maps to a different application
1. Notice how we had to install **both** applications on each instance
1. What are some of the drawbacks to this technique?

### Dual Application ELB Watch Script
```
#!/bin/bash

ELB=${1:-dual-applications-classic-876351830.us-west-2.elb.amazonaws.com}
DELAY=${2:-2}

TLO="curl --location --silent ${ELB}:1024/operations/info"
MOLDE="curl --location --silent ${ELB}:2048/operations/info"

for (( ; ; ))
do
   ${TLO} | python -m json.tool
   echo
   ${MOLDE} | python -m json.tool
   sleep ${DELAY}
done
```

# Lab 8: Elastic Load Balancers (continued)

## Spin Up ELB Instances (Application Load Balancer)
1. Create another Docker AMI, this time **do not install the docker containers**
1. Create 4 machines from the AMI but **install user data** with the Docker container script from the previous exercise
1. ALB wants instances in at least two AZs so **ensure you have the 4 instances split between 2 AZs**
1. Have 2 instance be the `TLO` application. `APPLICATION_NAME=TLO`, `SERVER_PATH=/tlo`, `SERVER_PORT=8080`
1. Have 2 instance be the `Mold-E` application. `APPLICATION_NAME=Mold-E`, `SERVER_PATH=/mold-e`, `SERVER_PORT=9090`
1. Hit the `/tlo/operations/info` and `/mold-e/operations/info` endpoints
1. It is **very important to test the endpoints** with so many moving parts

## ELB (Application Load Balancer)
1. `Create Load Balancer`, `Application Load Balancer`
1. `Name` can be anything you want
1. `Scheme` should be `internet-facting`
1. `HTTP Listeners` port `80`
1. Select **all** subnets in your VPC. The UI is odd in this context.
1. Set your tags
1. `Configure Security Settings`, `Configure Security Groups`
1. Select or create a wide open group -- **all** ports and addresses
1. `Configure Routing`
1. `New Target Group` with `Name` of `TLO`, `Protocol` of `HTTP`, `Port` of `8080`
1. `Health Checks` should be set to `HTTP` and `/tlo/operations/health`
1. `Register Targets`
1. Select **only the TLO instances** -- we need the others for another group
1. `Review` and `Create`
1. Wait for the balancer to be provisioned
1. `Target Groups`, `Create Target Group`
1. Create a `Mold-E` group that points to port `9090` and `/mold-e/operations/health`
1. Select your load balancer
1. `View/edit rules`, `Add Rules`, `Insert Rule`, `Path`, forward `/tlo/*` to `TLO`, `Save`
1. Repeat but forward `/mold-e/*` to `Mold-E`
1. Test the ELB via `curl --follow --silent ALB-Experiment-763587424.us-west-2.elb.amazonaws.com/tlo/operations/info`
1. Test the ELB via `curl --follow --silent ALB-Experiment-763587424.us-west-2.elb.amazonaws.com/mold-e/operations/info`
1. run the watcher script below
1. turn off containers and watch how the ELB responds

### Dual Application ALB Watch Script
```
#!/bin/bash

ELB=${1:-dual-applications-classic-876351830.us-west-2.elb.amazonaws.com}
DELAY=${2:-2}

TLO="curl --location --silent ${ELB}:80/tlo/operations/info"
MOLDE="curl --location --silent ${ELB}:80/mold-e/operations/info"

for (( ; ; ))
do
   ${TLO} | python -m json.tool
   echo
   ${MOLDE} | python -m json.tool
   sleep ${DELAY}
done
```

# Lab 9: EC2 Container Service: Creating The Cluster
In this lab we'll create an empty cluster ready to accept work.

## Create Empty Cluster
1. `EC2 Container Service`, `Create Cluster`
1. Use `transparent` as the cluster name
1. **`Create an empty cluster`**

## Create ECS Instances
1. [Look up the AMI](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html) to use for your region
1. Create 2 instances from the AMI -- ideally in different availability zones
1. `t2.nano` should do just fine
1. **Important:** `IAM Role` and select `ecsInstanceRole` from the list
1. `Advanced Details` and enter the script below
1. `Storage` and leave defaults
1. Add your tags
1. Use a wide-open security group
1. Launch the instances
1. Monitor the `ECS Instances` of the `Amazon ECS` view
1. In a few minutes, your instances should be registered with the cluster

### ECS Instance User Data Script
```
#!/bin/bash
echo ECS_CLUSTER=transparent >> /etc/ecs/ecs.config
```

## Create ECS Task Definition
1. `Amazon ECS`, `Task Definitions`, `Create new Task Definition`
1. `Task Definition Name`: tlo
1. `Task Role`: None
1. `Network Mode`: Host, ignoring the warning
1. `Add container`
1. `Container name`: TLO-hard-port
1. `Image`: kurron/spring-cloud-aws-echo:latest
1. `Memory Limits (MB)`: Hard limit, 256
1. `Env Variables`: INFO_application_name, TLO
1. `Env Variables`: SERVER_CONTEXT-PATH, /tlo
1. `Add`, `Create`

## Create ECS Service
1. `Amazon ECS`, `Clusters`, `transparent`
1. `Services, `Create`
1. `Task Definition`: tlo
1. `Cluster`: transparent
1. `Serivce Name`: tlo-hard-port
1. `Number of tasks`: 2
1. `Create Service`, `View Service`
1. Monitor the `Tasks` tab until both tasks are running

## Test The Services, The Ugly Way
1. Obtain the public addresses of both EC2 instances
1. Hit each instance and make sure it responds
1. `curl --location --silent 54.200.196.150:8080/tlo/operations/info | python -m json.tool`
1. Poke around the differnt views and see what information is available

## Take One Instance Off-line
1. select one of the instances in the `ECS Instances` view
1. `Actions`, `Drain Instances`
1. Did the 2nd container get moved to the remaining instance?
1. How can we find out what happened?
1. How can we fix things?

# Lab 10: EC2 Container Service: Using an ELB

## Create Load Balancer
1. `Application Load Balancer`
1. Defaults are appropriate but *select all availability zones and subnets*
1. **wide open security group**
1. Create a new target group but it is a dummy one that won't be used
1. **Do not** register any targets
1. `Review` and `Create`
1. Wait for it to be provisioned

## Update Task Definition
1. Select the `tlo` task definition
1. `Create new revision`
1. Change `Network Mode` from `Host` to `Bridge`
1. Click `TLO-Hard-Port`
1. Change the name to `TLO-Dynamic-Port`
1. `Add port mapping`
1. Leave `Host Port` blank, `Container Port` 8080
1. `Update`
1. `Create`

## Create Load Balanced ECS Service
1. `Amazon ECS`, `Clusters`, `transparent`
1. `Services, `Create`
1. `Task Definition`: **tlo:2**
1. `Cluster`: transparent
1. `Serivce Name`: tlo-dynamic-port
1. `Number of tasks`: 2
1. `Configure ELB`
1. The defaults should be sufficient
1. `Add to ELB`
1. `Listener port` should be `80:HTTP`
1. Change `Path pattern` to `/tlo*`
1. `Evaluation order` to 1
1. Change `Health check path` to `/tlo/operations/health`
1. `Save`
1. `Create Service`, `View Service`
1. Monitor the `Tasks` tab until both tasks are running
1. Check the `Events` tab
1. cURL the ELB endpoint: `curl --silent ecs-balancer-1527593673.us-west-2.elb.amazonaws.com/tlo/operations/info | python -m json.tool`
1. Traffic should be balanced between the instances
1. Change number of desired tasks and see what happens

# Lab 11: EC2 and Auto Scaling Groups

## Create Launch Configuration
1. `Create launch configuration`
1. Pick Amazon Linux AMI and run it on a `t2.nano`
1. Name it `ec2-asg` and click `Enable CloudWatch detailed monitoring`
1. Make sure it gets a public address because we need to SSH into the boxes
1. Attach a wide-open security group
1. `Create launch configuration`
1. `Close`

## Create Auto Scaling Group
1. `Create Auto Scaling group`
1. Select `ec2-asg` from the list, `Next Step`
1. Name it `ec2-asg` and start with 1 instance
1. Select your VPC and all public subnets within it
1. `Advanced` and select `Enable CloudWatch detailed monitoring`
1. `Configure scaling policies`, `Use scaling policies to adjust the capacity of this group`
1. Scale between 1 and 6 instances
1. `Average CPU Utilization` and `Target Value` of 50
1. Give the instances 10 seconds to warm up
1. Set `Health Check Grace` to 60 seconds
1. Set `Default Cooldown` to 60 seconds
1. `Configure Notifications`, `Configure Tags`, `Create Auto Scaling Group`
1. Verify that you have one instance spinning up

## Simulate High CPU Load
1. SSH into the instance
1. `sudo yum update`, `sudo yum install stress`
1. `stress --verbose --cpu 1`
1. In another terminal, SSH into the instance and run `top` to ensure 100% of the CPU is being used
1. Monitor the `Activity History` and `Instances` tab in your ASG view
1. What happens? How long does it take?
1. Kill the stress program and monitor the ASG
1. What happens? How long does it take?
1. If we chose to `Disable scale-in` what would happen?
1. Change `Health Check Grace` to the default 300 seconds and re-run the experiment.
1. Try configuring Step Scaling and re-run the exeriment
1. **Clean up your ASG** or you will always be running an instance!

# Lab 12: EC2 Container Service: Using an ELB and Auto Scaling Group
Based on how long it took us to simulate resource exhaustion, this lab
will just be about noting where in the console the auto scaling option
for containers exists.  You can trigger scaling events on your own time.

1. select an existing service definition and `Update` it
1. Under `Optional configuration`, click `Configure Service Auto Scaling`
1. `Configure Service Auto Scaling to adjust your service’s desired count`
1. `Add scaling policy`, `Create new Alarm`
1. Notice how not only can we use the pre-baked RAM and CPU triggers but we can also create our own.
1. *NOTE:* we can combine EC2 instance scaling with ECS container scaling


# Lab 13: API Gateway
We'll need to understand the basics of API Gateway before we can move
on to our final compute capability, Lambdas. Watching the API Gateway
video prior to this lab is **highly recommended**.

## Create the API
1. A working TLO echo service is required. Past labs provide at least 3 possible ways of doing this.
1. Select `API Gateway` in the console
1. `Create API`, `New API`
1. Name it `aws-study-group`, put in a description followed by `Create API`
1. Select the `/` resource and click `Actions` and select `Create Method`
1. Select `ANY` from the dropdown and click the check mark.
1. `Integration type` of HTTP, check `Use HTTP Proxy integration`, enter in your TLO endpoint, then `Save`
1. eg. `http://ecs-balancer-1527593673.us-west-2.elb.amazonaws.com/tlo/`

## Have Method Request Forward Host Header
1. Click `Method Request`
1. Expand `HTTP Request Headers` then `Add header`
1. `Name` should be `host` and click the check mark.
1. Check the `Required` check box.

## Have Integration Request Translate Host Header
1. Click `Integration Request` and expand `HTTP Headers`
1. `Add header`, `Name` should be `x-forwarded-host`, `Mapped from` should be `method.request.header.host`, click the check mark

## Test Gateway Endpoint Internally
1. Click the `Test` link
1. Test a `GET` request

## Publish The API
1. Select the API in the tree
1. `Actions`, `Deploy API`
1. Create a new stage called `production` and `Deploy`
1. cURL the API endpoint, eg `https://a8eu4cq3gl.execute-api.us-west-2.amazonaws.com/production/`
1. Notice the `calculated-return-path` and `x-forwarded-host` properties
1. cURL the `/operations/info` endpoint.  What happens?

## Proxy After Slash
1. `Resources`, `Actions`, `Create Resource`
1. Check `Configure as proxy resource`, `Create Resource`
1. `HTTP Proxy`
1. `Endpoint URL` should have your endpoint plus the `{proxy}`, eg `http://ecs-balancer-1527593673.us-west-2.elb.amazonaws.com/tlo/{proxy}`
1. `Save`
1. Publish the API again
1. Try cURLing the operations endpoint again, eg `curl https://w4f4fmcaa6.execute-api.us-west-2.amazonaws.com/production/operations/info/`

# Lab 14: API Gateway Continued

## Generate API Key
1. Select `API Keys`
1. `Actions`, `Create API Key`
1. Name it `aws-study-group`
1. `Save`

## Use API Key
1. Select your API
1. Select `ANY`, `Method Request`
1. Change `API Key Required` to true
1. Republish the API
1. cURL the slash endpoint.  What happens?
1. Add the `x-api-key` header using your API key to the request
1. Add `--header x-api-key:my api key` to the cURL command
1. cURL the slash endpoint.  What happens?
1. **NOTE:** you should be denied until a Usage Plan is attached

## Configure Usage Plan
1. `Usage Plans`, `Create`
1. Name it `aws-study-group-usage-plan`
1. Set the `Rate` to `1` and the `Burst` to `2`
1. Limit to `10` requests per `Day`
1. `Next`
1. `Add API Stage` and assoctiate the `production` stage of your API
1. `Next`, `Add API Key to Usage Plan`
1. Associate the API key to the plan, `Done`
1. Try cURLing the endpoint again.  What happens?

## Exceed Usage Plan
1. Hit the endpoint several more times? What happens?
1. `Usage Plans`, `aws-study-group-usage-plan`, `API Keys`, `Extension`
1. Give the key 5 more requests for the day
1. cURL again.  What happens?

## Configure Usage Plan Part Duex
1. Add the other resource to the Usage plan
1. Hit `/operations/info` and verify that limits are working

# Lab 15: AWS Lambda -- What's For Dinner, Alexa?
We will be following the steps in [Amazon Alexa Skill Recipe with Python 3.6](https://medium.com/@jacquelinewilson/amazon-alexa-skill-recipe-1444e6ee45a6).  **IMPORTANT:** [set up a developer account](https://developer.amazon.com/home.html)
prior to attempting the lab.

## Intents
```python
{
    "intents":[
        {
            "intent":"DinnerBotIntent"
        }
    ]
}
```

## Sample Utterances
```
DinnerBotIntent What should I have for dinner
DinnerBotIntent Do you have a dinner idea
DinnerBotIntent Whats for dinner
```

## Lambda Code
```python
import random

dinnerOptions = [
    "Chicken",
    "Beef",
    "Pork",
    "Fish",
    "Vegetarian"
]

def lambda_handler( event, context ):
    dinner = random.choice( dinnerOptions )
    response = {
        'version': '1.0',
        'response': {
            'outputSpeech': {
                'type': 'PlainText',
                'text': dinner
            }
        }
    }
    return response
```

# Lab 16: AWS Lambda with API Gateway
We'll be following the steps in [Using AWS Lambda with Amazon API Gateway (On-Demand Over HTTPS)](http://docs.aws.amazon.com/lambda/latest/dg/with-on-demand-https.html)

# Lab 17: AWS Lambda and Scheduled Events
We'll be following the steps in [Using AWS Lambda with Scheduled Events](http://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html)

# Lab 18: AWS Lambda and S3
We'll be following the steps in [Using AWS Lambda with Amazon S3](http://docs.aws.amazon.com/lambda/latest/dg/with-s3.html)

# Lab 19: AWS CloudFormation
It has become apparent to me that people enjoy a "guided tour" as opposed to step-by-step instructions.
So, for this lab, we'll outline a simple objective and let people figure out how to do it based
on what was learned in the video.

* Write a CloudFormation template that creates a new ECS cluster
* Feel free to use [my personal template](https://github.com/kurron/cloud-formation-ecs-service) as a reference
* You will need CLI access so I suggest creating a dedicated EC2 instance for this and future labs
* You will need to access the CloudFormation [refence documentation](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html) to do this
* For bonus points, launch your stack via the console

# Lab 20: Automation and AWS CLI
1. spin up an Amazon Linux instance making sure to assign it an admin role
1. ensure the CLI is installed via `aws --version`
1. install git via `sudo yum update` followed by `sudo yum install git`
1. `git --version`
1. clone the study group materials, `git clone https://github.com/kurron/aws-study-group-labs.git`
1. `cd aws-study-group-labs/labs/lab-20`
1. `./sanity-check-cli.sh`
1. edit `spin-up-instance-via-aws-cli.sh` so that is succeeds
1. run the script a second time.  What happens?
1. run the script a third time.  What happens?
1. create a script that terminates the instance you just created

# Lab 21: Automation and CloudFormation
1. spin up the instance from Lab 20
1. `cd aws-study-group-labs`
1. reset the area via `git reset --hard`
1. `git status` to ensure old changes no longer exist
1. `git pull --rebase` to update the area with the new lab
1. Open the CloudFormation view in the console
1. `cd labs/lab-21/`
1. edit `cloudformation.yml` to utilize the supplied parameters
1. `./validate-stack.sh` will validate the descriptor
1. edit and run `./create-stack.sh` to spin up the stack
1. look at the stack in the console, especially the outputs and events
1. `./create-stack.sh` a second time.  What happens?
1. edit and run `./destroy-stack.sh` to clean things up

# Lab 22: Automation and Ansible
1. spin up the instance from Lab 20
1. `cd aws-study-group-labs`
1. reset the area via `git reset --hard`
1. `git status` to ensure old changes no longer exist
1. `git pull --rebase` to update the area with the new lab
1. `cd labs/lab-22/`
1. `./install-ansible.sh` to install Ansible
1. edit `playbook.yml`adding the missing pieces
1. `./playbook.yml` to run your playbook
1. run the playbook a second time.  What happens?
1. Compare the Ansible descriptor to the CloudFormation one.  Which do you prefer?

# Lab 23: Automation and Terraform
1. spin up the instance from Lab 20
1. `cd aws-study-group-labs`
1. reset the area via `git reset --hard`
1. `git status` to ensure old changes no longer exist
1. `git pull --rebase` to update the area with the new lab
1. `cd labs/lab-23/`
1. `./install-terraform.sh` to install Terraform
1. edit `ec2-instance.tf` so it can spin up an EC2 instance.  **HINT:** there is very little to add.
1. `terraform init` to initialize Terraform -- **don't supply a key pair**
1. `terraform plan` to validate the file and see what changes are proposed
1. `terraform apply` to execute the proposed changes
1. `terraform show` to see the results of the execution
1. visit the console and verify that the instance fully comes up
1. edit `ec2-instance.tf` and add the key pair attribute
1. `terraform plan` to see what changes are proposed
1. What is interesting in the output?
1. `terraform apply` to execute the proposed changes
1. visit the console and verify that the instance fully comes up
1. How many instances do you see?
1. `terraform apply` again to see what happens
1. `terraform destroy` to clean up
1. Compare the Terraform descriptor to the Ansible and CloudFormation one.  Which do you prefer?

---



**Ron Notes. Ignore.**

1. Create API Keys
1. Start an Amazon Linux AMI
1. `sudo yum update` to apply any OS updates
1. `aws --version` to verify the AWS CLI is installed
1. `aws configure` to setup the tool
1. Install [ECS CLI](https://github.com/aws/amazon-ecs-cli)
1. `curl --output ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-v0.4.1`
1. `chmod a+x ecs-cli`
1. `sudo mv ecs-cli /usr/local/bin`
1. `ecs-cli --version`
1. `ecs-cli help configure` -- to see how to configure the tool


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

---

# Proposed Remaining Module Ideas

## Automation via AWS CLI and Bash
## Automation via Terraform
## [S3 Masterclass](https://acloud.guru/)
## [AWS Lambda](https://acloud.guru/)
## [Introduction to AWS CloudFormation](https://acloud.guru/)
## [Alexa - A Free Introduction](https://acloud.guru/)
## [AWS Cost Control](https://acloud.guru/)
## [Docker for DevOps - From Development to Production](https://acloud.guru/)
## [AWS CodeDeploy](https://acloud.guru/)
## [Alexa Development For Absolute Beginners](https://acloud.guru/)
## [AWS Security](https://acloud.guru/)
## [AWS Event Driven Security](https://acloud.guru/)

## [Cloud Computing With AWS](https://www.safaribooksonline.com/library/view/cloud-computing-with/9781771371209/)
1. AutoScaling and CloudWatch
1. CloudFormation
1. Storage in AWS
1. Relational Database Service
1. Simple Storage Service
1. CloudFront
1. ElastiCache
1. Virtual Private Cloud
1. Simple Notification Service
1. Simple Email Service
1. Simple Queuing Service
1. Identity And Access Management (IAM)
1. Route 53
1. Building A 3 Tier Scalable Web Application In The Cloud

## [Introduction to Ansible](https://www.safaribooksonline.com/library/view/introduction-to-ansible/9781491955956/)
1. Introduction To Ansible
1. Setup, Installation And Configuration
1. Ansible, Ansible-Docs, Ansible-Playbook
1. Includes And Roles
1. Playbooks Continued
1. Special Topics

# Tips and Tricks

# Troubleshooting

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).
