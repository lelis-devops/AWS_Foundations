#!/bin/bash

create_EC2 () {

AMI="ami-020cba7c55df1f615"

STANCE_TYPE="t3.micro"

Firewall="launch-wizard-1"
 
KEY_NAME="girl"


Volumesize=8

INSTANCE_ID=$(aws ec2 run-instances \ 

--image-id "$AMI" \
--instance-type" $STANCE_TYPE" \ 
--key-name "$KEY_NAME" \
--security-group" $Firewall" \
--block-device-mappings "{"DeviceName":"/dev/sda1","Ebs"\":{\"Volumesize\":$VOLUMEsize}}]"

}

attach_EBS () {

volumesize_ID="vol-0b49603bd18e9a354"

Submitted-Resources="i-0426bf9ecbed68a59"

Attached="/dev/sda1"

Snapshot_ID="0bc1d350c2ac74766"
aws ec2 run-attach-volume \

 --volume-id "$VOLUME_ID" \
 --instance-id "$INSTANCE_ID" \
 --device "$Attached"


}


mount_ebs () {
DEVICE_NAME="/dev/sda1"
MOUNT_POINT="/mnt/ebs"
sudo mkfs -t $DEVICE_NAME
sudo mkdir -p $MOUNT_POINT
sudo mount $DEVICE_NAME $MOUNT_POINT

echo " $DEVICE_NAME $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

}

create_EC2
attach_EBS
mount_ebs
