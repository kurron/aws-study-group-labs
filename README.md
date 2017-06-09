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
1. Run the the prevously outlined steps to mount the volume 
1. The volume already has a file system on it so **don't format the volume**
1. `ls --all -l --human-readable /mnt/data`.  Is your file still there?

# Lab 3: EC2 Virtual Servers (continued)

## Cloning An Instance Via An AMI
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
1. What filer in the data folder? 

## Sharing An AMI
1. In the console, select `AMIs`
1. Select your AMI
1. `Actions`, `Modify Image Permissions`, change to public

## Create An Instance Via Somebody Else's AMI

# Tips and Tricks

# Troubleshooting

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).
