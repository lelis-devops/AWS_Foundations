#!/bin/bash
STANCE_TYPE="t3.micro"
AVAILABITY_ZONE="sa-east=1"
create_EC2 () {

AMI="ami-020cba7c55df1f615"

Firewall="launch-wizard-1"
 
KEY_NAME="girl"

Volumesize=8

INSTANCE_ID=$(aws ec2 run-instances \ 

--image-id ""$AMI"" \
--availabity_zone "$AVAILABITY_ZONE"
--instance-ids "$STANCE_TYPE" \ 
--key-name "$KEY_NAME" \
--security-groups "$Firewall" \
--block-device-mappings "{"DeviceName":"/dev/sdf","Ebs"\":{\"Volumeid\":$Volumeid}}]"
aws ec2 wait ec2-in-use --ec2-ids "$AMI"
}

create_EBS () {

SIZE=8
IOPS=3000
Attached="/dev/sdf"
VOLUME_TYPE="io1"
Volumesize=$(aws ec2 create-volume \
--size_gb="$SIZE_GB"
--availabity_zone "$AVAILABITY_ZONE"
 --iops "$IOPS" \
 --instance-id "$INSTANCE_ID" \
 --device "$Attached"
 aws ec2 wait volume-in-use --volume-ids "$volume_ID"
 sleep 10

}


mount_ebs () {
DEVICE_NAME="/dev/sdf"
MOUNT_POINT="/mnt/ebs"
sudo mkfs -t ext4 $DEVICE_NAME
sudo mkdir -p $MOUNT_POINT
sudo mount $DEVICE_NAME $MOUNT_POINT

echo " $DEVICE_NAME $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
}

create_EC2
create_EBS
mount_ebs
